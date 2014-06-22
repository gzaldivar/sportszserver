class SponsorsController < ApplicationController
	before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy, :createad, :add]
  	before_filter :get_sport
  	before_filter :get_sponsor,		only: [:edit, :show, :destroy, :update, :updatephoto]

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
		@sponsor.sportadinv_id = params[:sportadinv_id] if params[:sportadinv_id]
		@playerad = true if params[:playerad]
	end

	def create
		begin
			@sponsor = @sport.sponsors.build(params[:sponsor])

			if params[:zip]
				@sponsor.city = @sponsor.zip.to_region(city: true)
        		@sponsor.state = @sponsor.zip.to_region(state: true)
        	end

			if !params[:team_id].nil? and !params[:team_id].blank?
				@sponsor.team_id = params[:team_id]
			end

			if (!@sponsor.ios_client_ad.nil? and @sponsor.ios_client_ad.playerad) or (!@sponsor.sportadinv.nil? and @sponsor.sportadinv.playerad)
				@sponsor.save(validate: false)
			else
				@sponsor.save!
			end

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
			if (!@sponsor.ios_client_ad.nil? and @sponsor.ios_client_ad.playerad) or (!@sponsor.sportadinv.nil? and @sponsor.sportadinv.playerad)
				@sponsor.attributes = params[:sponsor]
				@sponsor.save(validate: false)
			else
				@sponsor.update_attributes!(params[:sponsor])
			end

			if params[:zip]
				@sponsor.city = @sponsor.zip.to_region(city: true)
        		@sponsor.state = @sponsor.zip.to_region(state: true)
				@sponsor.save!
        	end

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
			if !isAdmin?
				if params[:user]
					@websponsors = @sport.sponsors.where(user_id: params[:user], :sportadinv.exists => true).paginate(page: params[:page])
					@inapsponsors = @sport.sponsors.where(user_id: params[:user], :ios_client_ad.exists => true).paginate(page: params[:page])
				else
					sortsponsors
				end
			else
				sortsponsors
				@webtotals = @inaptotals = @totals = 0
				
				if !@websponsors.nil?
					@websponsors.each do |s|
						@webtotals += s.sportadinv.price
					end
				end

				if !@inapsponsors.nil?
					@inapsponsors.each do |s|
						@inaptotals += s.ios_client_ad.price
					end
				end

				@totals = @webtotals + @inaptotals
			end

			respond_to do |format|
				format.html { 	if !@websponsors.nil?
									@websponsors.sort! { |a,b| a.sportadinv.price <=> b.sportadinv.price }
							  	end
							  	if !@inapsponsors.nil?
							  		@inapsponsors.sort! { |a,b| a.ios_client_ad.price <=> b.ios_client_ad.price }
							  	end }
				format.json { @sponsors = (@websponsors << @inapsponsors).flatten }
#			    format.csv { send_data @websponsors.to_csv }
			    format.xls { @sponsors = (@websponsors << @inapsponsors).flatten }
			end	
		rescue Exception => e
			respond_to do |format|
				format.html { flash[:alert] = e.message }
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

			if (!@sponsor.ios_client_ad.nil? and @sponsor.ios_client_ad.playerad) or (!@sponsor.sportadinv.nil? and @sponsor.sportadinv.playerad)
				@sponsor.save(validate: false)
			else
				@sponsor.save!
			end

			if params[:sponsorimage] == "sponsorbanner"
				queue = @sport.photo_queues.new(modelid: @sponsor.id, modelname: "sponsorbanner", filename: params[:filename], filetype: params[:filetype], 
			                            		filepath: params[:filepath])
			else
				queue = @sport.photo_queues.new(modelid: @sponsor.id, modelname: "sponsors", filename: params[:filename], filetype: params[:filetype], 
			                            		filepath: params[:filepath])
			end

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

		def sortsponsors
			@websponsors = nil
			@inapsponsors = nil

			if !params[:sortcriteria].blank? and !params[:month].blank? and !params[:year].blank?

				if params[:sortcriteria] == "Ap Purchased"
					@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, params[:month].to_i, 1)).paginate(page: params[:page])
				elsif params[:sortcriteria] == "Web Purchased"
					@websponsors = @sport.sponsors.where(:sportadinv.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, params[:month].to_i, 1)).paginate(page: params[:page])
				elsif params[:sortcriteria] == "All"
					@websponsors = @sport.sponsors.where(:sportadinv.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, params[:month].to_i, 1)).paginate(page: params[:page])
					@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, params[:month].to_i, 1)).paginate(page: params[:page])
				end

			elsif !params[:sortcriteria].blank? and !params[:year].blank?

				if params[:sortcriteria] == "Ap Purchased"
					@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, 1, 1)).paginate(page: params[:page])
				elsif params[:sortcriteria] == "Web Purchased"
					@websponsors = @sport.sponsors.where(:sportadinv.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, 1, 1)).paginate(page: params[:page])
				elsif params[:sortcriteria] == "All"
					@websponsors = @sport.sponsors.where(:sportadinv.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, 1, 1)).paginate(page: params[:page])
					@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, 1, 1)).paginate(page: params[:page])
				end

			elsif !params[:sortcriteria].blank? and !params[:month].blank?
				raise 'Please enter a year!'
			elsif !params[:month].blank? and !params[:year].blank?
				@websponsors = @sport.sponsors.where(:sportadinv.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, params[:month].to_i, 1)).paginate(page: params[:page])
				@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, params[:month].to_i, 1)).paginate(page: params[:page])
			elsif !params[:sortcriteria].blank?

				if params[:sortcriteria] == "Ap Purchased"
					@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true).paginate(page: params[:page])
				elsif params[:sortcriteria] == "Web Purchased"
					@websponsors = @sport.sponsors.where(:sportadinv.exists => true).paginate(page: params[:page])
				elsif params[:sortcriteria] == "All"
					@websponsors = @sport.sponsors.where(:sportadinv.exists => true).paginate(page: params[:page])
					@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true).paginate(page: params[:page])
				end

			elsif !params[:month].blank?
				raise 'Please enter a year!'
			elsif !params[:year].blank?
				@websponsors = @sport.sponsors.where(:sportadinv.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, 1, 1)).paginate(page: params[:page])
				@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true, 
											:updated_at.gte => DateTime.new(params[:year].to_i, 1, 1)).paginate(page: params[:page])
			else
				@websponsors = @sport.sponsors.where(:sportadinv.exists => true).paginate(page: params[:page])
				@inapsponsors = @sport.sponsors.where(:ios_client_ad.exists => true).paginate(page: params[:page])
			end
		end
end
