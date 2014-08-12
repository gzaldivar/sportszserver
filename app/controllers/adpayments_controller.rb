class AdpaymentsController < ApplicationController

	before_filter :get_sport

	def new
		sportadinv = Sportadinv.find(params[:sportadinv_id])

		response = EXPRESS_GATEWAY.setup_purchase(
			sportadinv.priceincents,
			ip: request.remote_ip,
			return_url: confirm_sport_sponsor_adpayments_url,
			cancel_return_url: cancel_sport_sponsor_adpayments_url,
			allow_guest_checkout: 'true',				   #payment with credit card for non PayPal users
			items: [ { name:sportadinv.adlevelname, description: sportadinv.adlevelname, quantity: "1", amount: sportadinv.priceincents, 
					   custom: sportadinv.id.to_s } ] #array of hashes, amount is a price in cents
		)
		redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
	end

	def confirm
		@order = Adpayment.new
		@sportadinv = @sport.sportadinvs.find(@sponsor.sportadinv_id)
		@order.express_token = params[:token]
		@price = @sportadinv.price
		render 'confirm'
	end

	def show
   		@order = Adpayment.find(params[:id])

   		redirect_to sport_sponsor_path(@sport, @sponsor)
  	end

  	def index
  	end

	def cancel
#		@sportadinv = @sport.sportadinvs.find(params[:custom])
		@sponsor.destroy

		redirect_to sport_sponsors_path(@sport), notice: "Ad Order Canceled"
  	end

	def create
		begin
			@sportadinv = @sport.sportadinvs.find(params[:adpayment][:sportadinv_id])
			@order = Adpayment.new(sportadinv_id: @sportadinv.id, sponsor_id: @sponsor.id)
			@order.attributes = params[:adpayment].merge(:ip_address => request.remote_ip)
			
			if @order.purchase(@sportadinv)
				payment = Adpayment.find_by(sponsor_id: @sponsor.id)

				if payment.nil?
					@order.expiration = DateTime.now + 1.year
				end

				if @order.save
					payment.destroy if !payment.nil?
					transfer_funds_to_program(@sponsor, User.find(@sport.adminid).paypal_email)

					redirect_to sport_sponsor_path(@sport, @sponsor)
				else
					raise 'failed to save'
				end
			else
				raise 'failed to purchase. ' + response.message
			end
		rescue Exception => e
			redirect_to sport_sponsor_path(@sport, @sponsor), alert: e.message
		end
			
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
			@sponsor = @sport.sponsors.find(params[:sponsor_id])
		end

		def transfer_funds_to_program(sponsor, email)
			adpercentage = (100 - Admin.first.adpercentage) / Float(100)
			payout = sponsor.sportadinv.price * adpercentage

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
				response = gateway.transfer(payout * 100, email, subject: sponsor.name, note: "Purchased ad level" + sponsor.sportadinv.adlevelname)
			end

			sponsor.sharetime = DateTime.parse(response.params["timestamp"])
			
			if response.success?
				sponsor.sharepaid = true
			else
				sponsor.sharepaid = false
			end

			sponsor.save
		end

end
