class AddApprovedToTeam < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :approved, :boolean, null: false, default: false
  end
end
