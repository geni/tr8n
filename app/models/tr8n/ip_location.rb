
# == Schema Information
#
# Table name: tr8n_ip_locations
#
#  id         :integer          not null, primary key
#  assigned   :date
#  cntry      :string(3)
#  country    :string(80)
#  ctry       :string(2)
#  high       :bigint
#  low        :bigint
#  registry   :string(20)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_tr8n_ip_locations_on_high  (high)
#  index_tr8n_ip_locations_on_low   (low)
#
class Tr8n::IpLocation < ApplicationRecord

  def self.no_country_clause
    %q{COALESCE(country, 'ZZZ') = 'ZZZ'}
  end

  def self.find_by_ip(ip)
    ip = case ip
      when String
        Tr8n::IpAddress.new(ip).to_i
      else
        ip.to_i
    end
    first(:conditions => ['low <= ? AND ? <= high', ip, ip]) || new.freeze
  rescue ArgumentError
    puts "Invalid ip: #{ip}" unless Rails.env.test?
    new.freeze
  end

  def blank?
    new_record? || 'ZZZ' == cntry
  end

  def self.import_from_file(file, opts=nil)
    opts ||= {:verbose => false}
    puts "Deleting old records..." if opts[:verbose]
    delete_all
    puts "Done." if opts[:verbose]

    puts "Importing new records..." if opts[:verbose]
    file = File.open(file) if file.is_a?(String)
    file.each_line do |line|
      next if line =~ /^\s*\#|^\s*$/
      line.chomp!.tr!('"\'','')
      values = line.split(',')
      create!(
        :low      =>  values[0],
        :high     =>  values[1],
        :registry =>  values[2],
        :assigned =>  Time.at(values[3].to_i),
        :ctry     =>  values[4],
        :cntry    =>  values[5],
        :country  =>  Iconv.conv('UTF-8', 'ISO_8859-1', values[6])
      )
      $stdout << '.' if opts[:verbose]
    end
    puts "Done." if opts[:verbose]
  end

end
