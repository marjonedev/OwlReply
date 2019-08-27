Rails.application.routes.draw do

  resources :subscriptions
  resources :transactions
  resources :invoices
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"

  resources :plans
  resources :replies
  resources :emailaccounts do
    resources :replies #This will be for new and create ONLY. /emailaccounts/1/replies/2 should just be /replies/2
  end
  resources :sessions
  resources :users

  current_user do
    root 'emailaccounts#index', as: :authenticated
  end
  root 'pages#home'
  #root 'pages#home'

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

