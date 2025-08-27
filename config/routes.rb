Tr8n::Engine.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount WillFilter::Engine => '/will_filter'

  namespace :admin do
    get    '/applications',                             :to => 'applications#index'
    get    '/applications/components',                  :to => 'applications#components'
    delete '/applications/delete',                      :to => 'applications#delete'
    delete '/applications/delete_component',            :to => 'applications#delete_component'
    delete '/applications/delete_key_source',           :to => 'applications#delete_key_source'
    delete '/applications/delete_source',               :to => 'applications#delete_source'
    get    '/applications/key_sources',                 :to => 'applications#key_sources'
    post   '/applications/lb_add_objects_to_component', :to => 'applications#lb_add_objects_to_component'
    post   '/applications/lb_add_to_component',         :to => 'applications#lb_add_to_component'
    get    '/applications/lb_caller',                   :to => 'applications#lb_caller'
    get    '/applications/lb_update',                   :to => 'applications#lb_update'
    get    '/applications/lb_update_component',         :to => 'applications#lb_update_component'
    get    '/applications/lb_update_source',            :to => 'applications#lb_update_source'
    get    '/applications/recalculate_metric',          :to => 'applications#recalculate_metric'
    get    '/applications/recalculate_source',          :to => 'applications#recalculate_source'
    delete '/applications/remove_keys_from_source',     :to => 'applications#remove_keys_from_source'
    get    '/applications/source',                      :to => 'applications#source'
    get    '/applications/sources',                     :to => 'applications#sources'
    post   '/applications/update',                      :to => 'applications#update'
    post   '/applications/update_component',            :to => 'applications#update_component'
    post   '/applications/update_source',               :to => 'applications#update_source'

    get    '/clientsdk', :to => 'clientsdk#index'

    get    '/forum', :to => 'forum#index'

    get    '/glossary',        :to => 'glossary#index'
    post   '/glossary/update', :to => 'glossary#update'

    get    '/language',                         :to => 'language#index'
    get    '/language/lb_add_to_component',     :to => 'language#lb_add_to_component'
    get    '/language/calculate_total_metrics', :to => 'language#calculate_total_metrics'
    get    '/language/cases',                   :to => 'language#cases'
    get    '/language/case_rules',              :to => 'language#case_rules'
    get    '/language/case_values',             :to => 'language#case_values'
    post   '/language/disable',                 :to => 'language#disable'
    post   '/language/enable',                  :to => 'language#enable'
    get    '/language/lb_update',               :to => 'language#lb_update'
    get    '/language/rules',                   :to => 'language#rules'
    post   '/language/update',                  :to => 'language#update'
    post   '/language/update_value_map',        :to => 'language#update_value_map'
    get    '/language/users',                   :to => 'language#users'
    get    '/language/view',                    :to => 'language#view'

    get    '/metrics', :to => 'metrics#index'

    get    '/translation',        :to => 'translation#index'
    delete '/translation/delete', :to => 'translation#delete'
    get    '/translation/votes',  :to => 'translation#votes'

    get    '/translation_key',                            :to => 'translation_key#index'
    get    '/translation_key/comments',                   :to => 'translation_key#comments'
    delete '/translation_key/delete',                     :to => 'translation_key#delete'
    delete '/translation_key/delete_lock',                :to => 'translation_key#delete_lock'
    post   '/translation_key/lb_add_to_source',           :to => 'translation_key#lb_add_to_source'
    post   '/translation_key/lb_merge',                   :to => 'translation_key#lb_merge'
    post   '/translation_key/lb_update',                  :to => 'translation_key#lb_update'
    get    '/translation_key/locks',                      :to => 'translation_key#locks'
    post   '/translation_key/merge',                      :to => 'translation_key#merge'
    get    '/translation_key/reset_verification_flags',   :to => 'translation_key#reset_verification_flags'
    post   '/translation_key/update',                     :to => 'translation_key#update'
    get    '/translation_key/update_translation_counts',  :to => 'translation_key#update_translation_counts'
    get    '/translation_key/view',                       :to => 'translation_key#view'

    get    '/translator',                 :to => 'translator#index'
    delete '/translator/delete_comment',  :to => 'translator#delete_comment'
    post   '/translator/register',        :to => 'translator#register'
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
  post '/language/manage',      :to => 'language#manage'
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

  get  '/translator',                   :to => 'translator#index'
  get  '/translator/assignments',       :to => 'translator#assignments'
  post '/translator/follow',            :to => 'translator#follow'
  get  '/translator/following',         :to => 'translator#following'
  get  '/translator/notifications',     :to => 'translator#notifications'
  get  '/translator/settings',          :to => 'translator#settings'
  post '/translator/settings',          :to => 'translator#settings'
  post '/translator/unfollow',          :to => 'translator#unfollow'
  post '/translator/update_value_map',  :to => 'translator#update_value_map'

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