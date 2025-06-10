#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# == Schema Information
#
# Table name: tr8n_languages
#
#  id                   :integer          not null, primary key
#  completeness         :integer
#  curse_words          :text
#  enabled              :boolean
#  english_name         :string           not null
#  facebook_key         :string
#  featured_index       :integer          default(0)
#  google_key           :string
#  locale               :string           not null
#  myheritage_key       :string
#  native_name          :string
#  right_to_left        :boolean
#  created_at           :datetime
#  updated_at           :datetime
#  fallback_language_id :integer
#
# Indexes
#
#  index_tr8n_languages_on_locale  (locale)
#
class Tr8n::Language < ApplicationRecord

  has_one  :fallback_language, :class_name => 'Tr8n::Language', :foreign_key => :fallback_language_id

  has_many :language_rules,         Proc.new { order(:type => 'asc') }, :dependent => :destroy
  has_many :language_cases,         Proc.new { order(:id  => 'asc') },  :dependent => :destroy
  has_many :language_users,         :dependent => :destroy
  has_many :translations,           :dependent => :destroy
  has_many :translation_key_locks,  :dependent => :destroy
  has_many :language_metrics,       :dependent => :destroy

  def self.find_or_create(lcl, english_name)
    find_by_locale(lcl) || create(:locale => lcl, :english_name => english_name)
  end

  def self.for(locale)
    return nil if locale.nil?
    Tr8n::Cache.fetch("language_#{locale}") do
      find_by_locale(locale)
    end
  end

  def rules
    Tr8n::Cache.fetch("language_rules_#{id}") do
      language_rules
    end
  end

  def cases
    Tr8n::Cache.fetch("language_cases_#{id}") do
      language_cases
    end
  end

  def reset!
    reset_language_rules!
  end

  def reset_language_rules!
    rules.delete_all
    Tr8n::Config.language_rule_classes.each do |rule_class|
      rule_class.default_rules_for(self).each do |definition|
        rule_class.create(:language => self, :definition => definition)
      end
    end
  end

  def current?
    self.locale == Tr8n::Config.current_language.locale
  end

  def default?
    self.locale == Tr8n::Config.default_locale
  end

  def flag
    locale
  end

  # deprecated
  def has_rules?
    rules?
  end

  def rules?
    not rules.empty?
  end

  def gender_rules?
    return false unless rules?

    rules.each do |rule|
      return true if rule.class.dependency == 'gender'
    end
    false
  end

  def cases?
    not cases.empty?
  end

  def case_keyword_maps
    @case_keyword_maps ||= begin
      hash = {}
      cases.each do |lcase|
        hash[lcase.keyword] = lcase
      end
      hash
    end
  end

  def suggestible?
    not google_key.blank?
  end

  def case_for(case_keyword)
    case_keyword_maps[case_keyword]
  end

  def valid_case?(case_keyword)
    case_for(case_keyword) != nil
  end

  def full_name
    return english_name if english_name == native_name
    "#{english_name} - #{native_name}"
  end

  def self.options
    enabled_languages.collect{|lang| [lang.english_name, lang.id.to_s]}
  end

  def self.locale_options
    enabled_languages.collect{|lang| [lang.english_name, lang.locale]}
  end

  def self.filter_options
    find(:all, :order => "english_name asc").collect{|lang| [lang.english_name, lang.id.to_s]}
  end

  def enable!
    self.enabled = true
    save
  end

  def disable!
    self.enabled = false
    save
  end

  def disabled?
    not enabled?
  end

  def dir
    right_to_left? ? 'rtl' : 'ltr'
  end

  def align(dest)
    return dest unless right_to_left?
    dest.to_s == 'left' ? 'right' : 'left'
  end

  def self.enabled_languages
    Tr8n::Cache.fetch("enabled_languages") do
      where(:enabled => true).order('english_name asc')
    end
  end

  def self.featured_languages
    Tr8n::Cache.fetch("featured_languages") do
      where(:enabled => true).where.not(:featured_index => nil).where('featured_index > 0').order('featured_index desc')
    end
  end

  def self.translate(label, desc = "", tokens = {}, options = {})
    # raise Tr8n::Exception.new("The label is blank") if label.blank?
    raise Tr8n::Exception.new("The label is being translated twice") if label.tr8n_translated?

    if (not Tr8n::Config.enabled?) or (Tr8n::Config.current_language.default? and Tr8n::Config.skip_key_registration_in_default_language?)
      return Tr8n::TranslationKey.substitute_tokens(label, tokens, options).tr8n_translated
    end

    options.delete(:source) unless Tr8n::Config.enable_key_source_tracking?
    Tr8n::Config.current_language.translate(label, desc, tokens, options).tr8n_translated
  end

  def translate(label, desc = "", tokens = {}, options = {})
    return label if label.blank?

    # raise Tr8n::Exception.new("The label is blank") if label.blank?
    raise Tr8n::Exception.new("The label is being translated twice") if label.tr8n_translated?

    if (not Tr8n::Config.enabled?) or (default? and Tr8n::Config.skip_key_registration_in_default_language?)
      return Tr8n::TranslationKey.substitute_tokens(label, tokens, options, self).tr8n_translated
    end

    translation_key = Tr8n::TranslationKey.find_or_create(label, desc, options)
    translation_key.translate(self, tokens.merge(:viewing_user => Tr8n::Config.current_user), options).tr8n_translated
  end
  alias :tr :translate

  def trl(label, desc = "", tokens = {}, options = {})
    tr(label, desc, tokens, options.merge(:skip_decorations => true))
  end

  def default_rule
    @default_rule ||= Tr8n::Config.language_rule_classes.first.new(:language => self, :definition => {})
  end

  def rule_classes
    @rule_classes ||= rules.collect{|r| r.class}.uniq
  end

  def dependencies
    @dependencies ||= rule_classes.collect{|r| r.dependency}.uniq
  end

  def default_rules_for(dependency)
    rules.select{|r| r.class.dependency == dependency}
  end

  def has_gender_rules?
    dependencies.include?("gender")
  end

  def update_daily_metrics_for(metric_date)
    metric = Tr8n::DailyLanguageMetric.where(["language_id = ? and metric_date = ?", self.id, metric_date]).first
    metric ||= Tr8n::DailyLanguageMetric.create(:language_id => self.id, :metric_date => metric_date)
    metric.update_metrics!
  end

  def update_monthly_metrics_for(metric_date)
    metric = Tr8n::MonthlyLanguageMetric.where(["language_id = ? and metric_date = ?", self.id, metric_date]).first
    metric ||= Tr8n::MonthlyLanguageMetric.create(:language_id => self.id, :metric_date => metric_date)
    metric.update_metrics!
  end

  def total_metric
    @total_metric ||= begin
      metric = Tr8n::TotalLanguageMetric.where(:language_id => self.id).first
      metric || Tr8n::TotalLanguageMetric.create(Tr8n::LanguageMetric.default_attributes.merge(:language_id => self.id))
    end
  end

  def update_total_metrics
    total_metric.update_metrics!
  end

  def prohibited_words
    return [] if curse_words.blank?
    @prohibited_words ||= begin
      wrds = self.curse_words.split(",").collect{|w| w.strip.downcase}
      wrds << fallback_language.prohibited_words if fallback_language
      wrds.flatten.uniq
    end
  end

  # you can add -bad_words to override the fallback language rules
  def accepted_prohibited_words
    return [] if curse_words.blank?
    @accepted_prohibited_words ||= begin
      wrds = self.curse_words.split(",").select{|w| w.first=='-'}
      wrds << wrds.collect{|w| w.strip.gsub('-', '').downcase}
      wrds << fallback_language.accepted_prohibited_words if fallback_language
      wrds.flatten.uniq
    end
  end

  def bad_words
    @bad_words ||= begin
      bw = prohibited_words + Tr8n::Config.default_language.prohibited_words
      bw.flatten.uniq - accepted_prohibited_words
    end
  end

  def clean_sentence?(sentence)
    return true if sentence.blank?

    # we need to solve the downcase problem - it doesn't work for russian and others
    sentence = sentence.downcase

    bad_words.each do |w|
      return false unless sentence.scan(/#{w}/).empty?
    end

    true
  end

  def translations_changed!
    # TODO: handle change event
  end

  def after_save
    Tr8n::Cache.delete("language_#{locale}")
    Tr8n::Cache.delete("featured_languages")
    Tr8n::Cache.delete("enabled_languages")
  end

  def after_destroy
    Tr8n::Cache.delete("language_#{locale}")
    Tr8n::Cache.delete("featured_languages")
    Tr8n::Cache.delete("enabled_languages")
  end

  def recently_added_forum_messages
    @recently_added_forum_messages ||= Tr8n::LanguageForumMessage
                                        .where(:language_id => self.id)
                                        .order("created_at desc")
                                        .limit(5)
  end

  def recently_added_translations
    @recently_added_translations ||= Tr8n::Translation.where(:language_id => self.id).order("created_at desc").limit(5)
  end

  def recently_updated_translations
    @recently_updated_translations ||= begin
      conditions = ["language_id = ?", self.id]
      conditions[0] << " and translation_key_id in (select id from tr8n_translation_keys where level <= ? and (type is null or type = 'Tr8n::TranslationKey' or type = 'TranslationKey')) "
      conditions << Tr8n::Config.current_translator.level
      Tr8n::Translation.where(conditions).order("updated_at desc").limit(5)
    end
  end

  def recently_updated_votes(translator = Tr8n::Config.current_translator)
    @recently_updated_votes ||= Tr8n::TranslationVote
                                  .where("translation_id in (select tr8n_translations.id from tr8n_translations where tr8n_translations.language_id = ? and tr8n_translations.translator_id = ?)", self.id, translator.id)
                                  .order("updated_at desc")
                                  .limit(5)
  end

end
