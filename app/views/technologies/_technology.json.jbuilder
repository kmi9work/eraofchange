# Технология в разрезе государства (@technologies_country — государство запроса, иначе текущее):
# статус открытия и элементы — этого государства (Д5).
country = @technologies_country || Country.current

json.extract! technology, :id, :name, :description, :params, :created_at, :updated_at
json.is_open technology.is_open(country)
json.country_id country&.id

technology_items = [
  TechnologyItem.new(
    id: 0,
    value: nil,
    comment: technology.description,
    country_id: country&.id
  ),
  *technology.items_for(country)
]

json.technology_items technology_items.reverse, partial: "technology_items/technology_item", as: :technology_item
json.url technology_url(technology, format: :json)
