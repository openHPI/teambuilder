class AddTeamToEnrollments < ActiveRecord::Migration[4.2]
  def change
    add_column :enrollments, :team_id, :integer
  end
end
