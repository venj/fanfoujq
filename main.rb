require 'rubygems'
require 'sinatra'
require 'fanfou'
require 'active_record'
require 'yaml'
require 'base64'

configure do 
  # connect to the database 
  dbconfig = YAML.load(File.read('config/database.yml')) 
  ActiveRecord::Base.establish_connection dbconfig['production'] 

  begin 
    ActiveRecord::Schema.define do 
      create_table :fanfouers do |t| 
        t.string :name, :null => false
        t.string :password, :null => false
        t.string :fanfouer, :null => false
      end 
    end 
  rescue ActiveRecord::StatementInvalid 
    # do nothing - gobble up the error 
  end 
end 

# define a simple model 
class Fanfouer < ActiveRecord::Base
end

get '/' do
  erb :index
end

post '/check' do
  # Do fanfouer save anyway.
  @params.each do |k, v|
    v.strip!
  end
  
  fanfouer = Fanfouer.find_by_name(@params[:name])
  if fanfouer.nil?
    fanfouer = Fanfouer.new(@params)
    fanfouer.save
  else
    fanfouer.update_attributes(@params)
    fanfouer.save
  end
  
  fanfou = Fanfou.new(@params[:name], @params[:password])
  unless fanfou.authenticate
    @flash = "用户名或密码错误。"
    erb :index
  else
    fanfouer_2 = Fanfouer.find_by_name(fanfouer.fanfouer)
    if !fanfouer_2.nil? && fanfouer_2.fanfouer == fanfouer.name
      fanfou_2 = Fanfou.new(fanfouer_2.name, fanfouer_2.password)
      fanfou.send_private_messages(fanfouer_2.name, "#{fanfouer_2.name}，其实我也很喜欢你，我们交往吧!")
      fanfou_2.send_private_messages(fanfouer.name, "#{fanfouer.name}，其实我也很喜欢你，我们交往吧!")
    end
    erb :check
  end
end
