#--
# Copyright (c) 2010-2013 Michael Berkovich, Geni Inc
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
# Table name: tr8n_notifications
#
#  id            :integer          not null, primary key
#  action        :string
#  object_type   :string
#  type          :string
#  viewed_at     :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  actor_id      :integer
#  object_id     :integer
#  target_id     :integer
#  translator_id :integer
#
# Indexes
#
#  index_tr8n_notifications_on_object_type_and_object_id  (object_type,object_id)
#  index_tr8n_notifications_on_translator_id              (translator_id)
#
class Tr8n::TranslationNotification < Tr8n::Notification

  def self.distribute(translation)
    tkey = translation.translation_key
    translators = translators_for_translation(translation)

    # find all translators who follow the key
    translators += followers(tkey)
    translators += followers(translation.translator)

    # remove the current translator
    translators = translators.uniq - [translation.translator]

    translators.each do |t|
      create(:translator => t, :object => translation, :actor => translation.translator, :action => "added_translation")
    end    
  end

  def title
    if object.translation_key.followed?
      return tr("[link: {user}] added a translation to a phrase you are following.", nil, 
          :user => actor, :link => [actor.url]
          )
    end

    if self.class.translators_for_translation(object).include?(translator)
      return tr("[link: {user}] added another translation to a phrase you've translated.", nil, 
          :user => actor, :link => [actor.url]
      )
    end

    tr("[link: {user}] added a new translation.", nil, 
          :user => actor, :link => [actor.url]
    )
  end
end
