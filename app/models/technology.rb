class Technology < ApplicationRecord
  has_many :technology_items

  RURAL_SCHOOLS = 1
  ST_GEORGE_DAY = 2
  CRAFTSMEN = 3
  TECH_SCHOOLS = 4
  GODS_ANOITED = 5
  MOSCOW_THIRD_ROME = 6
  DEV_BUREAU = 7
  OVERSEAS_TRADE = 8
  BLACKSMITHING = 9
  BALLISTICS = 10
  CANNING = 11
  FOREIGN_MERCE = 12

  def is_open
    technology_items.first&.value.to_i
  end

  def open_it
    ti = technology_items.first
    if ti
      ti.value = 1
      ti.save
    end
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
