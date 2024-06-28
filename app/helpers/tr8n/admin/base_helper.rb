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

module Tr8n::Admin::BaseHelper

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
    Tr8n::TotalLanguageMetric.find(:all, :conditions => ["language_id <> ?", Tr8n::Config.default_language.id], :order => "#{field} desc", :limit => limit).each do |metric|
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
    html << javascript_tag %{
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(drawChart);

      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Language');
        data.addColumn('number', 'Count');

        #{labels.each_with_index.collect {|label, index| "data.addRow(['#{label}', #{counts[index]}]);" }

        var options = {
          title: 'Language Metrics',
          width: 1000,
          height: 300
        };

        var chart#{@chart_id} = new google.visualization.BarChart(document.getElementById('chart#{@chart_id}'));
        chart#{@chart_id}.draw(data, options);
      }
    }

    html.join.html_safe
  end

  def tr8n_sections_tag(opts = {})
    render(:partial => "/tr8n/admin/common/sections", :locals => {:mode => params[:mode], :modes => opts[:modes], :opts => opts})
  end

end
