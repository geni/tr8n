class UpdateTr8nTranslatorIdTypes < ActiveRecord::Migration
  def self.up
    # Rails 3.0 + SQLite: Remove indexes before change_column to avoid temp table name issues
    if ActiveRecord::VERSION::MAJOR >= 3
      # tr8n_language_case_value_maps has index on translator_id
      remove_index :tr8n_language_case_value_maps, :name => 'tr8n_lcvm_translator' rescue nil

      # tr8n_translation_key_comments has index on translator_id
      remove_index :tr8n_translation_key_comments, :name => 'tr8n_tkey_msgs_translator_id' rescue nil

      # tr8n_translator_following has index on translator_id
      remove_index :tr8n_translator_following, :column => :translator_id rescue nil

      # tr8n_translator_reports has index on translator_id
      remove_index :tr8n_translator_reports, :column => :translator_id rescue nil

      # tr8n_language_case_rules has index on translator_id
      remove_index :tr8n_language_case_rules, :name => 'tr8n_lcr_translator_id' rescue nil

      # tr8n_language_cases has multiple indexes that cause name length issues
      remove_index :tr8n_language_cases, :column => [:language_id] rescue nil
      remove_index :tr8n_language_cases, :column => [:language_id, :translator_id] rescue nil
      remove_index :tr8n_language_cases, :column => [:language_id, :keyword] rescue nil
    end

    change_column :tr8n_language_case_rules, :translator_id, :integer, :limit => 8
    change_column :tr8n_language_case_value_maps, :translator_id, :integer, :limit => 8
    change_column :tr8n_language_cases, :translator_id, :integer, :limit => 8
    change_column :tr8n_translation_key_comments, :translator_id, :integer, :limit => 8, :null => false
    change_column :tr8n_translator_following, :translator_id, :integer, :limit => 8
    change_column :tr8n_translator_reports, :translator_id, :integer, :limit => 8

    # Re-add indexes with shorter names
    if ActiveRecord::VERSION::MAJOR >= 3
      add_index :tr8n_language_case_value_maps, :translator_id, :name => 'tr8n_lcvm_translator'
      add_index :tr8n_translation_key_comments, :translator_id, :name => 'tr8n_tkc_translator'
      add_index :tr8n_translator_following, :translator_id, :name => 'tr8n_tf_translator'
      add_index :tr8n_translator_reports, :translator_id, :name => 'tr8n_tr_translator'
      add_index :tr8n_language_case_rules, :translator_id, :name => 'tr8n_lcr_translator'
      add_index :tr8n_language_cases, :language_id, :name => 'tr8n_lc_lang'
      add_index :tr8n_language_cases, [:language_id, :translator_id], :name => 'tr8n_lc_lang_translator'
      add_index :tr8n_language_cases, [:language_id, :keyword], :name => 'tr8n_lc_lang_keyword'
    end
  end

  def self.down
    change_column :tr8n_language_case_rules, :translator_id, :integer
    change_column :tr8n_language_case_value_maps, :translator_id, :integer
    change_column :tr8n_language_cases, :translator_id, :integer
    change_column :tr8n_translation_key_comments, :translator_id, :integer, :null => false
    change_column :tr8n_translator_following, :translator_id, :integer
    change_column :tr8n_translator_reports, :translator_id, :integer
  end
end
