class AddAdminToTr8nTranslationKeyLocks < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translation_key_locks, :admin, :boolean
  end

  def self.down
    remove_column :tr8n_translation_key_locks, :admin
  end
end
