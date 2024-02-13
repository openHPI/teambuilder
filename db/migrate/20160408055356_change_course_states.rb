class ChangeCourseStates < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE courses SET workflow_state = 'finished' WHERE workflow_state = 'exported'", 'exported -> finished'
  end

  def down
    execute "UPDATE courses SET workflow_state = 'exported' WHERE workflow_state = 'finished'", 'finished -> exported'
  end
end
