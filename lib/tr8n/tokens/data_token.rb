
####################################################################### 
# 
# Data Token Forms:
#
# {count} 
# {count:number} 
# {user:gender}
# {today:date} 
# {user_list:list}
# {long_token_name} 
# {user1}
# {user1:user}
# {user1:user::pos}
#
# Data tokens can be associated with any rules through the :dependency
# notation or using the nameing convetnion of the token suffix, defined
# in the tr8n configuration file
#
####################################################################### 

class Tr8n::Tokens::DataToken < Tr8n::Token
  
  def self.expression
    /(\{[^_:][\w]*(:[\w]+)?(::[\w]+)?\})/
  end

end
