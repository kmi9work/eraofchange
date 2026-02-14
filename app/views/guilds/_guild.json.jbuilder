json.extract! guild, :id, :name, :created_at, :updated_at
json.icon guild.respond_to?(:icon) ? guild.icon : nil
json.icon_url "/images/guilds/#{guild.id}.png"
json.player_ids guild.player_ids
json.players guild.players.order(:name), partial: "players/player", as: :player
json.plants guild.plants.includes(:plant_level => {:plant_type => :plant_category}) do |plant|
  json.id plant.id
  json.plant_level do
    json.id plant.plant_level&.id
    json.level plant.plant_level&.level
    json.formulas plant.plant_level&.formulas
    json.formula_conversion plant.plant_level&.formula_conversion
    json.plant_type do
      pt = plant.plant_level&.plant_type
      if pt
        json.id pt.id
        json.name pt.name
        json.icon pt.respond_to?(:icon) ? pt.icon : nil
        json.icon_url "/images/plant_types/#{pt.id}.png"
        json.plant_category do
          pc = pt.plant_category
          if pc
            json.id pc.id
            json.name pc.name
            json.is_extractive pc.is_extractive
            json.icon pc.respond_to?(:icon) ? pc.icon : nil
            json.icon_url "/images/plant_categories/#{pc.id}.png"
          else
            json.nil!
          end
        end
      else
        json.nil!
      end
    end
  end
end
json.url guild_url(guild, format: :json)
