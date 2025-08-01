Rails.application.routes.draw do
  mount Tr8n::Engine => "/tr8n"

  get '/dummy/switch_user', to: 'dummy#switch_user', as: :switch_user

  get '/', to: 'dummy#index', as: :root
end
