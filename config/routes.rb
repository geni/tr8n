# prevent re-drawing of routes if this gem is required multiple times
return unless defined?(@drawn)
@drawn = true

# Rails 3.0 routing syntax
Rails.application.routes.draw do
  [:awards, :chart, :forum, :glossary, :help, :language_cases,
   :language, :phrases, :translations, :translator, :home, :login].each do |ctrl|
    match "tr8n/#{ctrl}/:action", :controller => "tr8n/#{ctrl}", :via => [:get, :post]
  end

  [:chart, :clientsdk, :forum, :glossary, :language, :translation, :translation_key, :translator, :applications].each do |ctrl|
    match "tr8n/admin/#{ctrl}/:action", :controller => "tr8n/admin/#{ctrl}", :via => [:get, :post]
  end

  [:application, :language, :translation, :translator].each do |ctrl|
    match "tr8n/api/v1/#{ctrl}/:action", :controller => "tr8n/api/v1/#{ctrl}", :via => [:get, :post]
  end

  match "tr8n/api/v1/language/translate.js", :controller => "tr8n/api/v1/language", :action => "translate", :via => [:get, :post]

  namespace :tr8n do
    root :to => 'home#index'
  end
end