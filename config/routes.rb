Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Landing page — served on root domain (slsh.me)
  root "pages#landing"

  # Auth
  resource  :session
  resources :passwords, param: :token
  resource  :registration, only: %i[new create]

  # Dashboard (authenticated)
  resource :settings, only: [] do
    get :profile, action: :profile
    patch :profile, action: :update_profile
    get :domains, action: :domains
  end
  resources :custom_domains, only: %i[create destroy] do
    member { post :check }
  end
  resources :campaigns, only: %i[show create destroy]
  resources :links, except: [ :show ] do
    member do
      get  :analytics
      get  :qr
    end
    collection do
      get :check_slug
      post :fetch_og
    end
  end

  # Public redirects — /l/ prefix on primary domain
  post "/l/:slug/unlock", to: "redirects#unlock", as: :unlock_redirect
  get  "/l/:slug",        to: "redirects#show",   as: :redirect

  # Custom domain redirects — slug at root
  post "/:slug/unlock", to: "redirects#unlock", as: :unlock_custom_redirect
  get  "/:slug",        to: "redirects#show",   as: :custom_redirect
end
