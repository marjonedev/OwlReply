Rails.application.routes.draw do

  get 'errors/not_found'
  get 'errors/unacceptable'
  get 'errors/internal_error'
  resources :users
  resources :sessions

  root 'pages#home'

  get 'pages/home'
  get 'features', to: 'pages#features'
  get 'pricing', to: 'pages#pricing'
  get 'documentation', to: 'pages#documentation'
  get 'faqs', to: 'pages#faqs'
  get 'security', to: 'pages#security'
  get 'signup' => 'users#new', :as => "signup"
  get 'users/index'
  get 'login' => 'sessions#new', :as => "login"
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy', :as => "logout"

end

