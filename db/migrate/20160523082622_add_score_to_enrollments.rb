class AddScoreToEnrollments < ActiveRecord::Migration[4.2]
  def change
    add_column :enrollments, :score, :float
  end
end
