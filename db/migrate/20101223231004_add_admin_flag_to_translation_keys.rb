class AddAdminFlagToTranslationKeys < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translation_keys, :admin, :boolean
  end

  def self.down
    remove_column :tr8n_translation_keys, :admin
  end
end
