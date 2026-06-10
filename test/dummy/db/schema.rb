# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20260608000001) do

  create_table "tr8n_applications", :force => true do |t|
    t.string   "key"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "tr8n_applications", ["key"], :name => "index_tr8n_applications_on_key"

  create_table "tr8n_component_languages", :force => true do |t|
    t.integer  "component_id"
    t.integer  "language_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "state"
  end

  add_index "tr8n_component_languages", ["component_id"], :name => "tr8n_comp_lang_comp_id"
  add_index "tr8n_component_languages", ["language_id"], :name => "tr8n_comp_lang_lang_id"

  create_table "tr8n_component_sources", :force => true do |t|
    t.integer  "component_id"
    t.integer  "translation_source_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "tr8n_component_sources", ["component_id"], :name => "tr8n_comp_comp_id"
  add_index "tr8n_component_sources", ["translation_source_id"], :name => "tr8n_comp_src_id"

  create_table "tr8n_component_translators", :force => true do |t|
    t.integer  "component_id"
    t.integer  "translator_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "language_id"
    t.string   "state"
  end

  add_index "tr8n_component_translators", ["component_id"], :name => "tr8n_comp_trn_comp_id"
  add_index "tr8n_component_translators", ["translator_id"], :name => "tr8n_comp_trn_trn_id"

  create_table "tr8n_components", :force => true do |t|
    t.integer  "application_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "state"
    t.string   "key"
  end

  add_index "tr8n_components", ["application_id"], :name => "tr8n_comp_app_id"
  add_index "tr8n_components", ["key"], :name => "tr8n_comp_key"

  create_table "tr8n_glossary", :force => true do |t|
    t.string   "keyword"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "tr8n_glossary", ["keyword"], :name => "index_tr8n_glossary_on_keyword"

  create_table "tr8n_ip_locations", :force => true do |t|
    t.integer  "low",        :limit => 8
    t.integer  "high",       :limit => 8
    t.string   "registry",   :limit => 20
    t.date     "assigned"
    t.string   "ctry",       :limit => 2
    t.string   "cntry",      :limit => 3
    t.string   "country",    :limit => 80
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "tr8n_ip_locations", ["high"], :name => "index_tr8n_ip_locations_on_high"
  add_index "tr8n_ip_locations", ["low"], :name => "index_tr8n_ip_locations_on_low"

  create_table "tr8n_language_case_rules", :force => true do |t|
    t.integer  "language_case_id",              :null => false
    t.integer  "language_id"
    t.integer  "translator_id",    :limit => 8
    t.text     "definition",                    :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "position"
  end

  add_index "tr8n_language_case_rules", ["language_case_id"], :name => "tr8n_lcr_case_id"
  add_index "tr8n_language_case_rules", ["language_id"], :name => "tr8n_lcr_lang_id"
  add_index "tr8n_language_case_rules", ["translator_id"], :name => "tr8n_lcr_translator"

  create_table "tr8n_language_case_value_maps", :force => true do |t|
    t.string   "keyword",                    :null => false
    t.integer  "language_id",                :null => false
    t.integer  "translator_id", :limit => 8
    t.text     "map"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.boolean  "reported"
  end

  add_index "tr8n_language_case_value_maps", ["keyword", "language_id"], :name => "tr8n_lcvm_kw_lang"
  add_index "tr8n_language_case_value_maps", ["translator_id"], :name => "tr8n_lcvm_translator"

  create_table "tr8n_language_cases", :force => true do |t|
    t.integer  "language_id",                :null => false
    t.integer  "translator_id", :limit => 8
    t.string   "keyword"
    t.string   "latin_name"
    t.string   "native_name"
    t.text     "description"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "application"
  end

  add_index "tr8n_language_cases", ["language_id", "keyword"], :name => "tr8n_lc_lang_keyword"
  add_index "tr8n_language_cases", ["language_id", "translator_id"], :name => "tr8n_lc_lang_translator"
  add_index "tr8n_language_cases", ["language_id"], :name => "tr8n_lc_lang"

  create_table "tr8n_language_forum_abuse_reports", :force => true do |t|
    t.integer  "language_id",               :null => false
    t.integer  "translator_id",             :null => false
    t.integer  "language_forum_message_id", :null => false
    t.string   "reason"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "tr8n_language_forum_abuse_reports", ["language_forum_message_id"], :name => "tr8n_forum_reports_message_id"
  add_index "tr8n_language_forum_abuse_reports", ["language_id", "translator_id"], :name => "tr8n_forum_reports_lang_id_translator_id"
  add_index "tr8n_language_forum_abuse_reports", ["language_id"], :name => "tr8n_forum_reports_lang_id"

  create_table "tr8n_language_forum_messages", :force => true do |t|
    t.integer  "language_id",             :null => false
    t.integer  "language_forum_topic_id", :null => false
    t.integer  "translator_id",           :null => false
    t.text     "message",                 :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "tr8n_language_forum_messages", ["language_id", "language_forum_topic_id"], :name => "tr8n_forum_msgs_lang_id_topic_id"
  add_index "tr8n_language_forum_messages", ["language_id"], :name => "tr8n_forum_msgs_lang_id"
  add_index "tr8n_language_forum_messages", ["translator_id"], :name => "tr8n_forums_msgs_translator_id"

  create_table "tr8n_language_forum_topics", :force => true do |t|
    t.integer  "translator_id", :null => false
    t.integer  "language_id"
    t.text     "topic",         :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tr8n_language_forum_topics", ["language_id"], :name => "tr8n_forum_topics_lang_id"
  add_index "tr8n_language_forum_topics", ["translator_id"], :name => "tr8n_forum_topics_translator_id"

  create_table "tr8n_language_metrics", :force => true do |t|
    t.string   "type"
    t.integer  "language_id",                         :null => false
    t.date     "metric_date"
    t.integer  "user_count",           :default => 0
    t.integer  "translator_count",     :default => 0
    t.integer  "translation_count",    :default => 0
    t.integer  "key_count",            :default => 0
    t.integer  "locked_key_count",     :default => 0
    t.integer  "translated_key_count", :default => 0
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "tr8n_language_metrics", ["created_at"], :name => "index_tr8n_language_metrics_on_created_at"
  add_index "tr8n_language_metrics", ["language_id"], :name => "index_tr8n_language_metrics_on_language_id"

  create_table "tr8n_language_rules", :force => true do |t|
    t.integer  "language_id",   :null => false
    t.integer  "translator_id"
    t.string   "type"
    t.text     "definition"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tr8n_language_rules", ["language_id", "translator_id"], :name => "index_tr8n_language_rules_on_language_id_and_translator_id"
  add_index "tr8n_language_rules", ["language_id"], :name => "index_tr8n_language_rules_on_language_id"

