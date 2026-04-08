Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Auth (from authentication generator)
  resource  :session
  resources :passwords, param: :token

  # Registrations
  resource :registration, only: %i[new create]

  # Authenticated
  root "links#index"
  resources :links, except: [:show] do
    member do
      get  :analytics
      get  :qr
    end
    collection do
      get :check_slug
    end
  end

  # Public redirect — must come last
  post "/:slug/unlock", to: "redirects#unlock", as: :unlock_redirect
  get  "/:slug",        to: "redirects#show",   as: :redirect
end
