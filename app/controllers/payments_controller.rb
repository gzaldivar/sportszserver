class PaymentsController < ApplicationController
#	include ActiveMerchant::Billing

	def new
		if params[:package] == "Silver"
			price = Payment.new.silver
		elsif params[:package] == "Gold"
			price = Payment.new.gold
		else 
			price = Payment.new.platinum
		end

		response = EXPRESS_GATEWAY.setup_purchase(
			price,
			ip: request.remote_ip,
			return_url: params[:package] == "Silver" ? confirmsilver_payments_url : params[:package] == "Gold" ? confirmgold_payments_url : 
														confirmplatinum_payments_url,
			cancel_return_url: cancel_payments_url,
			allow_guest_checkout: 'true',				   #payment with credit card for non PayPal users
			items: [ { name: params[:package], description: "Eazesportz - " + params[:package], quantity: "1", 
						amount: params[:package] == "Silver" ? 4900 : params[:package] == "Gold" ? 9900 : 24900 } ] #array of hashes, amount is a price in cents
		)
		redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
	end

	def confirmsilver
		@order = Payment.new
		@order.express_token = params[:token]
		@price = @order.silver/100
		@order.package = "Silver"
		render 'confirm'
	end

	def confirmgold
		@order = Payment.new
		@order.express_token = params[:token]
		@price = @order.gold/100
		@order.package = "Gold"
		render 'confirm'
	end

	def confirmplatinum
		@order = Payment.new
		@order.express_token = params[:token]
		@price = @order.platinum/100
		@order.package = "Platinum"
		render 'confirm'
	end

	def show
   		@order = Payment.find(params[:id])
  	end

  	def upgrade
		if params[:payment_id].nil?
			@order = Payment.new(user_id: current_user.id)
			@order.package = "Basic"
		else
    		@order = Payment.find(params[:payment_id])
    	end
  	end

  	def index
  	end

	def cancel
		redirect_to root_path, notice: "Order Canceled"
  	end

	def create
#		begin
			@order = Payment.new(user_id: current_user.id)
			@order.attributes = params[:payment].merge(:ip_address => request.remote_ip)
			
			if @order.purchase(params[:payment][:package])
				@order.package = params[:payment][:package]

				payment = Payment.find_by(user_id: current_user.id)

				if payment.nil?
					@order.expiration = DateTime.now + 1.year
				else
					@order.expiration = payment.expiration + 1.year
				end

				if current_user.default_site
					@order.sport_id = Sport.find(current_user.default_site).id
				end

				if @order.save
					payment.destroy if !payment.nil?

					redirect_to payment_path(@order)
				else
					raise 'failed to save'
				end
			else
				raise 'failed to purchase. ' + response.message
			end
#		rescue Exception => e
#			redirect_to :back, alert: e.message
#		end
	end

end
