Rails.application.routes.draw do
  namespace :api do
    post 'upload', to: 'uploads#upload'
    get 'list', to: 'uploads#list_backups'
    delete 'delete_backup', to: 'uploads#delete_backup'
    get 'list_files/:backup_name', to: 'files#list', as: 'list_files'
    delete 'delete_file', to: 'uploads#delete_file'
    get 'download_backup', to: 'uploads#download_backup'
    get 'download_file', to: 'uploads#download_file'
  end
end
