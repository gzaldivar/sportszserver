class UserMailer < ActionMailer::Base
	default from: "gametracker.info@gmail.com"

	def welcome_mail(user)
		@user = user
		attachments["GameTracker.png"] = File.read("#{Rails.root}/public/iTunesArtwork.png")
		mail(:to => "#{user.name} <#{user.email}>", :subject => "Welcome to GameTracker!")
	end

	def gametracker_news(users, paragraphone, paragraphtwo, paragraphthree)
		@paragraphone = paragraphone
		@paragraphtwo = paragraphtwo
		@paragraphthree = paragraphthree

		users.each do |user|
			puts user.email
			@user = user
			attachments["GameTracker.png"] = File.read("#{Rails.root}/public/iTunesArtwork.png")
			mail(:to => "#{user.name} <#{user.email}>", :subject => "GameTracker News")
		end
	end

end
