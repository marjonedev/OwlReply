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

  get 'emailaccounts/google_redirect'
  get 'emailaccounts/google_callback'
  resources :emailaccounts do
    resources :replies #This will be for new and create ONLY. /emailaccounts/1/replies/2 should just be /replies/2
    member do
      patch :check_again
      put :check_again
      get :authenticate_imap
      get :status
      patch :connect
      put :connect
      post :connect
      delete :remove
      get :revoke_account_access
    end
  end
  resources :sessions
  resources :users
  resources :email_viewer do
    member do
      get :connect_account
      get :view_messages
      get :done
      patch :skip_activation
      patch :activate
    end
  end

  get 'admin/accounts'
  get 'admin/emailaccounts'
  get 'admin/replies'
  get 'admin/subscribers'

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

  get 'forgot_password', to: 'pages#forgot_password'

  get 'password/reset', to: 'passwords#reset'
  post 'password/forgot', to: 'passwords#forgot'
  post 'password/reset_submit', to: 'passwords#reset_submit'

  get 'email_viewer/step1', to: 'email_viewer#connect_account'
  get 'email_viewer/step2', to: 'email_viewer#view_messages'
  get 'email_viewer/step3', to: 'email_viewer#done'
  patch 'email_viewer/skip', to: 'email_viewer#skip_activation'
  patch 'email_viewer/activate', to: 'email_viewer#activate'

end