# Could not dump table "tr8n_language_users" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "tr8n_languages", :force => true do |t|
    t.string   "locale",                              :null => false
    t.string   "english_name",                        :null => false
    t.string   "native_name"
    t.boolean  "enabled"
    t.boolean  "right_to_left"
    t.integer  "completeness"
    t.integer  "fallback_language_id"
    t.text     "curse_words"
    t.integer  "featured_index",       :default => 0
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "google_key"
    t.string   "facebook_key"
    t.string   "myheritage_key"
  end

  add_index "tr8n_languages", ["locale"], :name => "index_tr8n_languages_on_locale"

  create_table "tr8n_notifications", :force => true do |t|
    t.string   "type"
    t.integer  "translator_id"
    t.integer  "actor_id"
    t.integer  "target_id"
    t.string   "action"
    t.string   "object_type"
    t.integer  "object_id"
    t.datetime "viewed_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tr8n_notifications", ["object_type", "object_id"], :name => "index_tr8n_notifications_on_object_type_and_object_id"
  add_index "tr8n_notifications", ["translator_id"], :name => "index_tr8n_notifications_on_translator_id"

  create_table "tr8n_sync_logs", :force => true do |t|
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer  "keys_sent"
    t.integer  "translations_sent"
    t.integer  "keys_received"
    t.integer  "translations_received"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "tr8n_translation_domains", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "source_count", :default => 0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "tr8n_translation_domains", ["name"], :name => "index_tr8n_translation_domains_on_name", :unique => true

  create_table "tr8n_translation_key_comments", :force => true do |t|
    t.integer  "language_id",                     :null => false
    t.integer  "translation_key_id",              :null => false
    t.integer  "translator_id",      :limit => 8, :null => false
    t.text     "message",                         :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "tr8n_translation_key_comments", ["language_id", "translation_key_id"], :name => "tr8n_tkey_msgs_lang_id_tkey_id"
  add_index "tr8n_translation_key_comments", ["language_id"], :name => "tr8n_tkey_msgs_lang_id"
  add_index "tr8n_translation_key_comments", ["translator_id"], :name => "tr8n_tkc_translator"

