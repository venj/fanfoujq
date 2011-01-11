class FanfouUser
  attr_reader :screen_name, :uid
  def initialize(dict)
    @screen_name = dict["screen_name"]
    @uid = dict["id"]
  end
end