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
  resources :custom_domains, only: %i[index create destroy] do
    member { post :check }
  end
  resources :links, except: [ :show ] do
    member do
      get  :analytics
      get  :qr
    end
    collection do
      get :check_slug
    end
  end

  # Public redirects — /l/ prefix on primary domain
  post "/l/:slug/unlock", to: "redirects#unlock", as: :unlock_redirect
  get  "/l/:slug",        to: "redirects#show",   as: :redirect

  # Custom domain redirects — slug at root
  post "/:slug/unlock", to: "redirects#unlock", as: :unlock_custom_redirect
  get  "/:slug",        to: "redirects#show",   as: :custom_redirect
end
