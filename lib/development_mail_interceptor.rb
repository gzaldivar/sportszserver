class DevelopmentMailInterceptor
	def self.delivering_email(message)
    	message.subject = "#{message.to} #{message.subject}"
    	message.to = "gametracker.usertest@gmail.com"
	end
end