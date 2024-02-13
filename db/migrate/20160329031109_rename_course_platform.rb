class RenameCoursePlatform < ActiveRecord::Migration[4.2]
  def change
    rename_column :courses, :platform, :platform_id
  end
end
