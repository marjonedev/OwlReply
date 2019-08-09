Rails.application.routes.draw do
  resources :users
  get 'pages/home'
  get 'features', to: 'pages#features'
  get 'pricing', to: 'pages#pricing'
  get 'signup', to: 'pages#signup'
  get 'documentation', to: 'pages#documentation'
  get 'faqs', to: 'pages#faqs'
  get 'security', to: 'pages#security'
  get 'signup', to: 'users#new'

  get 'users/new'
 
  root 'pages#home'
end

