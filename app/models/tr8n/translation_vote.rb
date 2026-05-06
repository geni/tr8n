
# == Schema Information
#
# Table name: tr8n_translation_votes
#
#  id             :integer          not null, primary key
#  vote           :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#  translation_id :integer          not null
#  translator_id  :integer          not null
#
# Indexes
#
#  tr8n_trans_votes_trans_id_translator_id  (translation_id,translator_id)
#  tr8n_trans_votes_translator_id           (translator_id)
#
class Tr8n::TranslationVote < ApplicationRecord

  belongs_to :translation
  belongs_to :translator

  def self.find_or_create(translation, translator)
    vote = where(:translation_id => translation.id, :translator_id => translator.id).first
    vote = create(:translation => translation, :translator => translator, :vote => 0) unless vote
    vote
  end

end
