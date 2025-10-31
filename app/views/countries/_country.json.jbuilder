json.extract! country, :id, :name, :embargo, :params, :relations, :created_at, :updated_at
json.owner_type 'Country'
json.relation_points (country.params&.dig('relation_points') || 0)
json.alliances_enabled Country.alliances_enabled

relation_items = []
if Technology.find(Technology::MOSCOW_THIRD_ROME).is_open == 1 && 
  [Country::PERMIAN, Country::VYATKA, Country::RYAZAN, Country::TVER, Country::NOVGOROD].include?(country.id)
  relation_items << RelationItem.new(
    id: 0,
    value: country.class.moscow_third_rome_bonus,
    comment: 'Технология помазанник божий',
    country: country
  )
end

relation_items += country.relation_items

json.relation_items relation_items.reverse, partial: "relation_items/relation_item", as: :relation_item

if Country.alliances_enabled
  # Для иностранных стран показываем союзы Руси (id=1) с этой страной
  # Для Руси показываем все её союзы
  if country.id == Country::RUS
    alliances_list = country.alliances.includes(:partner_country, :alliance_type)
  else
    rus_alliances = Country.find_by_id(Country::RUS)&.alliances&.includes(:partner_country, :alliance_type) || []
    alliances_list = rus_alliances.select { |a| a.partner_country_id == country.id }
  end
  
  json.alliances alliances_list do |alliance|
    json.id alliance.id
    json.partner_country do
      json.id alliance.partner_country.id
      json.name alliance.partner_country.name
    end
    json.alliance_type do
      json.id alliance.alliance_type.id
      json.name alliance.alliance_type.name
      json.min_relations_level alliance.alliance_type.min_relations_level
    end
  end
else
  json.alliances []
end

json.url country_url(country, format: :json)
