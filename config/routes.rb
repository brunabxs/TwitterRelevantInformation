Rails.application.routes.draw do
  get 'tweets/list'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'tweets#list'
end
