Dummy::Application.routes.draw do
  # mount at /foo to make sure the links work
  # this will also mount will_filter at /will_filter
  mount Tr8n::Engine => '/foo'

  get '/dummy/switch_user', to: 'dummy#switch_user', as: :switch_user
  get '/', to: 'dummy#index', as: :root
end
