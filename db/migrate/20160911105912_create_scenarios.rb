class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.references :project, index: true, foreign_key: true
      t.string :scenario_name, null: false, limt: 255
      t.integer :scenario_no, null: false
      t.text :description
      t.integer :count_item, default: 0
      t.integer :count_item_target, default: 0
      t.integer :count_remaining, default: 0
      t.integer :count_ok, default: 0
      t.integer :count_ng, default: 0
      t.text :input_scenario, null: false

      t.timestamps null: false
    end
  end
end
