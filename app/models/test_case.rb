class TestCase < ActiveRecord::Base
    belongs_to :scenario
    
    validates :test_case_no, presence: true
    validates :screen_name, length: { maximum: 255 }
    validates :status, length: { is: 1 }, allow_blank: true
end
