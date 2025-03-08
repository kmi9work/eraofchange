class Technology < ApplicationRecord
  has_many :technology_items
  def is_open
    self.params['opened']
  end

  def open_it
    self.params['opened'] = 1
    self.save
  end

  def close_it
    self.params['opened'] = 0
    self.save
  end

  def self.opened
    Technology.all.map{|it| it.params['opened'] == 1}
  end

  def self.closed
    Technology.all.map{|it| it.params['closed'] == 1}
  end
end
