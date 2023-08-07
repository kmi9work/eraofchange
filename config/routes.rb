Rails.application.routes.draw do
  get '/settlements', to: 'settlements#index'
  get '/settlements/new', to: 'settlements#new'
  post '/settlements/create', to: 'settlements#create'
  get '/settlements/:id', to: 'settlements#show', as: :settlement
  get '/settlements/edit/:id', to: 'settlements#edit'
  get '/settlements/destroy/:id', to: 'settlements#destroy'
  root to: 'welcome#index'
end