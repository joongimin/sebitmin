class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.string :sub_title
      t.string :description
      t.string :detail
      t.integer :project_type

      t.timestamps
    end
  end
end
