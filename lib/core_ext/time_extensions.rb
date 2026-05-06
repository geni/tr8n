
module Tr8n
  module TimeExtensions

    def with_leading_zero(num, options = {})
      return (num < 10 ? "0#{num}" : num) if options[:with_leading_zero]
      num
    end

    def tensify(past, present, future)
      current_time = Time.now
      return past if self < current_time
      return future if self > current_time
      present
    end

    def translate(format = :default, language = Tr8n::Config.current_language, options = {})
      label = (format.is_a?(String) ? format.clone : Tr8n::Config.default_date_formats[format].clone)
      symbols = label.scan(/(%\w)/).flatten.uniq

      selected_tokens = []
      symbols.each do |symbol|
        token = Tr8n::Config.strftime_symbol_to_token(symbol)
        next unless token
        selected_tokens << token
        label.gsub!(symbol, token)
      end

      tokens = {}
      selected_tokens.each do |token|
        case token
          when "{days}" then tokens[:days] = with_leading_zero(day, options)
          when "{year_days}" then tokens[:year_days] = with_leading_zero(yday, options)
          when "{months}" then tokens[:months] = with_leading_zero(month, options)
          when "{week_num}" then tokens[:week_num] = wday
          when "{week_days}" then tokens[:week_days] = strftime("%w")
          when "{short_years}" then tokens[:short_years] = strftime("%y")
          when "{years}" then tokens[:years] = year
          when "{short_week_day_name}" then tokens[:short_week_day_name] = language.tr(Tr8n::Config.default_abbr_day_names[wday], "Short name for a day of a week", {}, options)
          when "{week_day_name}" then tokens[:week_day_name] = language.tr(Tr8n::Config.default_day_names[wday], "Day of a week", {}, options)
          when "{short_month_name}" then tokens[:short_month_name] = language.tr(Tr8n::Config.default_abbr_month_names[month - 1], "Short month name", {}, options)
          when "{month_name}" then tokens[:month_name] = language.tr(Tr8n::Config.default_month_names[month - 1], "Month name", {}, options)
          when "{am_pm}" then tokens[:am_pm] = language.tr(strftime("%p"), "Meridian indicator", {}, options)
          when "{full_hours}" then tokens[:full_hours] = hour
          when "{short_hours}" then tokens[:short_hours] = strftime("%I")
          when "{trimed_hour}" then tokens[:trimed_hour] = strftime("%l")
          when "{minutes}" then tokens[:minutes] = strftime("%M")
          when "{seconds}" then tokens[:seconds] = strftime("%S")
          when "{since_epoch}" then tokens[:since_epoch] = strftime("%s")
          when "{day_of_month}" then tokens[:day_of_month] = strftime("%e")
        end
      end

      language.tr(label, nil, tokens, options)
    end
    alias :tr :translate

    def trl(format = :default, language = Tr8n::Config.current_language, options = {})
      tr(format, language, options.merge!(:skip_decorations => true))
    end

  end # module TimeExtensions
end # module Tr8n

Time.send(:include, Tr8n::TimeExtensions)