VassalsAndRobbers::Engine.routes.draw do
  get 'checklists', to: 'checklists#index', defaults: { format: :json }
  post 'checklists/:id/establish_vassalage', to: 'checklists#establish_vassalage', defaults: { format: :json }
  post 'checklists/:id/remove_vassalage', to: 'checklists#remove_vassalage', defaults: { format: :json }
end

