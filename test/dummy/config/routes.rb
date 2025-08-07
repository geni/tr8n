Rails.application.routes.draw do
  # mount at /foo to make sure the links work
  mount Tr8n::Engine => '/foo'

  get '/dummy/switch_user', to: 'dummy#switch_user', as: :switch_user

  get '/', to: 'dummy#index', as: :root
end
