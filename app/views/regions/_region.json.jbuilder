json.extract! region, :id, :name, :params, :country, :player, :inf_buildings_on_po, :show_overall_po, :created_at, :updated_at
json.capital do
  if region.capital.present?
    json.partial! "settlements/settlement", settlement: region.capital
  end
end

public_order_items = [
  PublicOrderItem.new(
    id: 0,
    value: region.inf_buildings_on_po,
    comment: 'Влияние зданий',
    region: region
  ),
  PublicOrderItem.new(
    id: 0,
    value: (Technology.find(Technology::GODS_ANOITED).is_open == 1 ? 5 : 0),
    comment: 'Технология помазанник божий',
    region: region
  ),
  *region.public_order_items
]

json.public_order_items public_order_items.reverse do |poi|
  json.id poi.id
  json.value poi.value
  json.comment poi.comment
  json.year poi.year
  json.region poi.region
  json.entity poi.entity
end 
json.url region_url(region, format: :json)
