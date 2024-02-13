class CourseTeamsPresenter
  def initialize(course, sort: 'name', open: [])
    @course = course
    @sort = sort
    @open = Array.wrap(open).map(&:to_i)
  end

  def each(&block)
    sorted_teams.each(&block)
  end

  def possible_sort_orders
    @possible_sort_orders ||= {
      'name' => Team::SortByName.new,
      'size' => Team::SortBySize.new
    }.merge(@course.features.sort_options)
  end

  def possible_targets
    sorted_teams.unshift(@course.orphan_team)
  end

  def open?(team)
    @open.include? team.id
  end

  private

  def sorted_teams
    @sorted_teams ||= begin
      # Preload and sort all the teams
      ActiveRecord::Associations::Preloader.new.preload(@course, teams: :members)
      @course.teams.sort { |a, b| team_sorter.sort a, b }
    end
  end

  def team_sorter
    possible_sort_orders.fetch(@sort, possible_sort_orders['name'])
  end
end
