
class Tr8n::OfflineTask

  def self.schedule(class_name, method_name, opts = {})
    # default implementation just passes the call right back
    # you can monkey patch this class to use an offline system of your preference
    class_name.constantize.send(method_name, opts)
  end

end 
