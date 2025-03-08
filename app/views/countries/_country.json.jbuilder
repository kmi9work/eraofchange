json.extract! country, :id, :name, :params, :relations, :created_at, :updated_at

relation_items = [
  RelationItem.new(
    id: 0,
    value: country.params['relations'],
    comment: 'Ручная правка',
    country: country),
  *country.relation_items
].reverse

json.relation_items relation_items, partial: "relation_items/relation_item", as: :relation_item

json.url country_url(country, format: :json)
