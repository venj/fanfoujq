require 'rubygems'
require 'curb'
require 'fanfou_user'
require 'json'

class Fanfou
  def initialize
    @api_base = 'http://api.fanfou.com'
    @curl = Curl::Easy.new
    @curl.userpwd = "ffmsgr:zzzzzzzz" # my system password
  end
  
  def authenticate
    @curl.url = @api_base + '/account/verify_credentials.json'
    @curl.perform
    if @curl.response_code == 200
      true
    else
      false
    end
  end
  
  def profile(uid)
    @curl.url = @api_base + "/users/show.json?id=#{@curl.escape(uid)}"
    @curl.perform
    FanfouUser.new(JSON.parse(@curl.body_str))
  end
  
  def follow(uid)
    @curl.url = @api_base + '/friendships/create.json'
    @curl.http_post("id=#{@curl.escape(uid)}")
    if @curl.response_code == 200
      true
    else
      false
    end
  end
  
  def send_private_messages(uid, message)
    @curl.url = @api_base + '/direct_messages/new.json'
    @curl.http_post("user=#{@curl.escape(uid)}&text=#{message}")
  end
end

# Testing
if __FILE__ == $0
  fanfou = Fanfou.new("...","...")
  fanfou.send_private_messages("...", "message")
end