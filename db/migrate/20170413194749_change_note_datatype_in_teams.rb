class ChangeNoteDatatypeInTeams < ActiveRecord::Migration[4.2]
  def up
    change_column :teams, :note, :text
  end

  def down
    change_column :teams, :note, :string
  end
end
