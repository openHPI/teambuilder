require 'csv'
require 'team_builder/course_features'
require 'team_builder/grouping'

class Course < ApplicationRecord

  has_many :enrollments, dependent: :delete_all
  has_many :teams, -> { order 'id ASC' }, dependent: :delete_all
  has_many :empty_teams, -> { empty }, class_name: 'Team'

  validates_uniqueness_of :id, scope: :platform_id

  include Workflow

  workflow do
    state :new do
      event :publish, transitions_to: :published
    end
    state :published do
      event :export, transitions_to: :published
      event :manipulate_teams, transitions_to: :published
      event :clear_teams, transitions_to: :published
      event :create_collab_spaces, transitions_to: :finished
      event :copy, transitions_to: :published
    end
    state :copied do
      event :clear_teams, transitions_to: :copied
      event :export, transitions_to: :copied
      event :manipulate_teams, transitions_to: :copied
    end
    state :finished do
      event :copy, transitions_to: :finished
      event :export, transitions_to: :finished
    end
  end

  default_scope { order name: :asc }

  include ActionView::Helpers::TextHelper

  def copy(new_name)
    new_course = self.dup
    new_course.update name: new_name,
                      auth_key: nil,
                      auth_secret: nil,
                      workflow_state: :copied
    new_course.features = features.dup
    new_course.enrollments = enrollments.map{|e| e.dup}
    Course.reset_counters(new_course.id, :enrollments)
    new_course
  end

  def reset_teams
    teams.destroy_all
    # Make sure all remaining orphans are reset, too
    enrollments.update_all team_id: nil
  end

  def human_state
    if published?
      'Public ' + human_enrollments_count
    elsif finished?
      'Teams transferred'
    elsif copied?
      'Copy ' + human_enrollments_count
    else
      'Not public'
    end
  end

  def human_enrollments_count
    pluralize(enrollments.size, 'enrollment')
  end

  def state
    if published?
      'published'
    elsif finished?
      'teams transferred'
    elsif copied?
      'copied'
    else
      'not public'
    end
  end

  def platform
    @platform ||= Platform.find platform_id
  end

  def oauth_credentials
    if auth_key.present? && auth_secret.present?
      {key: auth_key, secret: auth_secret}
    elsif platform.oauth_credentials?
      platform.oauth_credentials
    else
      raise 'No OAuth credentials found'
    end
  end

  def features
    @features ||= TeamBuilder::CourseFeatures.from_database features_from_db
  end

  def features=(new_features)
    delete_old_features

    @features = TeamBuilder::CourseFeatures.wrap new_features
    insert_new_features(@features)
  end

  def custom_preferences
    @custom_preferences = features.select do |feature|
      feature.type == 'preferred_tasks'
    end
  end

  def has_teams?
    teams.exists?
  end

  def has_orphans?
    not orphans.empty?
  end

  def orphans
    @orphans ||= enrollments.where(team_id: 0)
  end

  def orphan_team
    Team.new(
      id: 0,
      name: 'Orphans',
      members: orphans
    )
  end

  def remaining_participants
    enrollments.where team_id: nil
  end

  def teams_as_csv
    CSV.generate do |csv|
      teams.to_a.unshift(orphan_team).each do |team|
        team.members.each do |member|
          csv << [team.name, member.name, member.email, member.user_id].tap do |row|
            row.push "#{member.score.to_f.round}%" if platform.check_scores?
            row.concat(features.qualifiers_for(member).map { |q| q[:text] })

            row.push platform.collab_space_link(team) if platform.collab_space_link? && team.collab_space_id
          end
        end
      end

      remaining_participants.each do |member|
        csv << ['Remaining', member.name, member.email, member.user_id].tap do |row|
          row.push "#{member.score.to_f.round}%" if platform.check_scores?
          row.concat(features.qualifiers_for(member).map { |q| q[:text] })
        end
      end
    end
  end

  def locked?
    current_state >= :published
  end

  def can_delete_course?
    current_state == :copied
  end

  def start_grouping_async!(enabled_features, opts, team_settings)
    return if grouping_teams

    update grouping_teams: true
    GroupingWorker.perform_async(id, enabled_features, opts, team_settings)
  end

  def group_teams!(enabled_features, opts, team_settings)
    # If participants are limited by score, we have to fetch the latest ones.
    if team_settings[:min_score]
      update updating_scores: true
      update_scores!
    end

    # Persist feature config to let the team page know which features to show.
    self.features = features.with_group_settings(enabled_features, opts)

    # And finally, start the actual grouping process!
    self.teams = TeamBuilder::Grouping.start!(
      enrollments,
      features.only_grouping_enabled,
      team_settings
    )
  rescue => err
    Mnemosyne.attach_error err
  ensure
    update grouping_teams: false
  end

  def update_scores_async!
    return if updating_scores

    update updating_scores: true

    ScoreFetchWorker.perform_async id
  end

  def update_scores!
    return unless platform.check_scores?

    # Reset all scores
    enrollments.update_all(score: 0.0)

    platform.user_scores(self).map { |user_id, score|
      sql = 'UPDATE enrollments SET score = $1 WHERE user_id = $2 AND course_id = $3'
      ActiveRecord::Base.connection.exec_update sql, 'Update user score', [[nil, score], [nil, user_id], [nil, id]]
    }
  ensure
    update updating_scores: false
  end

  private

  def create_collab_spaces
    platform.create_collab_spaces teams
  end

  def features_from_db
    sql = 'SELECT type, value, grouping_enabled FROM course_settings WHERE course_id = $1'
    ActiveRecord::Base.connection.select_all sql, nil, [[nil, id]]
  end

  def delete_old_features
    sql = 'DELETE FROM course_settings WHERE course_id = $1'
    ActiveRecord::Base.connection.exec_delete sql, 'Delete old course features', [[nil, id]]
  end

  def insert_new_features(new_features)
    new_features.each { |feature|
      sql = 'INSERT INTO course_settings (course_id, type, value, grouping_enabled) VALUES ($1, $2, $3, $4)'
      ActiveRecord::Base.connection.exec_insert(
        sql,
        'Insert new course feature',
        [
          [nil, id],
          [nil, feature.type],
          [nil, feature.to_s],
          [nil, new_features.grouping_enabled?(feature.type)]
        ]
      )
    }
  end

end
