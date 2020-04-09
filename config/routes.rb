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
      get :emails
      patch :connect
      put :connect
      post :connect
      delete :remove
      get :revoke_account_access
    end
  end
  resources :sessions
  resources :users

  #Fix later.
  #resources :viewer do
  #  member do
  #    get :connect_account
  #    get :view_messages
  #    get :done
  #    patch :skip_activation
  #    patch :activate
  #  end
  #end

  get 'admin/accounts'
  get 'admin/emailaccounts'
  get 'admin/replies'
  get 'admin/subscribers'
  get 'admin/late_invoices'
  get 'admin/show_invoice/:id', to: 'admin#show_invoice'

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

  get 'viewer/step1', to: 'viewer#connect_account'
  get 'viewer/step1/:id', to: 'viewer#connect_account'
  get 'viewer/step2', to: 'viewer#view_messages'
  get 'viewer/step2/:id', to: 'viewer#view_messages'
  get 'viewer/step3', to: 'viewer#done'
  get 'viewer/step3/:id', to: 'viewer#done'
  post 'viewer/step3', to: 'viewer#done'
  post 'viewer/step3/:id', to: 'viewer#done'
  patch 'viewer/skip', to: 'viewer#skip_activation'
  patch 'viewer/skip/:id', to: 'viewer#skip_activation'
  patch 'viewer/activate', to: 'viewer#activate'
  patch 'viewer/activate/:id', to: 'viewer#activate'

end
