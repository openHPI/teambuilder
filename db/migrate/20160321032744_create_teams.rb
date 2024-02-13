class CreateTeams < ActiveRecord::Migration[4.2]
  def change
    create_table :teams do |t|
      t.string :name
      t.uuid :course_id, index: true
      t.timestamps null: false
    end
  end
end
