Rails.application.routes.draw do
  namespace :api do
    post 'upload', to: 'uploads#upload'
    get 'list', to: 'uploads#list_backups'
    delete 'delete_backup', to: 'uploads#delete_backup'
  end
end
