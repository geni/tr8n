class AddTranslatorMetricsTotalsUniqueIndex < ActiveRecord::Migration
  NEW_INDEX = 'tr8n_translator_metrics_translator_id_and_language_id_uniq'

  # The old index on (translator_id, language_id) never protected the "totals" row
  # (language_id IS NULL) because unique indexes treat NULL as distinct from NULL.
  # Indexing COALESCE(language_id,-1) instead closes that gap on the exact same two
  # columns, so it replaces the old index outright instead of needing a second,
  # NULL-only partial index alongside it.
  def self.up
    execute "CREATE UNIQUE INDEX #{NEW_INDEX} ON tr8n_translator_metrics (translator_id, COALESCE(language_id,-1))"
    remove_index :tr8n_translator_metrics, [:translator_id, :language_id]
  end

  def self.down
    add_index :tr8n_translator_metrics, [:translator_id, :language_id]
    execute "DROP INDEX IF EXISTS #{NEW_INDEX}"
  end
end
