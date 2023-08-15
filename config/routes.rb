Rails.application.routes.draw do
  get '/settlements', to: 'settlements#index'
  get '/settlements/new', to: 'settlements#new', as: :new_settlement
  post '/settlements', to: 'settlements#create'
  get '/settlements/destroy/:id', to: 'settlements#destroy', as: :destroy
  get '/settlements/:id', to: 'settlements#show', as: :settlement
  get '/settlements/edit/:id/', to: 'settlements#edit', as: :edit_settlement
  patch '/settlements/:id', to: 'settlements#update'
  
  root to: 'welcome#index'
end