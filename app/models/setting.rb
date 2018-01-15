class ValidateDates < ActiveModel::Validator
  def validate(record)
    if record.setting_type == 'date' && !DateTime.strptime(record.value, '%m/%d/%Y %I:%M %p')
      record.errors[] << 'Invalid date'
    end
  end
end

class Setting < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :setting_type, presence: true, length: { maximum: 255 }
  validates_with ValidateDates
end
