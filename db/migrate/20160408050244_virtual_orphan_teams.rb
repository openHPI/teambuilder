class VirtualOrphanTeams < ActiveRecord::Migration[4.2]
  def up
    teams = exec_query "SELECT * FROM teams WHERE name='Orphans'"

    team_ids = teams.map { |team| team['id'] }

    if team_ids.count > 0
      execute "UPDATE enrollments SET team_id = 0 WHERE team_id IN (#{team_ids.join ','})", 'Update orphans'
      execute "DELETE FROM teams WHERE id IN (#{team_ids.join ','})", 'Remove orphan teams'
    end
  end

  def down
    # noop
  end
end
