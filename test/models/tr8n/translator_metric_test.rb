require 'test_helper'

class  TranslatorMetricTest < Tr8n::TestCase

  test 'find_or_create creates a total metric' do
    tm = Tr8n::TranslatorMetric.find_or_create(translator, nil)

    assert_equal translator, tm.translator
    assert_nil   tm.language
    assert_equal 0, tm.total_translations
    assert_equal 0, tm.total_votes
    assert_equal 0, tm.positive_votes
    assert_equal 0, tm.negative_votes
  end

  test 'find_or_create creates a metric per language' do
    tm = Tr8n::TranslatorMetric.find_or_create(translator, russian)

    assert_equal translator, tm.translator
    assert_equal russian,    tm.language
  end

  test 'find_or_create returns the existing total metric' do
    tm = Tr8n::TranslatorMetric.find_or_create(translator, nil)

    assert_no_difference 'Tr8n::TranslatorMetric.count' do
      assert_equal tm, Tr8n::TranslatorMetric.find_or_create(translator, nil)
    end
  end

  test 'find_or_create returns the existing metric for a language' do
    tm = Tr8n::TranslatorMetric.find_or_create(translator, russian)

    assert_no_difference 'Tr8n::TranslatorMetric.count' do
      assert_equal tm, Tr8n::TranslatorMetric.find_or_create(translator, russian)
    end
  end

  test 'find_or_create does not confuse the total metric with a language metric' do
    total   = Tr8n::TranslatorMetric.find_or_create(translator, nil)
    russian = Tr8n::TranslatorMetric.find_or_create(translator, self.russian)

    refute_equal total, russian
  end

  test 'update_metrics! for the total metric counts all languages' do
    add_translation(russian)
    add_translation(spanish)

    tm = translator.total_metric
    tm.update_metrics!

    assert_equal 2, tm.total_translations
  end

  test 'update_metrics! for a language only counts that language' do
    add_translation(russian)
    add_translation(spanish)

    tm = Tr8n::TranslatorMetric.find_or_create(translator, russian)
    tm.update_metrics!

    assert_equal 1, tm.total_translations
  end

  test 'update_metrics! counts votes cast by the translator' do
    voter = other_translator

    add_translation(russian).vote!(voter, 1)
    add_translation(spanish).vote!(voter, -1)

    tm = voter.total_metric
    tm.update_metrics!

    assert_equal 2, tm.total_votes
    assert_equal 1, tm.positive_votes
    assert_equal 1, tm.negative_votes
  end

  test 'update_metrics! counts votes cast by the translator for a language' do
    voter = other_translator

    add_translation(russian).vote!(voter, 1)
    add_translation(spanish).vote!(voter, -1)

    tm = Tr8n::TranslatorMetric.find_or_create(voter, russian)
    tm.update_metrics!

    assert_equal 1, tm.total_votes
    assert_equal 1, tm.positive_votes
    assert_equal 0, tm.negative_votes
  end

  test 'update_metrics! saves the metric' do
    add_translation(russian)

    tm = translator.total_metric
    tm.update_metrics!

    refute tm.changed?
    assert_equal 1, tm.reload.total_translations
  end

  test 'update_rank! for the total metric counts all languages' do
    add_translation(russian, :rank => Tr8n::Config.translation_threshold)
    add_translation(spanish, :rank => 0)

    tm = translator.total_metric
    tm.update_rank!

    assert_equal 1, tm.accepted_translations
    assert_equal 2, tm.rejected_translations
  end

  test 'update_rank! for a language only counts that language' do
    add_translation(russian, :rank => Tr8n::Config.translation_threshold)
    add_translation(spanish, :rank => Tr8n::Config.translation_threshold)

    tm = Tr8n::TranslatorMetric.find_or_create(translator, russian)
    tm.update_rank!

    assert_equal 1, tm.accepted_translations
    assert_equal 1, tm.rejected_translations
  end

  test 'update_rank! ignores translations below the threshold' do
    add_translation(russian, :rank => Tr8n::Config.translation_threshold - 1)

    tm = translator.total_metric
    tm.update_rank!

    assert_equal 0, tm.accepted_translations
  end

  test 'update_rank! saves the metric' do
    add_translation(russian, :rank => Tr8n::Config.translation_threshold)

    tm = translator.total_metric
    tm.update_rank!

    refute tm.changed?
    assert_equal 1, tm.reload.accepted_translations
  end

  test 'rank is zero without any translations' do
    assert_equal 0, Tr8n::TranslatorMetric.new(:total_translations => 0, :accepted_translations => 0).rank
  end

  test 'rank is zero when the counters are nil' do
    assert_equal 0, Tr8n::TranslatorMetric.new(:total_translations => nil, :accepted_translations => 5).rank
    assert_equal 0, Tr8n::TranslatorMetric.new(:total_translations => 5, :accepted_translations => nil).rank
  end

  test 'rank is the percentage of accepted translations' do
    tm = Tr8n::TranslatorMetric.new(:total_translations => 4, :accepted_translations => 1)

    assert_equal 25.0, tm.rank
  end

  test 'pending_vote_translations excludes accepted and rejected translations' do
    tm = Tr8n::TranslatorMetric.new(:total_translations => 10,
                                    :accepted_translations => 3,
                                    :rejected_translations => 2)

    assert_equal 5, tm.pending_vote_translations
  end

  test 'pending_vote_translations is the total when the counters are nil' do
    assert_equal 10, Tr8n::TranslatorMetric.new(:total_translations => 10,
                                                :accepted_translations => nil,
                                                :rejected_translations => 2).pending_vote_translations

    assert_equal 10, Tr8n::TranslatorMetric.new(:total_translations => 10,
                                                :accepted_translations => 3,
                                                :rejected_translations => nil).pending_vote_translations
  end

private

  def other_translator
    @other_translator ||= Tr8n::Translator.create!(:user => User.create!(:name => 'Bob', :gender => 'male'))
  end

  def add_translation(language, attrs = {})
    Tr8n::Config.init(language.locale, user)
    tkey = Tr8n::TranslationKey.find_or_create("Hello World in #{language.locale}")

    Tr8n::Translation.create!({:translation_key => tkey,
                               :language        => language,
                               :translator      => translator,
                               :label           => 'Privet Mir'}.merge(attrs))
  end

end # class TranslatorMetricTest
