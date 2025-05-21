json.extract! country, :id, :name, :embargo, :params, :relations, :created_at, :updated_at
json.owner_type 'Country'

relation_items = []
if Technology.find(Technology::MOSCOW_THIRD_ROME).is_open == 1 && 
  [Country::PERMIAN, Country::VYATKA, Country::RYAZAN, Country::TVER, Country::NOVGOROD].include?(country.id)
  relation_items << RelationItem.new(
    id: 0,
    value: 2,
    comment: 'Технология помазанник божий',
    country: country
  )
end

relation_items += country.relation_items

json.relation_items relation_items.reverse, partial: "relation_items/relation_item", as: :relation_item

json.url country_url(country, format: :json)
