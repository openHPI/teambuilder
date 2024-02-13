class AddGroupingTeamsToCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :grouping_teams, :boolean,null: false, default:false
  end
end
