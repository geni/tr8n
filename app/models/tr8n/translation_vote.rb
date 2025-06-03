#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

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

  belongs_to :translation,  :class_name => "Tr8n::Translation"
  belongs_to :translator,   :class_name => "Tr8n::Translator"

  def self.find_or_create(translation, translator)
    vote = where(:translation_id => translation.id, :translator_id => translator.id).first
    vote = create(:translation => translation, :translator => translator, :vote => 0) unless vote
    vote
  end

end
