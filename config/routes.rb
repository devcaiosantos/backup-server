Rails.application.routes.draw do
  namespace :api do
    post 'upload', to: 'uploads#upload'
    get 'list', to: 'uploads#list_backups'
  end
end
