require "resque/tasks"

if Rails.env.production?
	task "resque:setup" => :environment do
	  ENV['QUEUE'] = '*'
	end

	desc "Alias for resque:work (To run workers on Heroku)"
	task "jobs:work" => "resque:work"
else
	task "resque:setup" => :environment
end