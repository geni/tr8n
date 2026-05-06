
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
