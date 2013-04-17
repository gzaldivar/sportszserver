ENV["REDISTOGO_URL"] ||= "redis://redistogo:a83ed0b8ea32eac27498d36e30315dca@squawfish.redistogo.com:9383//"

uri = URI.parse(ENV["REDISTOGO_URL"])
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password, :thread_safe => true)

Dir["/app/workers/*.rb"].each { |file| require file }