
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
class Tr8n::ComponentTranslatorNotification < Tr8n::Notification

  def self.distribute(ct)
    create(:translator => ct.translator, :object => ct, :target => ct.translator, :action => "got_assigned_to_component")
  end

  def title
    tr("You were assigned to translate a component.")
  end

end
