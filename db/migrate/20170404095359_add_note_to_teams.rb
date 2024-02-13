class AddNoteToTeams < ActiveRecord::Migration[4.2]
  def change
    add_column :teams, :note, :string
  end
end
