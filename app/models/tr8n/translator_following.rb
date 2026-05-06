
class Tr8n::TranslatorFollowing < ApplicationRecord
  self.table_name = 'tr8n_translator_following'

  belongs_to :translator
  belongs_to :object, :polymorphic => true

  def self.find_or_create(translator, object)
    following_for(translator, object) || create(:translator => translator, :object => object)
  end

  def self.following_for(translator, object)
    where(['translator_id = ? and object_type = ? and object_id = ?', translator.id, object.class.name, object.id]).first
  end

  def after_create
    Tr8n::Notification.distribute(self)
  end

end
