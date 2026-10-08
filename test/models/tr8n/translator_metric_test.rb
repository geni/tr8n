require 'test_helper'

class TranslatorMetricTest < Tr8n::TestCase

  test 'create_metric does not create a duplicate totals row for the same translator' do
    first  = Tr8n::TranslatorMetric.create_metric(translator, nil)
    second = Tr8n::TranslatorMetric.create_metric(translator, nil)

    assert_equal first.id, second.id
    assert_equal 1, Tr8n::TranslatorMetric.where(:translator_id => translator.id, :language_id => nil).count
  end

  test 'create_metric does not create a duplicate row for the same translator and language' do
    first  = Tr8n::TranslatorMetric.create_metric(translator, english)
    second = Tr8n::TranslatorMetric.create_metric(translator, english)

    assert_equal first.id, second.id
    assert_equal 1, Tr8n::TranslatorMetric.where(:translator_id => translator.id, :language_id => english.id).count
  end

  test 'the unique index rejects a duplicate totals row (language_id IS NULL) for the same translator' do
    Tr8n::TranslatorMetric.create!(:translator_id => translator.id, :language_id => nil)

    error = assert_raise(ActiveRecord::StatementInvalid) do
      Tr8n::TranslatorMetric.create!(:translator_id => translator.id, :language_id => nil)
    end
    assert_match 'tr8n_translator_metrics_translator_id_and_language_id_uniq', error.message
  end

  test 'the unique index rejects a duplicate row for the same translator and language' do
    Tr8n::TranslatorMetric.create!(:translator_id => translator.id, :language_id => english.id)

    error = assert_raise(ActiveRecord::StatementInvalid) do
      Tr8n::TranslatorMetric.create!(:translator_id => translator.id, :language_id => english.id)
    end
    assert_match 'tr8n_translator_metrics_translator_id_and_language_id_uniq', error.message
  end

end # class TranslatorMetricTest
