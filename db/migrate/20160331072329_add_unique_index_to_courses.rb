class AddUniqueIndexToCourses < ActiveRecord::Migration[4.2]
  def change
    add_index :courses, [:platform_id, :id], unique: true
  end
end
