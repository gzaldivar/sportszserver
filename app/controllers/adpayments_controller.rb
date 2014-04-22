class AdpaymentsController < ApplicationController

	def new
		sportadinv = @sport.sportadinvs.find(params[:sportadinv])

		response = EXPRESS_GATEWAY.setup_purchase(
			sportadinv.price,
			ip: request.remote_ip,
			return_url: confirm_adpayments_url,
			cancel_return_url: cancel_payments_url,
			allow_guest_checkout: 'true',				   #payment with credit card for non PayPal users
			items: [ { name:sportadinv.adlevelname, quantity: "1", amount: sportadinv.priceincents, custom: sportadinv.id.to_s } ] #array of hashes, amount is a price in cents
		)
		redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
	end

	def confirm
		@order = Adpayment.new
		@sportadinv = @sport.sportadinvs.find(params[:custom])
		@order.express_token = params[:token]
		@price = @order.price/100
		render 'confirm'
	end

	def show
   		@order = Adpayment.find(params[:id])
   		@sportadinv = @sport.sportadinvs.find(@order.sportadinv)
   		@sponsor = @sport.sponsors.find(@sportadinv.sponsor_id)
   		redirect_to sport_sponsor_path(@sport, @sponsor)
  	end

  	def index
  	end

	def cancel
		@sportadinv = @sport.sportadinv.find(params[:custom])
		@sponsor = @sport.sponsors.find(@sportadinv.sponsor_id)

		redirect_to sport_sponsors_path(@sport), notice: "Ad Order Canceled"
  	end

	def create
		@sportadinv = params[:sportadinv_id]
		@order = Adpayment.new(sportadinv_id: @sportadinv.id)
		@order.attributes = params[:adpayment].merge(:ip_address => request.remote_ip)
		
		if @order.purchase(@sportadinv)
			@order.sportadinv = @sportadinv.adlevelname

			payment = Adpayment.find_by(sportadinv_id: @sportadinv.id)

			if payment.nil?
				@order.expiration = DateTime.now + 1.year
			end

			if @order.save
				payment.destroy if !payment.nil?

				redirect_to adpayment_path(@order)
			else
				raise 'failed to save'
			end
		else
			raise 'failed to purchase. ' + response.message
		end
	end

end
