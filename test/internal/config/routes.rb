Rails.application.routes.draw do
  resources :users, only: [:index]
  get "exclude", to: "users#exclude"
  get "upgrade_memberships_when_duplicate", to: "users#upgrade_memberships_when_duplicate"
end
