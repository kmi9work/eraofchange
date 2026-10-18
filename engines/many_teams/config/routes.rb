ManyTeams::Engine.routes.draw do
  get   "player_countries",       to: "player_countries#index"
  patch "player_countries",       to: "player_countries#update"

  get   "extraction_permissions", to: "extraction_permissions#index"
  patch "extraction_permissions", to: "extraction_permissions#update"
  post  "extraction_permissions", to: "extraction_permissions#update"

  get    "guild_embargoes",             to: "guild_embargoes#index"
  get    "guild_embargoes/market",      to: "guild_embargoes#market"
  get    "guild_embargoes/lift_all_availability", to: "guild_embargoes#lift_all_availability"
  post   "guild_embargoes",             to: "guild_embargoes#create"
  delete "guild_embargoes",             to: "guild_embargoes#destroy"
  post   "guild_embargoes/impose_all",  to: "guild_embargoes#impose_all"
  post   "guild_embargoes/lift_all",    to: "guild_embargoes#lift_all"
  post   "guild_embargoes/lift_all_for_country", to: "guild_embargoes#lift_all_for_country"

  get "guilds/:guild_id/workshop", to: "guild_workshop#show"
  get "intelligence/targets",      to: "intelligence#targets"
end
