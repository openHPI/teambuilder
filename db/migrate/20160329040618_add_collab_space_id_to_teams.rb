class AddCollabSpaceIdToTeams < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :collab_space_id, :string
  end
end
