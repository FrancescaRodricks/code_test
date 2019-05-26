Rails.application.routes.draw do
  root 'leads#new'
  match 'leads', controller: 'leads', action: 'new', via: [:get]
  resources :leads, only: [:create]
end
