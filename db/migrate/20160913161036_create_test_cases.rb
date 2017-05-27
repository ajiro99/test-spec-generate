class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.belongs_to :scenario, index: true, foreign_key: true
      t.integer :test_case_no, null: false
      t.string :screen_name, limt: 255
      t.text :test_content
      t.text :check_content
      t.text :description
      t.string :status

      t.timestamps null: false
    end
  end
end
