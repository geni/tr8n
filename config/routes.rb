Tr8n::Engine.routes.draw do

  [:awards, :chart, :forum, :glossary, :help, :language_cases,
   :language, :phrases, :translations, :translator, :home, :login
  ].each do |ctrl|
    get "/#{ctrl}/:action", :to => "#{ctrl}##{action}"
  end

  [:chart, :clientsdk, :forum, :glossary, :language, :translation,
   :translation_key, :translator, :applications
  ].each do |ctrl|
    get "/admin/#{ctrl}/:action", :to => "admin/#{ctrl}##{action}"
  end

  [:application, :language, :translation, :translator].each do |ctrl|
    get "/api/v1/#{ctrl}/:action", :to => "api/v1/#{ctrl}##{action}"
  end

  get "/api/v1/language/translate.js", :to => 'api/v1/language#translate'
  get '/', :to => 'home#index'
end