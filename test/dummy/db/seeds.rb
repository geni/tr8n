
Tr8n::Language.destroy_all
Tr8n::Language.create!(:locale => 'en-US', :english_name => 'English', :native_name => 'English')
Tr8n::Language.create!(:locale => 'en-PL', :english_name => 'Pig Latin', :native_name => 'Igpay Atinlay')

User.destroy_all
guest = User.create!(:id => 0, :name => 'Guest', :guest => true)
admin = User.create!(:id => 1, :name => 'Admin', :admin => true)
user  = User.create!(:id => 2, :name => 'User')
trans = User.create!(:id => 3, :name => 'Translator')

Tr8n::Translator.destroy_all
Tr8n::Translator.create!(:name => 'Default Translator', :user => trans)