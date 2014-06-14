class SportadinvsController < ApplicationController

	before_filter :authenticate_user!,   only: [:destroy, :new, :edit, :update, :create]
	before_filter :get_sport
	before_filter :correct_sportadinv, only: [:edit, :show, :update, :destroy]

	def new
    	@sportadinv = @sport.sportadinvs.new
	end

	def edit
	end

	def create
		begin
			player = @sport.sportadinvs.where(athlete_id: params[:athlete_id]).all

			if player.count > 0
	    		sportadinv = @sport.sportadinvs.create!(params[:sportadinv])

	    		respond_to do |format|
					format.html { redirect_to [@sport, sportadinv], notice: "Ad Level created for " + @sport.name }
					format.json { render json: { sportadinv: sportadinv } }
				end
			else
				raise "Player ad already defined. You must delete or edit the existing player ad."
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
 	end

	def show
	end

	def index
		begin
			@sportadinvs = @sport.sportadinvs.all.asc(:price).paginate( page: params[:page])
			@inapp_products = Admin.first.ios_client_ads.asc(:price)
		rescue Exception => e
			redirect_to :back, alert: e.message + " You can so by editing you user profile."
		end
	end

	def update
		begin
    		sportadinv = @sportadinv.update_attributes!(params[:sportadinv])

    		respond_to do |format|
				format.html { redirect_to [@sport, @sportadinv], notice: "Ad Level updated for " + @sport.name }
				format.json { render json: { sportadinv: @sportadinv } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

		def destroy
		begin
			@sportadinv.destroy

			respond_to do |format|
				format.html { redirect_to sport_sportadinvs_path(@sport), notice: "Ad entry deleted" }
				format.json { render json: { success: "success" } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_sportadinvs_path(@sport), alert: "Error deleting ad entry: " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def correct_sportadinv
			@sportadinv = @sport.sportadinvs.find(params[:id])
		end

end
