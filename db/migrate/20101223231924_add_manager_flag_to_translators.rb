class AddManagerFlagToTranslators < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translators, :manager, :boolean
  end

  def self.down
    remove_column :tr8n_translators, :manager
  end
end
