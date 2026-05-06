
# == Schema Information
#
# Table name: tr8n_translation_source_languages
#
#  id                    :integer          not null, primary key
#  created_at            :datetime
#  updated_at            :datetime
#  language_id           :integer
#  translation_source_id :integer
#
# Indexes
#
#  tsllt  (language_id,translation_source_id)
#
class Tr8n::TranslationSourceLanguage < ApplicationRecord

  belongs_to  :translation_source
  belongs_to  :language

  def self.find_or_create(translation_source, language = Tr8n::Config.current_language)
    source_lang = find(:first, :conditions => ["translation_source_id = ? and language_id = ?", translation_source.id, language.id])
    source_lang ||= create(:translation_source => translation_source, :language => language)
  end

  def self.touch(translation_source, language = Tr8n::Config.current_language)
    find_or_create(translation_source, language).touch
  end

end
