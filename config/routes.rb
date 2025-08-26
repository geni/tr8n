Tr8n::Engine.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount WillFilter::Engine => '/will_filter'

  namespace :admin do
    get '/applications',             :to => 'applications#index'
    get '/applications/components',  :to => 'applications#components'
    get '/applications/key_sources', :to => 'applications#key_sources'
    get '/applications/sources',     :to => 'applications#sources'
  end

  get '/awards', :to => 'awards#index'

  get '/forum',       :to => 'forum#index'
  get '/forum/topic', :to => 'forum#topic'

  get '/glossary', :to => 'glossary#index'

  get '/help',                        :to => 'help#index'
  get '/help/advanced_tools',         :to => 'help#advanced_tools'
  get '/help/awards',                 :to => 'help#awards'
  get '/help/creating_translations',  :to => 'help#creating_translations'
  get '/help/dashboard',              :to => 'help#dashboard'
  get '/help/discussions',            :to => 'help#discussions'
  get '/help/help',                   :to => 'help#help'
  get '/help/inline_translator',      :to => 'help#inline_translator'
  get '/help/language_selector',      :to => 'help#language_selector'
  get '/help/management',             :to => 'help#management'
  get '/help/phrases',                :to => 'help#phrases'
  get '/help/ranks',                  :to => 'help#ranks'
  get '/help/site_map',               :to => 'help#site_map'
  get '/help/translations',           :to => 'help#translations'
  get '/help/voting_on_translations', :to => 'help#voting_on_translations'

  get '/home', :to => 'home#index'

  get  '/language',             :to => 'language#index'
  get  '/language/manage',      :to => 'language#manage'
  post '/language/remove',      :to => 'language#remove'
  get  '/language/select',      :to => 'language#select'
  post '/language/switch',      :to => 'language#switch'
  get  '/language/table',       :to => 'language#table'
  get  '/language/translator',  :to => 'language#translator'

  get '/language_cases', :to => 'language_cases#index'

  get '/login',     :to => 'login#index'
  get '/login/out', :to => 'login#out', :as => 'logout'

  get  '/phrases',                :to => 'phrases#index'
  get  '/phrases/map',            :to => 'phrases#map'
  post '/phrases/submit_comment', :to => 'phrases#submit_comment'
  get  '/phrases/view',           :to => 'phrases#view'

  get  '/translations',           :to => 'translations#index'
  get  '/translations/permutate', :to => 'translations#permutate'
  post '/translations/permutate', :to => 'translations#permutate'
  get  '/translations/translate', :to => 'translations#translate'
  post '/translations/translate', :to => 'translations#translate'
  get  '/translations/vote',      :to => 'translations#vote'
  post '/translations/vote',      :to => 'translations#vote'

  get  '/translator',                :to => 'translator#index'
  get  '/translator/assignments',    :to => 'translator#assignments'
  post '/translator/follow',         :to => 'translator#follow'
  get  '/translator/following',      :to => 'translator#following'
  get  '/translator/notifications',  :to => 'translator#notifications'
  get  '/translator/settings',       :to => 'translator#settings'
  post '/translator/unfollow',       :to => 'translator#unfollow'

  post '/translations/translate',   :to => 'translations#translate'

#  [chart, :forum, :glossary, :help, :language_cases,
#   :language, :phrases, :translations, :translator, :home, :login
#  ].each do |ctrl|
#    get "/#{ctrl}/:action", :to => "#{ctrl}##{action}"
#  end

#  [:chart, :clientsdk, :forum, :glossary, :language, :translation,
#   :translation_key, :translator, :applications
#  ].each do |ctrl|
#    get "/admin/#{ctrl}/:action", :to => "admin/#{ctrl}##{action}"
#  end

#  [:application, :language, :translation, :translator].each do |ctrl|
#    get "/api/v1/#{ctrl}/:action", :to => "api/v1/#{ctrl}##{action}"
#  end

  get "/api/v1/language/translate.js", :to => 'api/v1/language#translate'
  get '/', :to => 'home#index'
end