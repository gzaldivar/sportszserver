module AdsponsorPayout

		def transfer_ad_payment(sponsor, email)
			if sponsor.ios_client_ad
				adpercentage = (70 - Admin.first.adpercentage) / Float(100)				# Account for Apple taking 30%
				payout = sponsor.ios_client_ad.price
			else
				adpercentage = (100 - Admin.first.adpercentage) / Float(100)
				payout = sponsor.sportadinv.price * adpercentage
			end

			if Rails.env.production?
				gateway = ActiveMerchant::Billing::PaypalGateway.new({
					      login: "gzaldivar_api1.icloud.com",
					      password: "1388935614",
					      signature: "AFcWxV21C7fd0v3bYYYRCpSSRl31Am0NwfOHNMcHaKUsemcqiBUkF" })
				response = gateway.transfer(payout * 100, email, subject: sponsor.name, note: "Purchased ad level" + sponsor.sportadinv.adlevelname)
			else
				gateway = ActiveMerchant::Billing::PaypalGateway.new({
					      login: "gzaldivar-facilitator_api1.icloud.com",
					      password: "1388935614",
					      signature: "AHUvrj4LS85hez4e0oNOt.ng8k.sApA9qsWrgVikPTlU8RdriVeo8t3a" })

				if sponsor.ios_client_ad
					response = gateway.transfer(payout * 100, email, subject: sponsor.name, note: "Purchased ad level" + sponsor.ios_client_ad.referencename)
				else
					response = gateway.transfer(payout * 100, email, subject: sponsor.name, note: "Purchased ad level" + sponsor.sportadinv.adlevelname)
				end
			end

			sponsor.sharetime = DateTime.parse(response.params["timestamp"])
			
			if response.success?
				sponsor.sharepaid = true
			else
				sponsor.sharepaid = false
			end

			if sponsor.ios_client_ad
				sponsor.save(validate: false)
			else
				sponsor.save!
			end
		end

end
