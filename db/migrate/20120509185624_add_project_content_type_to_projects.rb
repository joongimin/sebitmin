class AddProjectContentTypeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :project_content_type, :integer
    add_column :projects, :content_html, :string
    Project.update_all :project_content_type => Settings.project_content_type_photos
  end
end
