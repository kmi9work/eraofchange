json.extract! guild, :id, :name, :created_at, :updated_at
json.players guild.players.order(:name), partial: "players/player", as: :player
json.plants guild.plants.includes(:plant_level => {:plant_type => :plant_category}) do |plant|
  json.id plant.id
  json.plant_level do
    json.id plant.plant_level&.id
    json.level plant.plant_level&.level
    json.formulas plant.plant_level&.formulas
    json.formula_conversion plant.plant_level&.formula_conversion
    json.plant_type do
      json.id plant.plant_level&.plant_type&.id
      json.name plant.plant_level&.plant_type&.name
      json.plant_category do
        json.id plant.plant_level&.plant_type&.plant_category&.id
        json.name plant.plant_level&.plant_type&.plant_category&.name
      end
    end
  end
end
json.url guild_url(guild, format: :json)
