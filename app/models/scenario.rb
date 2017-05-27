class Scenario < ActiveRecord::Base
    belongs_to :project
    has_many :test_cases, dependent: :destroy
    accepts_nested_attributes_for :test_cases
    
    validates :scenario_no, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    validates :scenario_no, uniqueness: { scope: :project_id }
    validates :scenario_name, :scenario_no, :input_scenario, presence: true
    validates :scenario_name, length: { maximum: 255 }
    validate :input_scenario_format_check
    
    def input_scenario_format_check
      rowCount = 1
      splitTest = input_scenario.split(";")
  
      splitTest.each do |testCase|
        splitTestCase = testCase.split("^")
            
        unless splitTestCase.length == 4
          if testCase.present?
            errors.add(:input_scenario, "#{rowCount}項目目：フォーマットエラー")
          end
        end
        rowCount += 1
      end
    end
end
