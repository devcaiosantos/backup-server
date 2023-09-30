Rails.application.routes.draw do
  namespace :api do
    post 'upload', to: 'uploads#upload'
    get 'list', to: 'uploads#list_backups'
    delete 'delete_backup', to: 'uploads#delete_backup'

    get 'list_files/:backup_name', to: 'files#list', as: 'list_files'
  end
end
