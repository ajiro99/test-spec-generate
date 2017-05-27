class Project < ActiveRecord::Base
    has_many :scenarios, dependent: :destroy
    validates :project_name, presence: true
    validates :project_name, length: { maximum: 255 }
end
