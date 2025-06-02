class AddLastIpToTranslators < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_translators, :last_ip, :string
    add_column :tr8n_translators, :country_code, :string
  end

  def self.down
    remove_column :tr8n_translators, :last_ip
    remove_column :tr8n_translators, :country_code
  end
end
