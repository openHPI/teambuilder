class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :update, :teams, :build_teams, :team_action, :destroy, :copy]
  before_action :set_platform, only: [:new, :create]

  before_action :authenticate_course_admin!, only: [:show, :update, :teams, :build_teams, :team_action]
  before_action :authenticate_admin!, except: [:show, :update, :teams, :build_teams, :team_action]

  before_action :ensure_scores_are_not_updating, only: [:build_teams]

  # GET /courses
  def index
    @courses = Course.all
    @platforms = @courses.map(&:platform_id).uniq
    @states = @courses.map(&:state).uniq
  end

  # GET /courses/new
  def new
    if params[:platform_id]
      @courses = available_courses if @platform.courses?
      render 'new'
    else
      render 'choose_platform'
    end
  end

  # POST /courses
  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to @course, notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  # GET /courses/1
  def show
    respond_to do |format|
      format.html { render 'settings' }
      format.json {
        render json: @course.as_json(only: [:updating_scores, :grouping_teams])
      }
    end
  end

  # PATCH/PUT /courses/1
  def update
    if params[:publish]
      if @course.can_publish?
        @course.publish!

        redirect_to course_path(@course), notice: 'The settings have been locked.'
      else
        redirect_to course_path(@course), notice: 'Course settings have already been published'
      end
    else
      @course.features = enabled_course_features(settings_params)

      redirect_to course_path(@course), notice: 'Settings have been saved.'
    end
  end

  # GET /courses/1/teams
  def teams
    if @course.grouping_teams
      render 'teams_building'
    elsif @course.has_teams?
      @course_teams = CourseTeamsPresenter.new(@course, sort: params[:order], open: params[:open])

      respond_to do |format|
        format.html
        format.csv { render csv: @course.teams_as_csv, filename: "teams-#{@course.id}" }
      end
    else
      render 'team_settings'
    end
  end

  # POST /courses/1/teams/action
  def team_action
    if params[:create_collab_spaces]
      action_create_collab_spaces
    elsif params[:clear_teams]
      action_clear_teams
    elsif params[:create_team]
      action_create_team
    elsif params[:delete_team]
      action_delete_team
    elsif params[:delete_empty_teams]
      action_delete_empty_teams
    elsif params[:toggle_team_approval]
      action_toggle_team_approval
    elsif params[:move_members]
      action_move_members
    elsif params[:change_team_note]
      action_change_team_note
    else
      render status: 400, text: 'invalid request'
    end
  end

  # POST /courses/1/teams
  def build_teams
    if params[:build]
      @course.start_grouping_async! enabled_grouping_features,
                                    grouping_opts,
                                    team_settings

      redirect_to teams_course_path(@course)
    else
      @course.update_scores_async!

      redirect_to teams_course_path(@course), notice: 'Scores are now updating.'
    end
  end

  # DELETE /courses/1
  def destroy
    @course.destroy
    redirect_to courses_path, notice: 'Course was successfully destroyed.'
  end

  # POST courses/:id/copy
  def copy
    if @course.copy copy_params[:name]
      redirect_to courses_path, notice: 'successfully copied course'
    else
      redirect_to courses_path, notice: 'failed to copy course'
    end
  end


  private

  def action_create_collab_spaces
    if @course.platform.collab_spaces? && @course.can_create_collab_spaces?
      @course.create_collab_spaces!

      redirect_to teams_course_path(@course), notice: 'The teams have been exported.'
    else
      render status: 404, text: 'We do not support sending teams to the course platform. Please export the teams as CSV and import them manually.'
    end
  end

  def action_clear_teams
    @course.reset_teams
    redirect_to teams_course_path(@course), notice: 'All teams were reset.'
  end

  def action_create_team
    # Make sure we're only dealing with enrollments for this course
    enrollments = Enrollment.find params[:members].keys rescue return back_to_teams_with('Please select members for this team')
    return back_to_teams_with('Selected members do not belong to this course') if enrollments.any? { |e| e.course != @course }

    team = Team.new(name: params[:team_name], course: @course)

    # Make sure we have a valid name
    return back_to_teams_with('Please provide a valid team name') unless team.valid?

    team.members = enrollments
    team.save

    affected_teams = enrollments.map(&:team_id).uniq.push(team.id)

    redirect_to teams_course_path(@course, open: affected_teams, order: params[:order], anchor: "team-#{team.id}"), notice: 'Team was created.'
  end

  def action_delete_team
    team = Team.find params[:delete_team].keys.first rescue return back_to_teams_with('Invalid team selected')

    return back_to_teams_with('Can not delete non-empty teams') if team.members.count > 0

    team_name = team.name
    team.destroy

    redirect_to teams_course_path(@course, order: params[:order]), notice: "Team '#{team_name}' was deleted."
  end

  def action_delete_empty_teams
    @course.empty_teams.destroy_all
    redirect_to teams_course_path(@course, order: params[:order])
  end

  def action_toggle_team_approval
    team = Team.find params[:toggle_team_approval].keys.first rescue return back_to_teams_with('Invalid team selected')

    team.toggle! :approved

    redirect_to teams_course_path(@course, order: params[:order]), notice: "Team '#{team.name}' was updated."
  end

  def action_change_team_note
    id = params[:change_team_note].keys.first
    team = Team.find id rescue return back_to_teams_with('Invalid team selected')
    team.note = params[:note][id]
    team.save

    redirect_to teams_course_path(@course, order: params[:order]), notice: "Note of team '#{team.name}' was updated."
  end

  def action_move_members
    # Make sure we're only dealing with enrollments for this course
    enrollments = Enrollment.find params[:members].keys rescue return back_to_teams_with('Please select members to move')
    return back_to_teams_with('Selected members do not belong to this course') if enrollments.any? { |e| e.course != @course }

    # Make sure the target is a team for this course
    target_team = Team.find_by id: params[:target_team]
    return back_to_teams_with('Please select a valid target team') if params[:target_team] != '0' && (target_team.nil? || target_team.course != @course)

    affected_teams = enrollments.map(&:team_id).uniq.push(params[:target_team])

    # Move the team members
    enrollments.each do |enrollment|
      enrollment.update team_id: params[:target_team]
    end

    # ...and redirect back
    redirect_to teams_course_path(@course, open: affected_teams, order: params[:order], anchor: "team-#{target_team.id}"), notice: 'Members were moved.'
  end

  def back_to_teams_with(message)
    redirect_to teams_course_path(@course, order: params[:order]), flash: { error: message }
  end

  def set_course
    @course = Course.find_by!(id: params[:id])
  end

  def set_platform
    @platform = Platform.find params[:platform_id] if params[:platform_id]
  rescue KeyError
    render plain: 'invalid platform', status: 400
  end

  def ensure_scores_are_not_updating
    if @course.updating_scores
      redirect_to teams_course_path(@course),
                  flash: {error: 'Scores are currently updating.'}
    end
  end

  def authenticate_course_admin!
    current_user.can_administer?(@course) || authenticate_admin!
  end

  def available_courses
    # All courses, except for already connected ones
    @available_courses ||= Hash[@platform.courses.map { |course|
      [course['id'], "#{course['title']} - #{course['course_code']}"]
    }].except(
      *Course.where(platform_id: @platform.name).map(&:id)
    )
  end

  def team_settings
    {}.tap { |hash|
      hash[:new_grouping] = params[:new_grouping] == 'yes'
      hash[:max_participants] = params[:max_candidates].to_i if params[:limiters] && params[:limiters][:by_number]
      hash[:min_score] = params[:min_score].to_i if params[:limiters] && params[:limiters][:by_score]
      hash[:min_size] = params[:min_size].to_i if params[:min_size]
      hash[:max_size] = params[:max_size].to_i if params[:max_size]
      hash[:randomize] = true if params[:randomize] == 'yes'
    }
  end

  def course_params
    if @platform.courses?
      {
        id: params[:course],
        name: chosen_course_name,
        platform_id: @platform.name
      }
    else
      params.permit :name, :auth_key, :auth_secret, :platform_id
    end
  end

  def chosen_course_name
    available_courses[params[:course]]
  end

  def copy_params
    params.require(:course).permit(:name)
  end

  def settings_params
    params.permit(
      :terms,
      features: [
        :group_by_commitment,
        :group_by_expertise,
        :group_by_gender,
        :group_by_age,
        :local_teams,
        :language_teams,
        :preferred_tasks,
        :accept_terms
      ],
    ).merge(params.to_unsafe_hash.slice(:preferred_tasks))
  end

  def enabled_course_features(p)
    [].tap { |features|
      f = p[:features] || {}

      features << TeamBuilder::CourseFeatures::AreaOfExpertise.new(p[:group_by_expertise]) if f[:group_by_expertise]
      features << TeamBuilder::CourseFeatures::Gender.new if f[:group_by_gender]
      features << TeamBuilder::CourseFeatures::Age.new if f[:group_by_age]
      features << TeamBuilder::CourseFeatures::Commitment.new if f[:group_by_commitment]
      features << TeamBuilder::CourseFeatures::LocalTeams.new(100) if f[:local_teams]
      features << TeamBuilder::CourseFeatures::LanguageTeams.new if f[:language_teams]

      if f[:preferred_tasks].present?
        p[:preferred_tasks].each_pair do |pt|
          next if Array.wrap(pt[1].dig('tasks')).empty?

          features << TeamBuilder::CourseFeatures::PreferredTasks.new(pt.dig(1, 'tasks'), name: pt.dig(1, 'name'), id: pt.dig(1, 'id') || SecureRandom.uuid)
        end
      end

      features << TeamBuilder::CourseFeatures::AcceptTerms.new(p[:terms]) if f[:accept_terms]
    }
  end

  def enabled_grouping_features
    Array.wrap (params[:enabled] || {}).keys
  end

  def grouping_opts
    {
      features: {}.tap { |features|
        features['timezone'] = {type: params[:timezone]}
        features['timezone'][:max_distance] = params[:max_distance] if params[:max_distance]
        features['language_teams'] = {diversity: params[:language]} if params[:language]
        features['group_by_expertise'] = {diversity: params[:expertise]} if params[:expertise]
        features['group_by_gender'] = {diversity: params[:gender]} if params[:gender]
        features['group_by_age'] = {diversity: params[:age]} if params[:age]
        features['preferred_tasks'] = {diversity: params[:task]} if params[:task]
        features['group_by_commitment'] = {diversity: params[:commitment]} if params[:commitment]
      }
    }
  end
end
