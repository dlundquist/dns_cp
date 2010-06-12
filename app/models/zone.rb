class Zone < ActiveRecord::Base
  validates_uniqueness_of :name

  def records
  end
end
