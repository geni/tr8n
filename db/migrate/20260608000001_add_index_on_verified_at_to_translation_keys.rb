class AddIndexOnVerifiedAtToTranslationKeys < ActiveRecord::Migration
  def self.up
    add_index :tr8n_translation_keys, :verified_at
  end

  def self.down
    remove_index :tr8n_translation_keys, :verified_at
  end
end
