class AddVerifiedAtToTr8nTranslationKeys < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translation_keys, :verified_at, :timestamp
  end

  def self.down
    remove_column :tr8n_translation_keys, :verified_at
  end
end
