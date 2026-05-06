
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
class Tr8n::TranslatorFollowingNotification < Tr8n::Notification

  def self.distribute(tf)
    return unless tf.object
    if tf.object.is_a?(Tr8n::Translator)
      create(:translator => tf.object, :object => tf, :actor => tf.translator, :target => tf.object, :action => "got_followed")
      create(:translator => tf.translator, :object => tf, :actor => tf.translator, :target => tf.object, :action => "followed_translator")
    end
  end

  def title
    if action == "got_followed"
      return tr("[link: {user}] is now following your translation activity.", nil, 
          :user => actor, :link => [actor.url]
      )
    end

    tr("You are now following [link: {user}]'s translation activity.", nil, 
      :user => target, :link => [target.url]
    )
  end
end
