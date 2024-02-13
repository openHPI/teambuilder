class CreateEnrollments < ActiveRecord::Migration[4.2]
  def change
    create_table :enrollments do |t|
      t.uuid :user_id
      t.uuid :course_id
      t.text :data
      t.timestamps null: false
    end
  end
end
