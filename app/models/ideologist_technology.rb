class IdeologistTechnology < ApplicationRecord
  belongs_to :job

  def open_it
    self.params['opened'] = 1
    self.save
  end

  def close_it
    self.params['opened'] = 0
    self.save
  end

  def self.opened
    IdeologistTechnology.all.map{|it| it.params['opened'] == 1}
  end

  def self.closed
    IdeologistTechnology.all.map{|it| it.params['closed'] == 1}
  end
end
