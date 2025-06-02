class AddTypeToTr8nTranslationKeys < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translation_keys, :type, :string
  end

  def self.down
    remove_column :tr8n_translation_keys, :type, :string
  end
end
