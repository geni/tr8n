class AddApplicationToLanguageCases < ActiveRecord::Migration[4.2]
  def self.up
    add_column :tr8n_language_cases, :application, :string
  end

  def self.down
    remove_column :tr8n_language_cases, :application
  end
end
