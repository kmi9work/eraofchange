Rails.application.routes.draw do
  get '/settlements', to: 'settlements#index'
  get '/settlements/new', to: 'settlements#new', as: :new_settlement
  post '/settlements', to: 'settlements#create'
  get '/settlements/:id', to: 'settlements#show', as: :settlement
  get '/settlements/:id/edit', to: 'settlements#edit', as: :edit_settlement
  patch '/settlements/:id', to: 'settlements#update'
  delete '/settlements/:id', to: 'settlements#destroy', as: :destroy
  

  get '/economicsubjects', to: 'economicsubjects#index'
  get '//welcome-index', to: 'welcome#index'





  root to: 'welcome#index'





end