class CreateCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :courses, id: :uuid do |t|
      t.string :name
      t.string :auth_key
      t.string :auth_secret
      t.string :url
      t.string :platform
      t.boolean :published, null: false, default: false
      t.integer :enrollments_count, default: 0
      t.timestamps null: false
    end
  end
end
