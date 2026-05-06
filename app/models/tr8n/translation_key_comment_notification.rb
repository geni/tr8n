
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
class Tr8n::TranslationKeyCommentNotification < Tr8n::Notification

  def self.distribute(comment)
    tkey = comment.translation_key

    # find translators for all other translations of the key in this language
    tanslations = Tr8n::Translation.where(["translation_key_id = ? and language_id = ?", tkey.id, comment.language.id])

    translators = []
    tanslations.each do |t|
      translators << t.translator
    end

    translators += commenters(tkey, comment.language)
    translators += followers(tkey)
    translators += followers(comment.translator)

    # remove the current translator
    translators = translators.uniq - [comment.translator]

    translators.each do |t|
      create(:translator => t, :object => comment, :actor => comment.translator, :action => "commented_on_translation_key")
    end
  end

  def title
    if object.translation_key.followed?
      return tr("[link: {user}] commented on a translation to a phrase you are following.", nil,
          :user => actor, :link => [actor.url]
      )
    end

    if object.translation_key.commented?(object.language)
      return tr("[link: {user}] replied to your comment.", nil,
          :user => actor, :link => [actor.url]
      )
    end

    tr("[link: {user}] commented on a phrase you've translated.", nil,
      :user => actor, :link => [actor.url]
    )
  end


end
