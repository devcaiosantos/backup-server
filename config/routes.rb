Rails.application.routes.draw do
  namespace :api do
    post 'upload', to: 'uploads#upload'
  end
end
