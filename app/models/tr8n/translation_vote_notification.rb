
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
class Tr8n::TranslationVoteNotification < Tr8n::Notification

  def self.distribute(vote)
    return if vote.translation.translator == vote.translator

    last_notification = Tr8n::TranslationVoteNotification
        .where(["object_type = ? and object_id = ?", vote.class.name, vote.id])
        .order("updated_at desc")
        .first

    return if last_notification and last_notification.updated_at > Time.now - 5.minutes

    tkey = vote.translation.translation_key
    translators = translators_for_translation(vote.translation)

    # find all translators who follow the key
    translators += followers(tkey)
    translators += followers(vote.translator)

    # remove the current translator
    translators = translators.uniq - [vote.translator]

    translators.each do |t|
     create(:translator => t, :object => vote, :actor => vote.translator, :action => "voted_on_translation")
    end
  end

  def verb(vote)
    return "likes" if vote.vote > 0
    "does not like"
  end

  def title
    if object.translation.translation_key.followed?
      return tr("[link: {user}] #{verb(object)} a translation to a phrase you are following.", nil,
          :user => actor, :link => [actor.url]
      )
    end

    if object.translation.translator == Tr8n::Config.current_translator
      return tr("[link: {user}] #{verb(object)} your translation.", nil,
        :user => actor, :link => [actor.url]
      )
    end

    if self.class.translators_for_translation(object.translation).include?(translator)
      return tr("[link: {user}] #{verb(object)} an alternative translation to a phrase you've translated.", nil,
        :user => actor, :link => [actor.url]
      )
    end

    tr("[link: {user}] #{verb(object)} a translation.", nil,
      :user => actor, :link => [actor.url]
    )
  end
end
