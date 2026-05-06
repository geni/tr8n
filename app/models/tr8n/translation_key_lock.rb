
# == Schema Information
#
# Table name: tr8n_translation_key_locks
#
#  id                 :integer          not null, primary key
#  admin              :boolean
#  locked             :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#  language_id        :integer          not null
#  translation_key_id :integer          not null
#  translator_id      :integer
#
# Indexes
#
#  tr8n_locks_key_id_lang_id  (translation_key_id,language_id)
#
class Tr8n::TranslationKeyLock < ApplicationRecord

  belongs_to :translation_key
  belongs_to :language
  belongs_to :translator

  alias :key :translation_key

  def self.find_or_create(translation_key, language)
    lock = where(:translation_key_id => translation_key.id, :language_id => language.id).first
    lock || create(:translation_key => translation_key, :language => language)
  end

  def self.for(translation_key, language)
    Tr8n::Cache.fetch("translation_key_lock_#{language.locale}_#{translation_key.key}") do
      find_or_create(translation_key, language)
    end
  end

  def lock!(translator = Tr8n::Config.current_translator)
    update_attributes(:locked => true, :translator => translator)
    translator.locked_translation_key!(translation_key, language)
    key.update_metrics!(language)
  end

  def unlock!(translator = Tr8n::Config.current_translator)
    update_attributes(:locked => false, :translator => translator)
    translator.unlocked_translation_key!(translation_key, language)
    key.update_metrics!(language)
  end

  def after_save
    Tr8n::Cache.delete("translation_key_lock_#{language.locale}_#{translation_key.key}")
  end
end
