class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :project_name, null: false, limt: 255
      t.text :description

      t.timestamps null: false
    end
  end
end