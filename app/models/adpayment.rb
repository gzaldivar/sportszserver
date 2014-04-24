class Adpayment
	include Mongoid::Document
	include Mongoid::Timestamps

	field :express_token, :type => String
	field :express_payer_id, :type => String
	field :expiration, type: DateTime

	belongs_to :sponsor

	attr_accessor :first_name, :last_name, :ip_address

	def purchase(sportadinv)
		response = process_purchase(sportadinv.priceincents)

		if response.success?
			return true
		else
			raise 'error purchasing ad ' + response.message
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