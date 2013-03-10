class AddCoverPhotoIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :cover_photo_id, :integer
  end
end
