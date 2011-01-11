require 'rubygems'
require 'sinatra'
require 'fanfou'
require 'active_record'
require 'yaml'

configure do 
  # connect to the database 
  dbconfig = YAML.load(File.read('config/database.yml')) 
  ActiveRecord::Base.establish_connection dbconfig['development'] 

  begin 
    ActiveRecord::Schema.define(:version => 1) do 
      create_table :fanfouers do |t| 
        t.string :name, :null => false
        t.string :password, :null => false
        t.string :fanfouer, :null => false
      end
    end
  rescue ActiveRecord::StatementInvalid 
    # do nothing - gobble up the error 
  end
  begin
    ActiveRecord::Schema.define(:version => 2) do 
      remove_column :fanfouers, :password
      add_column :fanfouers, :message, :text
    end
  rescue ActiveRecord::StatementInvalid 
    
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
  user = Fanfou.new(@params["name"], @params["password"])
  @params.delete("password")
  fanfouer = Fanfouer.find_by_name(@params["name"])
  if fanfouer.nil?
    fanfouer = Fanfouer.new(@params)
    fanfouer.save
  else
    fanfouer.update_attributes(@params)
    fanfouer.save
  end
  
  # Initialize system user
  fanfou = Fanfou.new("ffmsgr", "zzzzzzzz")
  
  # Follow him anyway
  fanfou.follow(@params["name"])
  
  fanfouer_2 = Fanfouer.find_by_name(fanfouer.fanfouer)
  if user.authenticate
    if !fanfouer_2.nil? && fanfouer_2.fanfouer == fanfouer.name
      fanfou.send_private_messages(fanfouer.name, "#{fanfou.profile(fanfouer_2.name).screen_name}(http://fanfou.com/#{fanfouer_2.name})让我跟你说，TA很喜欢你。TA还想说：#{fanfouer_2.message}")
      fanfou.send_private_messages(fanfouer_2.name, "#{fanfou.profile(fanfouer.name).screen_name}(http://fanfou.com/#{fanfouer.name})让我跟你说，TA很喜欢你。TA还想说：#{fanfouer.message}")
    end
    erb :check
  else
    @flash = "用户名或密码错误."
    erb :index
  end
end
