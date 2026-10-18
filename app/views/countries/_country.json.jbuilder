json.extract! country, :id, :name, :short_name, :flag_image_name, :embargo, :params, :created_at, :updated_at
# Торгует ли государство на рынке (есть товары с ценами) — по этому признаку
# эмбарго на гильдии доступно только торгующим странам.
json.trades_on_market country.trades_on_market?
json.owner_type 'Country'

# Отношения показываются в паре с текущим государством (прежний смысл «со своей страной»).
# Для самой текущей страны пара не определена — остаётся сумма её собственных элементов.
# Партнёра можно передать явно (партиал используется Дашбордом для пары «A ↔ B», ТЗ № 2, § 2.3).
partner = local_assigns.key?(:partner_country) ? local_assigns[:partner_country] : Country.current
pair_partner = partner && partner.id == country.id ? nil : partner

json.relations country.relations(partner)
# Значения отношений со всеми остальными государствами: { "<id>" => значение }
json.relations_by_country Country.where.not(id: country.id).order(:id).map { |other|
  [other.id.to_s, country.relations_with(other)]
}.to_h
json.current_country_id partner&.id
json.relation_partner_id partner&.id
# Партнёр пары (для Дашборда): государство A строки таблицы отношений
json.relation_partner do
  if partner
    json.extract! partner, :id, :name, :short_name, :flag_image_name
  end
end
json.relation_points country.relation_points_for(partner)
json.alliances_enabled Country.alliances_enabled

relation_items = []
if Technology.find(Technology::MOSCOW_THIRD_ROME).is_open(Country.rus_country) == 1 &&
  Country::THIRD_ROME_BONUS_COUNTRIES.include?(country.id)
  relation_items << RelationItem.new(
    id: 0,
    value: country.class.moscow_third_rome_bonus,
    comment: 'Технология помазанник божий',
    country: country,
    partner_country: partner
  )
end

# Элементы пары «текущее государство ↔ эта страна»; для текущей страны — её собственные
relation_items += pair_partner.nil? ? country.relation_items : country.relation_items_with(pair_partner)

json.relation_items relation_items.reverse, partial: "relation_items/relation_item", as: :relation_item

if Country.alliances_enabled
  # Союзы текущего государства с этой страной (союз считается парой стран)
  if pair_partner.nil?
    alliances_list = country.alliances.includes(:partner_country, :alliance_type)
  else
    own = country.alliances.includes(:partner_country, :alliance_type)
                 .select { |a| a.partner_country_id == pair_partner.id }
    reverse = pair_partner.alliances.includes(:partner_country, :alliance_type)
                          .select { |a| a.partner_country_id == country.id }
    alliances_list = own + reverse
  end

  json.alliances alliances_list do |alliance|
    json.id alliance.id
    json.partner_country do
      json.id alliance.partner_country.id
      json.name alliance.partner_country.name
      json.short_name alliance.partner_country.short_name
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

json.resources country.resources do |resource|
  json.identificator resource.identificator
  json.name resource.name
  json.icon resource.icon
end

json.url country_url(country, format: :json)
