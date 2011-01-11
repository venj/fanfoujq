require 'rubygems'
require 'curb'

class Fanfou
  def initialize(username, password)
    @api_base = 'http://api.fanfou.com'
    @username = username
    @password = password
  end
  
  def authenticate
    curl = Curl::Easy.new
    curl.userpwd = @username + ':' + @password
    curl.url = @api_base + '/account/verify_credentials.json'
    curl.perform
    if curl.response_code == 200
      curl.close
      true
    else
      curl.close
      false
    end
  end
  
  def send_private_messages(uid, message)
    curl = Curl::Easy.new
    curl.userpwd = @username + ':' + @password
    curl.url = @api_base + '/direct_messages/new.json'
    curl.http_post("user=#{uid}&text=#{message}")
    curl.close
  end
end

# Testing
if __FILE__ == $0
  fanfou = Fanfou.new("...","...")
  fanfou.send_private_messages("...", "message")
end