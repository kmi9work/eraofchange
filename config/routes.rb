Rails.application.routes.draw do
  get '/settlements', to: 'settlements#index'
  get '/settlements/new', to: 'settlements#new', as: :new_settlement
  post '/settlements', to: 'settlements#create'
  get '/settlements/:id', to: 'settlements#show', as: :settlement
  get '/settlements/:id/edit', to: 'settlements#edit', as: :edit_settlement
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


  root to: 'welcome#index'
end
