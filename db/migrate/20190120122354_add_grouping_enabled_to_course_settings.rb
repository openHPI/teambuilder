class AddGroupingEnabledToCourseSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :course_settings, :grouping_enabled, :boolean, null: false, default: true
  end
end
