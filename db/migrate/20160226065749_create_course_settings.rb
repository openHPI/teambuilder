class CreateCourseSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :course_settings, id: false do |t|
      t.uuid :course_id
      t.string :type
      t.text :value
    end
  end
end
