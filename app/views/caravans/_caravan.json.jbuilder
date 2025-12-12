json.extract! caravan, :id, :year, :resources_export, :resources_import, :gold_export, :gold_import, :via_vyatka, :created_at, :updated_at

if caravan.guild
  json.guild_name caravan.guild.name
else
  json.guild_name nil
end

if caravan.country
  json.country_name caravan.country.name
else
  json.country_name nil
end
