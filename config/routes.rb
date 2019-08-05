Rails.application.routes.draw do
  get 'pages/home'
  get 'features', to: 'pages#features'
  get 'pricing', to: 'pages#pricing'
  get 'signup', to: 'pages#signup'
  get 'documentation', to: 'pages#documentation'
  get 'faq', to: 'pages#faq'
  get 'security', to: 'pages#security'
  get 'signup', to: 'pages#signup'
 
  root 'pages#home'
end

