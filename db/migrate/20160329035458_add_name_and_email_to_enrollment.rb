class AddNameAndEmailToEnrollment < ActiveRecord::Migration[4.2]
  def change
    add_column :enrollments, :name, :string
    add_column :enrollments, :email, :string
  end
end
