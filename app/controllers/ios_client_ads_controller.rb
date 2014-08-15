class IosClientAdsController < ApplicationController
	before_filter :authenticate_user!,	only: [:update, :edit, :create, :destroy, :process_payments]
	before_filter :isGod?, only: [:update, :edit, :create, :destroy]
	before_filter :getAdmin
	before_filter :getIOSAd, only: [:show, :update, :destroy, :edit]

	include AdsponsorPayout

	def new
		@product = IosClientAd.new
	end

	def create
		begin
			product = @admin.ios_client_ads.create!(params[:ios_client_ad])

			respond_to do |format|
				format.html { redirect_to admin_ios_client_ad_path(@admin, product), notice: "IOS product created!" }
				format.json { render status: 200, json: { product: product } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to admin_ios_client_ads_path(@admin), alert: "Error creating IOS product - " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def edit
	end

	def show
	end

	def update
		begin
			@product.update_attributes!(params[:ios_client_ad])

			respond_to do |format|
				format.html { redirect_to admin_ios_client_ad_path(@admin, @product), notice: "IOS product created!" }
				format.json { render status: 200, json: { product: prodcut } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to admin_ios_client_ad_path(@admin, @product), alert: "Error creating IOS prodcuct - " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def index
		@products = IosClientAd.all
	end

	def destroy
		begin
			@product.destroy

			respond_to do |format|
				format.html { redirect_to admin_ios_client_ads_path(@admin), notice: "Delete Succesful" }
				format.json { render status: 200, json: { success: "Delete Succesful" } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to admin_ios_client_ad_path(@admin), alert: "Error Deleting IOS Product - " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def process_payments
		@iosads = Sponsor.where(:ios_client_ad.exists => true, sharepaid: false)

		@iosads.each do |adsponsor|
			transfer_ad_payment(adsponsor, User.find(adsponsor.sport.adminid).paypal_email)
		end
	end

	private

		def getAdmin
			@admin = Admin.find(params[:admin_id])
		end

		def getIOSAd
			@product = @admin.ios_client_ads.find(params[:id])
		end
end
