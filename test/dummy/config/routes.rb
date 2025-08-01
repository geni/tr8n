Rails.application.routes.draw do
  mount Tr8n::Engine => "/tr8n"

  get '/', to: 'dummy#index', as: :root
end
