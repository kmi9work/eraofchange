Rails.application.routes.draw do
  
  # Аутентификация
  post '/auth/login', to: 'auth#login'
  post '/auth/logout', to: 'auth#logout'
  get '/auth/current_player', to: 'auth#current_player'
  get '/auth/generate_qr/:id', to: 'auth#generate_qr'
  
  # QR-коды для печати
  get '/qr_codes', to: 'qr_codes#index'
  
  resources :public_order_items
  resources :technology_items
  resources :relation_items
  resources :influence_items
  
  # Кастомные маршруты для караванов должны быть ДО resources
  get '/caravans/check_robbery', to: 'caravans#check_robbery'
  get '/caravans/check_robbery_with_decide', to: 'caravans#check_robbery_with_decide'
  post '/caravans/register_caravan', to: 'caravans#register_caravan'
  resources :caravans

  patch '/troops/:id/pay_for', to: 'troops#pay_for'
  patch '/troops/:id/upgrade', to: 'troops#upgrade'
  get '/troop_types/upgrade_paths', to: 'troop_types#upgrade_paths'


  ### мобильная
  get '/players/:id/show_players_resources', to: 'players#show_players_resources'
  post '/players/:id/exchange_resources', to: 'players#exchange_resources'
  post '/players/:id/receive_from_masters', to: 'players#receive_from_masters'
  post '/players/:id/buy_and_sell_res', to: 'players#buy_and_sell_res'

  ###
  patch '/players/:id/add_influence', to: 'players#add_influence'

  get '/plants/:id/name_of_plant', to: 'plants#name_of_plant'
  patch '/plants/:id/upgrade', to: 'plants#upgrade'
  get '/plants/:id/has_produced', to: 'plants#has_produced'
  post '/plants/:id/print_barcode', to: 'plants#print_barcode'

  ### Результаты
  get   '/game_parameters/show_sorted_results', to: 'game_parameters#show_sorted_results'
  get   '/game_parameters/show_noble_results', to: 'game_parameters#show_noble_results'
  patch '/game_parameters/save_sorted_results', to: 'game_parameters#save_sorted_results'
  patch '/game_parameters/clear_results',       to: 'game_parameters#clear_results'
  patch '/game_parameters/update_results',      to: 'game_parameters#update_results'
  patch '/game_parameters/delete_result',       to: 'game_parameters#delete_result'

  get   '/game_parameters/display_results', to: 'game_parameters#display_results'
  get   '/game_parameters/screen_bundle', to: 'game_parameters#screen_bundle'
  patch '/game_parameters/change_results_display', to: 'game_parameters#change_results_display'

  ###Таймер и расписание
  get   '/game_parameters/show_schedule', to: 'game_parameters#show_schedule'
  patch '/game_parameters/create_schedule', to: 'game_parameters#create_schedule'
  patch '/game_parameters/add_schedule_item', to: 'game_parameters#add_schedule_item'
  patch '/game_parameters/update_schedule_item', to: 'game_parameters#update_schedule_item'
  patch '/game_parameters/delete_schedule_item', to: 'game_parameters#delete_schedule_item'
  patch   '/game_parameters/toggle_timer', to: 'game_parameters#toggle_timer'

  ###Экран
  get   '/game_parameters/get_screen', to: 'game_parameters#get_screen'
  patch '/game_parameters/toggle_screen', to: 'game_parameters#toggle_screen'

  
  patch '/game_parameters/pay_state_expenses', to: 'game_parameters#pay_state_expenses'
  patch '/game_parameters/unpay_state_expenses', to: 'game_parameters#unpay_state_expenses'
  patch '/game_parameters/increase_year', to: 'game_parameters#increase_year'
  get '/game_parameters/plugin_status', to: 'game_parameters#plugin_status'
  
  ###Настройки
  get '/game_parameters/get_years_count', to: 'game_parameters#get_years_count'
  patch '/game_parameters/update_years_count', to: 'game_parameters#update_years_count'
  get '/game_parameters/get_caravan_robbery_settings', to: 'game_parameters#get_caravan_robbery_settings'
  patch '/game_parameters/update_caravan_robbery_settings', to: 'game_parameters#update_caravan_robbery_settings'
  get '/game_parameters/get_caravans_per_guild', to: 'game_parameters#get_caravans_per_guild'
  patch '/game_parameters/update_caravans_per_guild', to: 'game_parameters#update_caravans_per_guild'
  get '/game_parameters/get_robbery_stats', to: 'game_parameters#get_robbery_stats'
  get '/game_parameters/get_vassalage_settings', to: 'game_parameters#get_vassalage_settings'
  patch '/game_parameters/update_vassalage_settings', to: 'game_parameters#update_vassalage_settings'
  get '/game_parameters/get_active_lingering_effects', to: 'game_parameters#get_active_lingering_effects'



  patch '/armies/:id/demote_army', to: 'armies#demote_army'
  patch '/armies/:id/pay_for_army', to: 'armies#pay_for_army'
  patch '/armies/:id/goto/:settlement_id', to: 'armies#goto'
  patch '/armies/:id/attack/:enemy_id', to: 'armies#attack'
  post '/armies/:id/troops', to: 'armies#add_troop'
  
  patch '/regions/:id/add_po_item', to: 'regions#add_po_item'
  patch '/regions/:id/captured_by', to: 'regions#captured_by'

  patch '/countries/:id/set_embargo', to: 'countries#set_embargo'
  patch '/countries/:id/capture/:region_id', to: 'countries#capture'
  patch '/countries/:id/add_relation_item',   to: 'countries#add_relation_item'
  patch '/countries/:id/improve_relations_via_trade', to: 'countries#improve_relations_via_trade'
  patch '/countries/:id/join_peace',   to: 'countries#join_peace'
  get '/countries/foreign_countries', to: 'countries#foreign_countries'
  get '/countries/show_trade_turnover', to: 'countries#show_trade_turnover'
  get '/countries/:id/calculate_trade_turnover', to: 'countries#calculate_trade_turnover'
  get '/countries/:id/show_current_trade_level', to: 'countries#show_current_trade_level'
  get '/countries/:id/show_trade_thresholds', to: 'countries#show_trade_thresholds'
  get '/countries/trade_levels_and_thresholds', to: 'countries#trade_levels_and_thresholds'
  patch '/countries/:id/update_trade_thresholds', to: 'countries#update_trade_thresholds'
  get '/countries/:country_id/alliances', to: 'alliances#index'
  post '/alliances', to: 'alliances#create'
  delete '/alliances/:id', to: 'alliances#destroy'

  patch '/buildings/:id/upgrade', to: 'buildings#upgrade'
  patch '/buildings/:id/pay_for_maintenance', to: 'buildings#pay_for_maintenance'

  get '/plant_levels/prod_info', to: 'plant_levels#prod_info'
  get '/plant_levels/prod_info_full', to: 'plant_levels#prod_info_full'
  post '/plant_levels/:id/feed_to_plant', to: 'plant_levels#feed_to_plant'

  get '/plant_places/available_places', to: 'plant_places#available_places'

  get '/resources/show_prices',  to: 'resources#show_prices'
  get '/resources/show_all_resources',  to: 'resources#show_all_resources'
  post '/resources/send_caravan', to: 'resources#send_caravan'

  

  #TODO Населенный пункт надо бы сделать тоже через ресурс.
  get '/settlements', to: 'settlements#index'
  get '/settlements/new', to: 'settlements#new', as: :new_settlement
  post '/settlements', to: 'settlements#create'
  get '/settlements/:id', to: 'settlements#show', as: :settlement
  get '/settlements/:id/edit', to: 'settlements#edit', as: :edit_settlement
  post '/settlements/:id/build', to: 'settlements#build'
  patch '/settlements/:id/pay_for_church', to: 'settlements#pay_for_church'
  patch '/settlements/:id', to: 'settlements#update'

  delete '/settlements/:id', to: 'settlements#destroy', as: :destroy
  
  get '/economic_subjects', to: 'economic_subjects#index'
  get '/economic_subjects/new', to: 'economic_subjects#new', as: :new_economic_subject
  post '/economic_subjects', to: 'economic_subjects#create'
  get '/economic_subjects/:id', to: 'economic_subjects#show', as: :economic_subject
  get '/economic_subjects/:id/edit', to: 'economic_subjects#edit', as: :edit_economic_subject
  patch '/economic_subjects/:id', to: 'economic_subjects#update'
  delete '/economic_subjects/:id', to: 'economic_subjects#destroy', as: :destroy_economic_subject
  
  get '/settles', to: 'settles#index'
  get '/settles/new', to: 'settles#new', as: :new_settle
  post '/settles', to: 'settles#create'
  get '/settles/:id', to: 'settles#show', as: :settle
  get '/settles/:id/edit', to: 'settles#edit', as: :edit_settle
  patch '/settles/:id', to: 'settles#update'
  delete '/settles/:id', to: 'settles#destroy', as: :destroy_settle

  get '/eco_subjects', to: 'eco_subjects#index'
  get '/eco_subjects/new', to: 'eco_subjects#new', as: :new_eco_subject
  post '/eco_subjects', to: 'eco_subjects#create'
  get '/eco_subjects/:id', to: 'eco_subjects#show', as: :eco_subject
  get '/eco_subjects/:id/edit', to: 'eco_subjects#edit', as: :edit_eco_subject
  patch '/eco_subjects/:id', to: 'eco_subjects#update'
  delete '/eco_subjects/:id', to: 'eco_subjects#destroy', as: :destroy_eco_subject
  

  get '/facilities', to: 'facilities#index'
  get '/facilities/new', to: 'facilities#new', as: :new_facility
  post '/facilities', to: 'facilities#create'
  get '/facilities/:id', to: 'facilities#show', as: :facility
  get '/facilities/:id/edit', to: 'facilities#edit', as: :edit_facility
  get '/facilities/:id/destroy', to: 'facilities#destroy', as: :destroy_facility
  patch '/facilities/:id', to: 'facilities#update'

  get '/plants', to: 'plants#index'
  get '/plants/new', to: "plants#new", as: :new_plant
  post '/plants', to: 'plants#create'
  get '/plants/:id', to: 'plants#show', as: :plant
  get '/plants/:id/edit', to: 'plants#edit', as: :edit_plant
  patch '/plants/:id', to: 'plants#update'
  delete '/plants/:id', to: 'plants#destroy', as: :destroy_plant
  patch '/plants/:id/upgrade', to: 'plants#upgrade', as: :upgrade_plant

  get '/login/:id', to: 'users#login'
  get '/current_user', to: 'users#current_user'

  get '/audits', to: 'audits#index'
  post '/audits/mark_as_viewed', to: 'audits#mark_as_viewed'
  post '/audits/mark_all_as_viewed', to: 'audits#mark_all_as_viewed'
  get '/audits/yearly_stats', to: 'audits#yearly_stats'
  get '/audits/detailed_yearly_stats', to: 'audits#detailed_yearly_stats'


  resources :game_parameters
  resources :users
  resources :credits
  resources :troops
  resources :resources
  resources :plant_types
  resources :plant_categories
  resources :settlement_types
  # Специальный список гильдий должен идти раньше resources, чтобы не совпадать с :id
  get '/guilds/list', to: 'guilds#list'
  patch '/guilds/:id/assign_players', to: 'guilds#assign_players'
  resources :guilds
  resources :merchants
  resources :families
  resources :players
  resources :countries
  resources :armies do
    member do
      patch :unlease
    end
  end
  resources :army_sizes
  resources :troop_types
  resources :plant_places
  resources :fossil_types
  resources :regions
  resources :buildings
  resources :building_levels
  resources :building_types
  resources :building_places
  resources :plant_levels
  resources :jobs
  resources :humen
  resources :player_types
  resources :ideologist_types
  resources :technologies
  resources :political_actions
  resources :political_action_types
  resources :alliance_types

  # Game engines
  mount VassalsAndRobbers::Engine, at: '/vassals_and_robbers'

  root to: 'welcome#index'
end
