
Tr8n::Language.destroy_all
Tr8n::Language.create!(:locale => 'en-US', :english_name => 'English', :native_name => 'English')
Tr8n::Language.create!(:locale => 'en-PL', :english_name => 'Pig Latin', :native_name => 'Igpay Atinlay')

User.destroy_all
User.create!(:id => 0, :name => 'Guest', :guest => true)
User.create!(:id => 1, :name => 'User')
User.create!(:id => 2, :name => 'Admin', :admin => true)