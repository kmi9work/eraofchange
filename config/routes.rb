Rails.application.routes.draw do

  patch '/game_parameters/pay_state_expenses', to: 'game_parameters#pay_state_expenses'
  patch '/game_parameters/increase_year', to: 'game_parameters#increase_year'

  patch '/armies/:id/demote_army', to: 'armies#demote_army'
  patch '/armies/:id/pay_for_army', to: 'armies#pay_for_army'

  patch '/regions/:id/modify_public_order', to: 'regions#modify_public_order'
  patch '/regions/:id/captured_by', to: 'regions#captured_by'

  patch '/countries/:id/embargo', to: 'countries#embargo'
  patch '/countries/:id/capture', to: 'countries#capture'
  patch '/countries/:id/change_relations',   to: 'countries#change_relations'

  patch '/buildings/:id/upgrade', to: 'buildings#upgrade'
  patch '/buildings/:id/pay_for_maintenance', to: 'buildings#pay_for_maintenance'

  get '/plant_levels/:id/feed_to_plant', to: 'plant_levels#feed_to_plant'

  get '/resources/show_prices',  to: 'resources#show_prices'
  get '/resources/send_caravan', to: 'resources#send_caravan'

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
  delete '/plants/:id/destroy', to: 'plants#destroy', as: :destroy_plant
  patch '/plants/:id/upgrade', to: 'plants#upgrade', as: :upgrade_plant

  resources :game_parameters
  resources :credits
  resources :troops
  resources :resources
  resources :plant_types
  resources :plant_categories
  resources :settlement_types
  resources :guilds
  resources :merchants
  resources :families
  resources :players
  resources :countries
  resources :armies
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
  resources :ideologist_technologies
  resources :political_actions
  resources :political_action_types

  root to: 'welcome#index'
end
