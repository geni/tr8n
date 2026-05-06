
module Tr8n::Admin::BaseHelper
  include Tr8n::CommonMethods
  include Tr8n::HelperMethods
  include WillFilter::HelperMethods

  def tr8n_will_filter(results)
    will_filter(results)
  end

  def tr8n_will_paginate(collection = nil, options = {})
    super(collection, options.merge(:skip_decorations => true))
  end

  def tr8n_page_entries_info(collection, options = {})
    super(collection, options.merge(:skip_decorations => true))
  end

  def tr8n_pretty_print_hash(hash)
    return "" unless hash
    html = ""
    hash.each do |key, value|
       html << "<strong>"
       html << key << ": </strong>"
       if value.is_a?(Hash)
         html << "{"
         html << tr8n_pretty_print_hash(value)
         html << "} "
       else
         html << value.strip if value
         html << "; "
       end
   end
   html
  end

  def language_metric_chart(field = :user_count, limit = 20)
    labels = []
    counts = []
    Tr8n::TotalLanguageMetric.where(["language_id <> ?", Tr8n::Config.default_language.id])
                             .order("#{field} desc")
                             .limit(limit)
    .each do |metric|
      labels << metric.language.english_name
      counts << (metric.send(field) || 0)
    end

    max_count = counts.max
    max_count = 100 if max_count < 100
    counts = counts.collect{|c| c/(max_count * 1.0) * 100}

    @chart_id ||= 0
    @chart_id += 1

    html = []
    html << "<div id='chart#{@chart_id}'></div>"
    html << javascript_tag(%Q|
      document.addEventListener('DOMContentLoaded', function() {
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawChart#{@chart_id});
      });

      function drawChart#{@chart_id}() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Language');
        data.addColumn('number', 'Count');

        #{labels.each_with_index.collect do |label, index|
          "data.addRow(['#{label}', #{counts[index]}]);"
        end.join("\n")}

        var options = {
          title: 'Language Metrics',
          width: 1000,
          height: 300
        };

        var chart#{@chart_id} = new google.visualization.BarChart(document.getElementById('chart#{@chart_id}'));
        chart#{@chart_id}.draw(data, options);
      }
    |)

    html.join.html_safe
  end

  def tr8n_sections_tag(opts = {})
    render(:partial => "/tr8n/admin/common/sections", :locals => {:mode => params[:mode], :modes => opts[:modes], :opts => opts})
  end

end
