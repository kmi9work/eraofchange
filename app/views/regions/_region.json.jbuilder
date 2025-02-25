json.extract! region, :id, :title, :params, :country, :player, :inf_buildings_on_po, :created_at, :updated_at
json.capital do 
  json.partial! "settlements/settlement", settlement: region.capital
end
json.url region_url(region, format: :json)
