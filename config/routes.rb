Rails.application.routes.draw do
  root :to => redirect('/backup')

  namespace :api do
    post 'upload', to: 'uploads#upload'
    get 'download_backup', to: 'uploads#download'
    delete 'delete_backup', to: 'uploads#delete'
    
    get 'download_file', to: 'files#download'
    delete 'delete_file', to: 'files#delete'
  end
  
  get 'backup', to: 'api/uploads#list'
  get 'list/:backup_name', to: 'api/files#list', as: 'list'
end
