class Payment
 	include Mongoid::Document
	include Mongoid::Timestamps

	belongs_to :user
	belongs_to :sport

	field :express_token, :type => String
	field :express_payer_id, :type => String
	field :package, type: String
	field :expiration, type: DateTime

	attr_accessor :first_name, :last_name, :ip_address

	def silver
		4900	# $49
	end

	def silvergold
		5000
	end

	def gold
		9900	# $99
	end

	def goldplatinum
		5000
	end

	def platinum
		14900	# $149
	end

	def isSilver?
		package == "Intermediate"
	end

	def isGold?
		package == "Expert"
	end

	def isPlatinum?
		package == "Platinum"
	end

	def purchase(package)
		if package == "Intermediate"
			response = process_purchase(silver)
		elsif package == "Intermediate to Expert"
			response = process_purchase(silvergold)
		elsif package == "Expert"
			response = process_purchase(gold)
		elsif package == "Gold to Platinum"
			response = process_purchase(goldplatinum)
		else
			response = process_purchase(platinum)
		end

		if response.success?
			return true
		else
			raise 'error purchasing package ' + response.message
		end
	end

	def express_token=(token)
		write_attribute(:express_token, token)
		if new_record? && token.present?
			details = EXPRESS_GATEWAY.details_for(token)
			self.express_payer_id = details.payer_id
			self.first_name = details.params["first_name"]
			self.last_name = details.params["last_name"]
		end
	end

	private

		def process_purchase(price)
			EXPRESS_GATEWAY.purchase(
				price,
				:ip => ip_address,
				:token => express_token,
				:payer_id => express_payer_id
			)
		end
end
