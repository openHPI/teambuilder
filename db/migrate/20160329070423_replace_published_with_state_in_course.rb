class ReplacePublishedWithStateInCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :workflow_state, :string

    reversible do |dir|
      dir.up { execute "UPDATE courses SET workflow_state = 'published' WHERE published = TRUE" }
      dir.down { execute "UPDATE courses SET published = TRUE WHERE workflow_state = 'published'" }
    end

    remove_column :courses, :published, :boolean, null: false, default: false
  end
end