# Could not dump table "tr8n_translation_key_locks" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "tr8n_translation_key_sources", :force => true do |t|
    t.integer  "translation_key_id",    :null => false
    t.integer  "translation_source_id", :null => false
    t.text     "details"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "tr8n_translation_key_sources", ["translation_key_id"], :name => "tr8n_trans_keys_key_id"
  add_index "tr8n_translation_key_sources", ["translation_source_id"], :name => "tr8n_trans_keys_source_id"

  create_table "tr8n_translation_keys", :force => true do |t|
    t.string   "key",                              :null => false
    t.text     "label",                            :null => false
    t.text     "description"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.datetime "verified_at"
    t.integer  "translation_count"
    t.boolean  "admin"
    t.string   "locale"
    t.integer  "level",             :default => 0
    t.string   "type"
    t.datetime "synced_at"
  end

  add_index "tr8n_translation_keys", ["key"], :name => "index_tr8n_translation_keys_on_key", :unique => true
  add_index "tr8n_translation_keys", ["synced_at"], :name => "index_tr8n_translation_keys_on_synced_at"
  add_index "tr8n_translation_keys", ["verified_at"], :name => "index_tr8n_translation_keys_on_verified_at"

  create_table "tr8n_translation_source_languages", :force => true do |t|
    t.integer  "language_id"
    t.integer  "translation_source_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "tr8n_translation_source_languages", ["language_id", "translation_source_id"], :name => "tsllt"

  create_table "tr8n_translation_source_metrics", :force => true do |t|
    t.integer  "translation_source_id",                :null => false
    t.integer  "language_id",                          :null => false
    t.integer  "key_count",             :default => 0
    t.integer  "locked_key_count",      :default => 0
    t.integer  "translation_count",     :default => 0
    t.integer  "translated_key_count",  :default => 0
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "tr8n_translation_source_metrics", ["translation_source_id", "language_id"], :name => "tr8n_tsm_trans_source_and_lang"

  create_table "tr8n_translation_sources", :force => true do |t|
    t.string   "source"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "translation_domain_id"
    t.integer  "completeness",          :default => 0
    t.string   "name"
    t.text     "description"
    t.string   "url"
    t.integer  "key_count"
  end

  add_index "tr8n_translation_sources", ["source"], :name => "tr8n_sources_source"

  create_table "tr8n_translation_votes", :force => true do |t|
    t.integer  "translation_id", :null => false
    t.integer  "translator_id",  :null => false
    t.integer  "vote",           :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "tr8n_translation_votes", ["translation_id", "translator_id"], :name => "tr8n_trans_votes_trans_id_translator_id"
  add_index "tr8n_translation_votes", ["translator_id"], :name => "tr8n_trans_votes_translator_id"

  create_table "tr8n_translations", :force => true do |t|
    t.integer  "translation_key_id",                             :null => false
    t.integer  "language_id",                                    :null => false
    t.integer  "translator_id",                                  :null => false
    t.text     "label",                                          :null => false
    t.integer  "rank",                            :default => 0
    t.integer  "approved_by_id",     :limit => 8
    t.text     "rules"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.datetime "synced_at"
  end

  add_index "tr8n_translations", ["created_at"], :name => "tr8n_trans_created_at"
  add_index "tr8n_translations", ["synced_at"], :name => "index_tr8n_translations_on_synced_at"
  add_index "tr8n_translations", ["translation_key_id", "translator_id", "language_id"], :name => "tr8n_trans_key_id_translator_id_lang_id"
  add_index "tr8n_translations", ["translator_id"], :name => "r8n_trans_translator_id"

  create_table "tr8n_translator_following", :force => true do |t|
    t.integer  "translator_id", :limit => 8
    t.integer  "object_id"
    t.string   "object_type"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "tr8n_translator_following", ["translator_id"], :name => "tr8n_tf_translator"

  create_table "tr8n_translator_logs", :force => true do |t|
    t.integer  "translator_id"
    t.integer  "user_id",       :limit => 8
    t.string   "action"
    t.integer  "action_level"
    t.string   "reason"
    t.string   "reference"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "tr8n_translator_logs", ["created_at"], :name => "index_tr8n_translator_logs_on_created_at"
  add_index "tr8n_translator_logs", ["translator_id"], :name => "index_tr8n_translator_logs_on_translator_id"
  add_index "tr8n_translator_logs", ["user_id"], :name => "index_tr8n_translator_logs_on_user_id"

  create_table "tr8n_translator_metrics", :force => true do |t|
    t.integer  "translator_id",                                     :null => false
    t.integer  "language_id",           :limit => 8
    t.integer  "total_translations",                 :default => 0
    t.integer  "total_votes",                        :default => 0
    t.integer  "positive_votes",                     :default => 0
    t.integer  "negative_votes",                     :default => 0
    t.integer  "accepted_translations",              :default => 0
    t.integer  "rejected_translations",              :default => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "tr8n_translator_metrics", ["created_at"], :name => "index_tr8n_translator_metrics_on_created_at"
  add_index "tr8n_translator_metrics", ["translator_id", "language_id"], :name => "index_tr8n_translator_metrics_on_translator_id_and_language_id"
  add_index "tr8n_translator_metrics", ["translator_id"], :name => "index_tr8n_translator_metrics_on_translator_id"

  create_table "tr8n_translator_reports", :force => true do |t|
    t.integer  "translator_id", :limit => 8
    t.string   "state"
    t.integer  "object_id"
    t.string   "object_type"
    t.string   "reason"
    t.text     "comment"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "tr8n_translator_reports", ["translator_id"], :name => "tr8n_tr_translator"

# Could not dump table "tr8n_translators" because of following FrozenError
#   can't modify frozen String: "false"

# Could not dump table "users" because of following FrozenError
#   can't modify frozen String: "false"

  create_table "wf_filters", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "data"
    t.integer  "user_id"
    t.string   "model_class_name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "wf_filters", ["user_id"], :name => "index_wf_filters_on_user_id"

end
