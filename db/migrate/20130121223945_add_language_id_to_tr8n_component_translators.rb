class AddLanguageIdToTr8nComponentTranslators < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_component_translators, :language_id, :integer
  end

  def self.down
    remove_column :tr8n_component_translators, :language_id
  end
end
