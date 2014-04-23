class SponsorsController < ApplicationController
	before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy, :add, :createad]
  	before_filter :get_sport
  	before_filter :get_sponsor,		only: [:edit, :show, :destroy, :update, :updatephoto]
	before_filter only: [:new, :create, :edit, :update, :destroy] do |controller|
		SiteOwner?(current_user.teamid)
	end
#	before_filter only: [:destroy, :update, :create, :edit, :new, :createphoto, :updatephoto] do |check|
#		check.sponsorEnabled?(current_site)
#	end

	def info
		@sportadinvs = @sport.sportadinvs.all.asc(:price).paginate( page: params[:page])
	end

	def add
		@sponsor = Sponsor.new
	end

	def createad
		begin			
			@sponsor = @sport.sponsors.build(params[:sponsor])
			@sponsor.city = @sponsor.zip.to_region(city: true)
        	@sponsor.state = @sponsor.zip.to_region(state: true)

			if !params[:team_id].nil? and !params[:team_id].blank?
				@sponsor.team_id = params[:team_id]
			end

			@sponsor.save!

			redirect_to new_sport_sponsor_adpayment_path(@sport, @sponsor, sportadinv_id: @sponsor.sportadinv_id.to_s)
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error adding Ad " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def new
		@sponsor = Sponsor.new
	end

	def create
		begin
			@sponsor = @sport.sponsors.build(params[:sponsor])
			@sponsor.city = @sponsor.zip.to_region(city: true)
        	@sponsor.state = @sponsor.zip.to_region(state: true)

			if !params[:team_id].nil? and !params[:team_id].blank?
				@sponsor.team_id = params[:team_id]
			end

			@sponsor.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @sponsor], notice: "Added #{@sponsor.name}!" }
				format.json { render status: 200, json: { sponsor: @sponsor } }
			end

		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error adding Sponsor " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def edit
	end

	def update
		begin
			@sponsor.update_attributes!(params[:sponsor])
			@sponsor.city = @sponsor.zip.to_region(city: true)
        	@sponsor.state = @sponsor.zip.to_region(state: true)
        	@sponsor.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @sponsor], notice: "Sponsor updated!" }
				format.json { render status: 200, json: { sponsor: @sponsor } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error adding Sponsor " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def index
		begin
			if isAdmin?
				@sponsors = @sport.sponsors.all
				@totals = 0
				@sponsors.each do |s|
					@totals += s.sportadinv.price
				end
			else
				@sponsors = @sport.sponsors.where(adminentered: false)
			end
			respond_to do |format|
				format.html
				format.json
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

	def destroy
		begin
			@sponsor.destroy

			respond_to do |format|
				format.html { redirect_to sport_sponsors_path(@sport), alert: "Sponsor delete sucessful!" }
				format.json { render status: 200, json: { success: "success" } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error deleting Sponsor " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def createphoto
		begin
			path = CGI.unescape(params[:filepath]).split('/')
			@sponsor = @sport.sponsors.find(path[4])    
			path = params[:filepath].split('/')
			imagepath = CGI.unescape(path[2])
			@sponsor.processing = true

			@sponsor.save!

			queue = @sport.photo_queues.new(modelid: @sponsor.id, modelname: "sponsors", filename: params[:filename], filetype: params[:filetype], 
											filepath: imagepath)
			if queue.save!
				Resque.enqueue(PhotoProcessor, queue.id)
			end
		rescue Exception => e
		  puts e.message
		end
	end

	def updatephoto
		begin    
			@sponsor.processing = true

			@sponsor.save!

			queue = @sport.photo_queues.new(modelid: @sponsor.id, modelname: "sponsors", filename: params[:filename], filetype: params[:filetype], 
			                              filepath: params[:filepath])
			if queue.save!
				Resque.enqueue(PhotoProcessor, queue.id)
			end

			respond_to do |format|
				format.json { render json: { success: "success", sponsor: @sponsor } }
			end
		rescue Exception => e
			respond_to do |format|
				format.json { render status: 404, json: { error: e.message, sponsor: @sponsor } }
			end
		end
	end
  
	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def get_sponsor
			@sponsor = @sport.sponsors.find(params[:id])
		end
end
