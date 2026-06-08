require_relative '../test_helper'

class Tr8n::TranslationKeyTest < Tr8n::TestCase

  def setup
    super
    @user = Tr8n::Translator.create!(:id => 2, :user_id => 2, :name => "Mike")
    Tr8n::Config.init(@russian.locale, @current_user)
  end

  test "find or create a translation key" do
    key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key
    the_key = Tr8n::TranslationKey.find_or_create("Hello World", "We must start with this sentence!")
    assert key.key, the_key.key
  end

  test "tokens" do
    key = Tr8n::TranslationKey.find_or_create("Hello {user}, you have {count} messages in your inbox")

    assert key.key
    assert key.translation_tokens?
    assert (not key.decoration_tokens?)

    assert_equal ["{user}", "{count}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["{user}", "{count}"], key.translation_tokens.collect{|t| t.sanitized_name}
  end

  test "basic translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello World")
    t = key.translate(@default_language)
    assert_equal "Hello World", t

    key = Tr8n::TranslationKey.find_or_create("Hello {world}")
    assert_equal ["{world}"], key.tokens.collect{|t| t.sanitized_name}
    t = key.translate(@default_language, :world => "World")
    assert_equal "Hello World", t

    key = Tr8n::TranslationKey.find_or_create("{hello_world}")
    assert_equal ["{hello_world}"], key.tokens.collect{|t| t.sanitized_name}
    t = key.translate(@default_language, :hello_world => "Hello World")
    assert_equal "Hello World", t
  end

  test "gender based translations in English" do
    # @user already has name set to "Mike" in setup, just need to set gender
    @user.update_attributes(:gender => "male")

    key = Tr8n::TranslationKey.find_or_create("Dear {user}")
    assert_equal ["{user}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal "Dear Mike", key.translate(@default_language, :user => @user)

    key = Tr8n::TranslationKey.find_or_create("Dear {user:gender}")
    assert_equal ["{user}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal "Dear Mike", key.translate(@default_language, :user => @user)
    assert_equal "Dear Mike", key.translate(@default_language, :user => [@user, @user.name])
    assert_equal "Dear Mike", key.translate(@default_language, :user => [@user, :name])
    assert_equal "Dear Mike", key.translate(@default_language, :user => [@user, lambda{|user| user.name}])
    assert_equal "Dear Mike and Tom", key.translate(@default_language, :user => [@user, lambda{|user, tom| "#{user.name} and #{tom}"}, "Tom"])

    key = Tr8n::TranslationKey.find_or_create("{custom:gender} updated {custom:gender|his,her} profile")
    assert_equal ["{custom:gender}", "{custom:gender|his,her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike updated his profile", key.translate(@default_language, {:custom => @user})

    key = Tr8n::TranslationKey.find_or_create("{user} updated {user|his,her} profile")
    assert_equal ["{user}", "{user|his,her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Mike updated his profile", key.translate(@default_language, :user => @user)

    @user.update_attributes(:name => "Tina", :gender => "female")
    assert_equal "Tina updated her profile", key.translate(@default_language, :user => @user)

    @user.update_attributes(:name => "Alex", :gender => "unknown")
    assert_equal "Alex updated his/her profile", key.translate(@default_language, :user => @user)

    key = Tr8n::TranslationKey.find_or_create("{user} updated {user | his, her, his-her} profile")
    assert_equal ["{user}", "{user | his, her, his-her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex updated his-her profile", key.translate(@default_language, :user => @user)

    # double pipe approach - will include the name
    key = Tr8n::TranslationKey.find_or_create("{user || updated his, updated her, updated his/her} profile")
    assert_equal ["{user || updated his, updated her, updated his/her}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex updated his/her profile", key.translate(@default_language, :user => [@user, :name])
  end

  test "number based translations in English" do
    # old way of doing things
    key = Tr8n::TranslationKey.find_or_create("{val:number} {_messages}")
    assert_equal ["{val}", "{_messages}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "5 messages", key.translate(@default_language, :val => 5, :_messages => "message".pluralize_for(5))

    key = Tr8n::TranslationKey.find_or_create("{count} {_messages}")
    assert_equal ["{count}", "{_messages}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "5 messages", key.translate(@default_language, :count => 5, :_messages => "message".pluralize_for(5))

    @user.update_attributes(:name => "Alex")
    # Define age method on this instance (since Translator doesn't have age attribute)
    def @user.age; 5; end
    key = Tr8n::TranslationKey.find_or_create("{user} is now {years} {_years} old")
    assert_equal ["{user}", "{years}", "{_years}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::DataToken", "Tr8n::Tokens::HiddenToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :years => @user.age, :_years => "year".pluralize_for(@user.age))

    # new way
    key = Tr8n::TranslationKey.find_or_create("{user} is now {age} {age|year} old")
    assert_equal ["{user}", "{age}", "{age|year}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{age}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :age => @user.age)

    key = Tr8n::TranslationKey.find_or_create("{user} is now {age || year} old")
    assert_equal ["{user}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :age => @user.age)

    key = Tr8n::TranslationKey.find_or_create("{user} is now {age || year, years} old")
    assert_equal ["{user}", "{age || year, years}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{age}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Alex is now 5 years old", key.translate(@default_language, :user => [@user, :name], :age => @user.age)

    key = Tr8n::TranslationKey.find_or_create("{count||person,people}")
    assert_equal ["{count||person,people}"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{count}"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::TransformToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "1 person", key.translate(@default_language, :count => 1)
    assert_equal "2 people", key.translate(@default_language, :count => 2)
    assert_equal "0 people", key.translate(@default_language, :count => 0)
  end

  test "decoration tokens" do
    # see config/tr8n/tokens/decorations.yml

    key = Tr8n::TranslationKey.find_or_create("[b: hello world]")
    assert_equal ["[b: hello world]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "<b>hello world</b>", key.translate(@default_language, :b => lambda{|str| "<b>#{str}</b>"})
    assert_equal "<b>hello world</b>", key.translate(@default_language, :b => "<b>{$0}</b>")
    assert_equal "<strong>hello world</strong>", key.translate(@default_language)

    key = Tr8n::TranslationKey.find_or_create("[link: click here]")
    assert_equal ["[link: click here]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["[link: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "<a href='www.google.com' style=''>click here</a>", key.translate(@default_language, :link => ["www.google.com"])

    assert_equal "<a href='www.google.com' style=''>click here</a>", key.translate(@default_language, :link => ["www.google.com"])
  end

  test "nested tokens" do
    # see config/tr8n/tokens/decorations.yml
    @user.update_attributes(:name => "Michael")

    key = Tr8n::TranslationKey.find_or_create("Hello [b: {user.name}]")
    assert_equal ["{user.name}", "[b: {user.name}]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user.name}", "[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::MethodToken", "Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Hello <strong>Michael</strong>", key.translate(@default_language, :user => @user)

    key = Tr8n::TranslationKey.find_or_create("Dear {user}, you have [b: {count||message}] in your inbox")
    assert_equal ["{user}", "{count||message}", "[b: {count||message}]"], key.tokens.collect{|t| t.full_name}
    assert_equal ["{user}", "{count}", "[b: ]"], key.tokens.collect{|t| t.sanitized_name}
    assert_equal ["Tr8n::Tokens::DataToken", "Tr8n::Tokens::TransformToken", "Tr8n::Tokens::DecorationToken"], key.tokens.collect{|t| t.class.name}
    assert_equal "Dear Michael, you have <strong>5 messages</strong> in your inbox", key.translate(@default_language, :user => @user, :count => 5)
  end

  test "words" do
    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert_equal ["Hello", "Link1", "User", "Have", "Link2", "Count", "Posted", "Items"], key.words
  end

  test "locking translation key" do
    key = Tr8n::TranslationKey.find_or_create("Hello [link1: {user}], you have [link2: {count} {_posted__items}]")
    assert key.unlocked?
    key.lock!
    assert key.locked?
    key.unlock!
    assert key.unlocked?
  end

  test "simple translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello World")

    assert key.add_translation("Привет Мир")

    # for Russian
    assert_equal "Привет Мир", key.translate(@russian)

    # for Spanish
    assert_equal "Hello World", key.translate(@spanish)
  end

  test "simple token translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello {name}")

    assert key.add_translation("Привет {name}")

    # for Russian
    assert_equal "Привет Mike", key.translate(@russian, :name => "Mike")

    # for Spanish
    assert_equal "Hello Mike", key.translate(@spanish, :name => "Mike")
  end

  test "object translations" do
    # Define first_name method on this instance (since Translator doesn't have first_name attribute)
    def @user.first_name; 'Mike'; end
    key = Tr8n::TranslationKey.find_or_create("Hello {user.first_name}")
    assert key.add_translation("Привет {user.first_name}")

    # for Russian
    assert_equal "Привет Mike", key.translate(@russian, :user => @user)

    # for Spanish
    assert_equal "Hello Mike", key.translate(@spanish, :user => @user)
  end

  test "more object translations" do
    key = Tr8n::TranslationKey.find_or_create("Hello {user}")
    assert key.add_translation("Привет {user}")

    assert_equal "Привет Mike", key.translate(@russian, :user => [@user, @user.name])
    assert_equal "Привет Mike", key.translate(@russian, :user => [@user, :name])
  end

  test "number based translations" do
    key    = Tr8n::TranslationKey.find_or_create("{count} {_messages}")
    lrule1 = Tr8n::NumericRule.create(:language => @russian, :definition => {:multipart => false, :part1 => 'is', :value1 => '1'})
    lrule2 = Tr8n::NumericRule.create(:language => @russian, :definition => {:multipart => false, :part1 => 'is_not', :value1 => '1'})

    assert key.add_translation("{count} сообщение", [{:token => 'count', :rule_id => [lrule1.id]}])
    assert key.add_translation("{count} сообщений", [{:token => 'count', :rule_id => [lrule2.id]}])

    assert_equal "1 сообщение", key.translate(@russian, :count => 1, :_messages => "message")
    assert_equal "10 сообщений", key.translate(@russian, :count => 10, :_messages => "messages")
  end

  test "verified_at gets updated when key is accessed with verification enabled" do
    # Save original config value
    original_config = Tr8n::Config.config[:enable_key_verification]

    begin
      # Enable key verification
      Tr8n::Config.config[:enable_key_verification] = true

      # Create a key with verified_at in the past
      past_time = 3.days.ago
      unique_label = "Test verification #{Time.now.to_f}"
      key = Tr8n::TranslationKey.create!(
        :key => Tr8n::TranslationKey.generate_key(unique_label, ""),
        :label => unique_label,
        :description => "",
        :locale => @default_language.locale,
        :verified_at => past_time
      )

      # Access the key through find_or_create (which calls verify_key)
      current_time = Time.now
      Tr8n::TranslationKey.find_or_create(unique_label, "")

      # Reload to get fresh data from database
      key.reload

      # verified_at should be updated to approximately now
      assert_not_nil key.verified_at
      assert key.verified_at > past_time, "verified_at should be updated from past time"
      assert (key.verified_at - current_time).abs < 5, "verified_at should be close to current time"
    ensure
      # Restore original config
      Tr8n::Config.config[:enable_key_verification] = original_config
    end
  end

  test "verified_at respects 24-hour throttle" do
    # Save original config value
    original_config = Tr8n::Config.config[:enable_key_verification]

    begin
      # Enable key verification
      Tr8n::Config.config[:enable_key_verification] = true

      # Create a key with verified_at 12 hours ago (within throttle window)
      recent_time = 12.hours.ago
      unique_label = "Test throttle #{Time.now.to_f}"
      key = Tr8n::TranslationKey.create!(
        :key => Tr8n::TranslationKey.generate_key(unique_label, ""),
        :label => unique_label,
        :description => "",
        :locale => @default_language.locale,
        :verified_at => recent_time
      )

      original_verified_at = key.verified_at

      # Access the key through find_or_create
      Tr8n::TranslationKey.find_or_create(unique_label, "")

      # Reload to get fresh data from database
      key.reload

      # verified_at should NOT be updated due to 24-hour throttle
      assert_equal original_verified_at.to_i, key.verified_at.to_i,
                   "verified_at should not be updated within 24-hour throttle window"
    ensure
      # Restore original config
      Tr8n::Config.config[:enable_key_verification] = original_config
    end
  end

  test "verified_at not updated when verification disabled" do
    # Save original config value
    original_config = Tr8n::Config.config[:enable_key_verification]

    begin
      # Disable key verification
      Tr8n::Config.config[:enable_key_verification] = false

      # Create a key with verified_at in the past
      past_time = 3.days.ago
      unique_label = "Test disabled #{Time.now.to_f}"
      key = Tr8n::TranslationKey.create!(
        :key => Tr8n::TranslationKey.generate_key(unique_label, ""),
        :label => unique_label,
        :description => "",
        :locale => @default_language.locale,
        :verified_at => past_time
      )

      # Access the key through find_or_create
      Tr8n::TranslationKey.find_or_create(unique_label, "")

      # Reload to get fresh data from database
      key.reload

      # verified_at should NOT be updated when verification is disabled
      assert_equal past_time.to_i, key.verified_at.to_i,
                   "verified_at should not be updated when verification is disabled"
    ensure
      # Restore original config
      Tr8n::Config.config[:enable_key_verification] = original_config
    end
  end

  test "touch_sources not called when only verified_at changes" do
    # Create a translation source
    source = Tr8n::TranslationSource.create!(
      :source => "test_controller#test_action_#{Time.now.to_f}"
    )

    # Create a translation key associated with this source
    key = Tr8n::TranslationKey.find_or_create("Test no touch on verify #{Time.now.to_f}")
    Tr8n::TranslationKeySource.create!(
      :translation_key => key,
      :translation_source => source
    )

    # Record source's current updated_at
    source.reload
    original_updated_at = source.updated_at

    # Update only verified_at (simulating usage tracking)
    sleep 0.1 # Small delay to ensure timestamp would change if touched
    key.update_attributes(:verified_at => Time.now)

    # Reload source
    source.reload

    # updated_at should NOT have changed when only verified_at was updated
    assert_equal original_updated_at.to_i, source.updated_at.to_i,
                 "source.updated_at should not be touched when only verified_at changes"
  end

  test "touch_sources respects 24-hour throttle" do
    # Create a translation source
    source = Tr8n::TranslationSource.create!(
      :source => "test_controller#test_action_#{Time.now.to_f}"
    )

    # Create a translation key associated with this source
    key = Tr8n::TranslationKey.find_or_create("Test touch throttle #{Time.now.to_f}")
    Tr8n::TranslationKeySource.create!(
      :translation_key => key,
      :translation_source => source
    )

    # Update source's updated_at to 12 hours ago (within throttle window)
    recent_time = 12.hours.ago
    source.update_attributes(:updated_at => recent_time)
    original_updated_at = source.updated_at

    # Trigger after_save which calls touch_sources (change something other than verified_at)
    key.update_attributes(:description => "Modified")

    # Reload source
    source.reload

    # updated_at should NOT have changed due to 24-hour throttle
    assert_equal original_updated_at.to_i, source.updated_at.to_i,
                 "source.updated_at should not be touched within 24-hour throttle window"
  end

  test "touch_sources updates old sources" do
    # Create a translation source with old updated_at
    source = Tr8n::TranslationSource.create!(
      :source => "test_controller#test_action_old_#{Time.now.to_f}"
    )

    # Create a translation key associated with this source
    key = Tr8n::TranslationKey.find_or_create("Test touch old #{Time.now.to_f}")
    Tr8n::TranslationKeySource.create!(
      :translation_key => key,
      :translation_source => source
    )

    # Update source's updated_at to 3 days ago (outside throttle window)
    old_time = 3.days.ago
    source.update_attributes(:updated_at => old_time)

    # Trigger after_save which calls touch_sources
    current_time = Time.now
    key.update_attributes(:description => "Modified again")

    # Reload source
    source.reload

    # updated_at should have been updated
    assert source.updated_at > old_time,
           "source.updated_at should be touched when older than 24 hours"
    assert (source.updated_at - current_time).abs < 5,
           "source.updated_at should be close to current time"
  end

end # class Tr8n::TranslationKeyTest