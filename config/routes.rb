Rails.application.routes.draw do

  class OnlyAjaxRequest
    def matches?(request)
      request.xhr?
    end
  end

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

  # get 'emailaccounts/google_redirect'
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
      get :google_redirect
      get :reply
      get :get_keywords, constraint: OnlyAjaxRequest.new
    end
  end
  resources :inbox do

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
  get 'admin/accounts/:id/emailaccounts', to: 'admin#accounts_emailaccounts'
  get 'admin/emailaccounts'
  get 'admin/emailaccounts/:id', to: 'admin#emailaccount'
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
  get 'guides/email-automation', to: 'pages#guide_email_automation'
  get 'guides/customer-service-emails', to: 'pages#guide_customer_service_emails'
  get 'guides/tips-for-good-emails', to: 'pages#guide_tips_for_good_emails'
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


  get 'wizard/1', to: 'wizard#connect_account'
  get 'wizard/1/:id', to: 'wizard#connect_account'
  get 'wizard/2', to: 'wizard#view_messages'
  get 'wizard/2/:id', to: 'wizard#view_messages'
  get 'wizard/3', to: 'wizard#done'
  get 'wizard/3/:id', to: 'wizard#done'
  post 'wizard/3', to: 'wizard#done'
  post 'wizard/3/:id', to: 'wizard#done'
  patch 'wizard/skip', to: 'wizard#skip_activation'
  patch 'wizard/skip/:id', to: 'wizard#skip_activation'
  patch 'wizard/activate', to: 'wizard#activate'
  patch 'wizard/activate/:id', to: 'wizard#activate'
  put 'wizard/activate', to: 'wizard#activate'
  put 'wizard/activate/:id', to: 'wizard#activate'

end
