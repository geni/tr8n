
class Tr8n::IpAddress

  def self.non_routable_networks
    @non_routable_networks ||= [
      Tr8n::IpAddress.new('10.0.0.0/8'),
      Tr8n::IpAddress.new('127.0.0.0/8'),
      Tr8n::IpAddress.new('172.16.0.0/12'),
      Tr8n::IpAddress.new('192.168.0.0/16'),
    ]
  end

  def self.routable?(ip)
    not non_routable?(ip)
  end

  def self.non_routable?(ip)
    return true if ip.blank?
    ip = new(ip.to_s) unless ip.is_a?(Tr8n::IpAddress)
    ip.non_routable?
  rescue ArgumentError
    return true
  end

  def non_routable?
    self.class.non_routable_networks.each {|network| return true if network.include?(self)}
    false
  end

end
