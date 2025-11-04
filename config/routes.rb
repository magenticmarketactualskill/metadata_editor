Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "editor#index"

  # Editor routes
  post 'editor/analyze_folder', to: 'editor#analyze_folder'
  get 'editor/folder_tree', to: 'editor#folder_tree'
  get 'editor/file_content', to: 'editor#file_content'
  get 'editor/file_metadata', to: 'editor#file_metadata'
  post 'editor/update_file', to: 'editor#update_file'
  post 'editor/update_metadata', to: 'editor#update_metadata'
  get 'editor/all_metadata', to: 'editor#all_metadata'
end
