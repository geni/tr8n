class RenameTr8nLanguageCaseValueMapKeyToKeyword < ActiveRecord::Migration
  def self.up
    # Rails 3.0: Remove indexes before rename to avoid temp table name length issues
    if ActiveRecord::VERSION::MAJOR >= 3
      remove_index :tr8n_language_case_value_maps, :name => 'index_tr8n_language_case_value_maps_on_key_and_language_id' rescue nil
      remove_index :tr8n_language_case_value_maps, :name => 'index_tr8n_language_case_value_maps_on_translator_id' rescue nil
    end

    rename_column :tr8n_language_case_value_maps, :key, :keyword

    # Re-add indexes with shorter names for Rails 3.0
    if ActiveRecord::VERSION::MAJOR >= 3
      add_index :tr8n_language_case_value_maps, [:keyword, :language_id], :name => 'tr8n_lcvm_kw_lang'
      add_index :tr8n_language_case_value_maps, :translator_id, :name => 'tr8n_lcvm_translator'
    end
  end

  def self.down
    # Rails 3.0: Remove indexes before rename
    if ActiveRecord::VERSION::MAJOR >= 3
      remove_index :tr8n_language_case_value_maps, :name => 'tr8n_lcvm_kw_lang' rescue nil
      remove_index :tr8n_language_case_value_maps, :name => 'tr8n_lcvm_translator' rescue nil
    end

    rename_column :tr8n_language_case_value_maps, :keyword, :key

    # Re-add original indexes
    if ActiveRecord::VERSION::MAJOR >= 3
      add_index :tr8n_language_case_value_maps, [:key, :language_id], :name => 'tr8n_lcvm_key_lang'
      add_index :tr8n_language_case_value_maps, :translator_id, :name => 'tr8n_lcvm_translator'
    end
  end
end
