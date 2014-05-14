class PaymentsController < ApplicationController
#	include ActiveMerchant::Billing

	def new
		if params[:package] == "Intermediate"
			price = Payment.new.silver
			package = "Intermediate"
		elsif params[:package] == "Intermediate to Expert"
			price = Payment.new.silvergold
			package = "Upgrade Intermediate to Expert"
		elsif params[:package] == "Expert"
			price = Payment.new.gold
			package = "Expert"
		elsif params[:package] == "Expert to Platinum"
			price = Payment.new.goldplatinum
			package = "Upgrade Expert to Platinum"
		else
			price = Payment.new.platinum
		end

		response = EXPRESS_GATEWAY.setup_purchase(
			price,
			ip: request.remote_ip,
			return_url: params[:package] == "Intermediate" ? confirmsilver_payments_url : params[:package] == "Intermediate to Expert" ? 
						confirmsilvergold_payments_url : params[:package] == "Expert" ? confirmgold_payments_url : 
						params[:package] == "Expert to Platinum" ? confirmgoldplatinum_payments_url : confirmplatinum_payments_url,
			cancel_return_url: cancel_payments_url,
			allow_guest_checkout: 'true',				   #payment with credit card for non PayPal users
			items: [ { name: package, description: "Game Tracker - " + package, quantity: "1", 
						amount: params[:package] == "Intermediate" ? 5900 : params[:package] == "Intermediate to Expert" ? 4000 : 
						params[:package] == "Expert" ? 9900 : params[:package] == "Expert to Platinum" ? 5000 : 14900 } ] #array of hashes, amount is a price in cents
		)
		redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
	end

	def confirmsilver
		@order = Payment.new
		@order.express_token = params[:token]
		@price = @order.silver/100
		@order.package = "Intermediate"
		render 'confirm'
	end

	def confirmsilvergold
		@order = Payment.new
		@order.express_token = params[:token]
		@price = 40
		@order.package = "Intermediate to Expert"
		render 'confirm'
	end

	def confirmgold
		@order = Payment.new
		@order.express_token = params[:token]
		@price = @order.gold/100
		@order.package = "Expert"
		render 'confirm'
	end

	def confirmgoldplatinum
		@order = Payment.new
		@order.express_token = params[:token]
		@price = 50
		@order.package = "Expert to Platinum"
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
  		begin
			if params[:payment_id].nil?
				@order = Payment.new(user_id: current_user.id)
				@order.package = "Basic"
			else
	    		@order = Payment.find(params[:payment_id])
	    	end  			
  		rescue Exception => e
  			redirect_to :back, alert: e.message
  		end
  	end

  	def index
  	end

	def cancel
		redirect_to root_path, notice: "Order Canceled"
  	end

	def create
		begin
			@order = Payment.new(user_id: current_user.id)
			@order.attributes = params[:payment].merge(:ip_address => request.remote_ip)
			
			if @order.purchase(params[:payment][:package])
				@order.package = params[:payment][:package]

				payment = Payment.find_by(user_id: current_user.id)

				if payment.nil?
					@order.expiration = DateTime.now + 1.year
				elsif @order.package != "Intermediate to Expert" and @order.package != "Expert to Platinum"
					@order.expiration = payment.expiration + 1.year
				end

				if params[:payment][:package] == "Intermediate to Expert"
					@order.package = "Expert"
				elsif params[:payment][:package] == "Expert to Platinum"
					@order.package = "Platinum"
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
		rescue Exception => e
			redirect_to :back, alert: e.message
		end
	end

end
