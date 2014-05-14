class SendApnNotification
  
	require 'houston'
	require 'open-uri'

	@queue = :sendapn_queue

	def self.perform(alertid)
#		admin = Admin.all.first
		
#		if Rails.env.production?
#			iphonepushnotification = Houston::Client.production
#			ipadpushnotification = Houston::Client.production
#		else
#			iphonepushnotification = Houston::Client.development
#			ipadpushnotification = Houston::Client.development
#		end

		iPhoneFname = "#{Rails.root}/tmp" + "/" + SecureRandom.hex(10) + "iPhoneTempfile.pem"
		iPadFname = "#{Rails.root}/tmp" + "/" + SecureRandom.hex(10) + "iPadTempfile.pem"

		s3 = AWS::S3.new
		bucket = s3.buckets[S3DirectUpload.config.bucket]

		if Rails.env.production?
			iphoneobj = bucket.objects['admins/certificates/GameTracker/apple_push_notification.pem']
			ipadobj = bucket.objects['admins/certificates/GameTrackerHD/apple_push_notification.pem']
		else
			iphoneobj = bucket.objects['admins/certificates/GameTrackerTest/GameTrackerTest_apn_notification.pem']
			ipadobj = bucket.objects['admins/certificates/GameTrackerHDTest/GameTrackerHdTest_apn_notification.pem']
		end

		File.open(iPhoneFname, 'wb') do |file|
			iphoneobj.read do |chunk|
		  		file.write(chunk)
			end
		end

		iphonecertificate = File.read(iPhoneFname)

		s3 = AWS::S3.new
		bucket = s3.buckets[S3DirectUpload.config.bucket]

		File.open(iPadFname, 'wb') do |file|
			ipadobj.read do |chunk|
		  		file.write(chunk)
			end
		end

		ipadcertificate = File.read(iPadFname)

		passphrase = "cjz1216"

		if Rails.env.production?
			connection = Houston::Connection.new(Houston::APPLE_PRODUCTION_GATEWAY_URI, iphonecertificate, passphrase)
			ipadconection = Houston::Connection.new(Houston::APPLE_PRODUCTION_GATEWAY_URI, ipadcertificate, passphrase)
		else
			connection = Houston::Connection.new(Houston::APPLE_DEVELOPMENT_GATEWAY_URI, iphonecertificate, passphrase)
			ipadconection = Houston::Connection.new(Houston::APPLE_DEVELOPMENT_GATEWAY_URI, ipadcertificate, passphrase)
		end

		connection.open
		ipadconection.open

		# use the newly created file as the PEM file for the Houston gem

		alert = Alert.find(alertid)
		sport = Sport.find(alert.sport_id)
		team = sport.teams.find(alert.team_id)

		team.apn_notifications.each do |n|
			bundle = n.bundleidentifier.split(".")

			if n.scorealerts and alert.gamelog_id
				if bundle[2] == "gametracker"
					send_notification(n, connection, alert)
				elsif bundle[2] == "gametrackerhd"
					send_notification(n, ipadconection, alert)
				end
			elsif n.mediaalerts and (alert.photo_id or alert.videoclip_id)
				if bundle[2] == "gametracker"
					send_notification(n, connection, alert)
				elsif bundle[2] == "gametrackerhd"
					send_notification(n, ipadconection, alert)
				end
			elsif n.blogalerts and alert.blog_id
				if bundle[2] == "gametracker"
					send_notification(n, connection, alert)
				elsif bundle[2] == "gametrackerhd"
					send_notification(n, ipadconection, alert)
				end
			elsif n.athleterts and alert.athlete_id
				if bundle[2] == "gametracker"
					send_notification(n, connection, alert)
				elsif bundle[2] == "gametrackerhd"
					send_notification(n, ipadconection, alert)
				end
			end
		end

		connection.close
		ipadconection.close

		# clean up

		if alert.athlete_id.nil?
			alert.destroy
		end

		File.delete(iPhoneFname)
		File.delete(iPadFname)

		if Rails.env.production?
			olddevices = Houston::Client.production
		else
			olddevices = Houston::Client.development
		end

		olddevices.certificate = iphonecertificate
		olddevices.passphrase = passphrase
		iphonedevices = olddevices.devices

		iphonedevices.each do |d|
			apn = sport.team.apn_notifications.find(d)
			d.destroy!
		end

		olddevices.certificate = ipadcertificate
		olddevices.passphrase = passphrase
		ipaddevices = olddevices.devices

		ipaddevices.each do |d|
			apn = sport.team.apn_notifications.find(d)
			d.destroy!
		end
	end

    def self.send_notification(apn, connection, alert)
    	puts "send notification"
    	puts alert.message
      	notification = Houston::Notification.new(device: apn.token)
      	notification.alert  = alert.message
      	connection.write(notification.message)
    end

end