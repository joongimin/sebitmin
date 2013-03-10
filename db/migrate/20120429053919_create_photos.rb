class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :url
      t.string :key
      t.string :thumbnail_url_small
      t.string :thumbnail_key_small
      t.string :imageable_type
      t.integer :imageable_id

      t.timestamps
    end
  end
end
