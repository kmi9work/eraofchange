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

  # Факт открытия технологии — на государство (одна строка technology_items на пару
  # «технология × государство»). Все читатели получают дефолт «текущее государство»,
  # поэтому при игре за одну страну поведение прежнее.
  def item_for(country = Country.current)
    country_id = country&.id
    return technology_items.find_by(country_id: nil) if country_id.nil?

    item = technology_items.find_by(country_id: country_id)
    return item if item

    # Легаси-строка без страны (до бэкфилла) относится к «Руси»
    country_id.to_i == Country::RUS ? technology_items.find_by(country_id: nil) : nil
  end

  # Элементы технологии в разрезе государства (без страны — legacy-элементы)
  def items_for(country = Country.current)
    country_id = country&.id
    return technology_items.where(country_id: nil) if country_id.nil?

    technology_items.where(country_id: country_id)
  end

  def is_open(country = Country.current)
    item_for(country)&.value.to_i
  end

  def open_it(country = Country.current)
    ti = item_for(country)
    if ti
      ti.value = 1
      ti.save
    end
  end

  def close_it(country = Country.current)
    ti = item_for(country)
    if ti
      ti.value = 0
      ti.save
    end
  end
end
