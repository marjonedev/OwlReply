Rails.application.routes.draw do

  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"

  resources :paymentmethods do
    member do
      patch :toggle_default
      put :toggle_default
    end
  end

  resources :subscriptions
  resources :transactions
  resources :invoices
  resources :plans
  resources :replies
  resources :emailaccounts do
    resources :replies #This will be for new and create ONLY. /emailaccounts/1/replies/2 should just be /replies/2
    member do
      patch :check_again
      put :check_again
      get :status
      patch :connect
      put :connect
      post :connect
      get :google_redirect
      get :google_callback
      get :labels
    end
  end
  resources :sessions
  resources :users

  get 'admin/accounts'
  get 'admin/emailaccounts'
  get 'admin/replies'

  root 'pages#home'

  get 'pages/home'
  get 'help', to: 'pages#help'
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
  get 'privacy-policy', to: 'pages#privacy'
  get 'terms-of-use', to: 'pages#terms'
end

