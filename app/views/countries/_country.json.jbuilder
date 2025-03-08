json.extract! country, :id, :name, :params, :relations, :created_at, :updated_at

json.relation_items country.relation_items.reverse, partial: "relation_items/relation_item", as: :relation_item

json.url country_url(country, format: :json)
