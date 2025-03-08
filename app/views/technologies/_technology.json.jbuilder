json.extract! technology, :id, :name, :description, :is_open, :params, :created_at, :updated_at

technology_items = [
  TechnologyItem.new(
    id: 0,
    value: nil,
    comment: technology.description  
  ),
  *technology.technology_items
]

json.technology_items technology_items.reverse, partial: "technology_items/technology_item", as: :technology_item
json.url technology_url(technology, format: :json)
