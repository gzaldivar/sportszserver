class BasketballStatsController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_stat, only: [:edit, :update, :destroy, :show]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		controller.team_manager?(@athlete, nil)
	end

	def newstat
		@gameschedule = Gameschedule.find(params[:gameschedule_id].to_s)
		@team = @sport.teams.find(@gameschedule.team_id)
		@athlete = Athlete.find(params[:athlete_id].to_s)

		if params[:livestats] == "Live"
			@live = "Live"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end

#		if @gameschedule.nil?
			@games = @sport.teams.find(@athlete.team_id.to_s).gameschedules.asc(:starttime)
#		else
			@bbstats = BasketballStat.new
#		end
	end

	def create
		begin
			if params[:basketball_stat].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:basketball_stat][:gameschedule_id].to_s)
				live = params[:basketball_stat][:livestats].to_s
			end

			if live == "Totals"
				bbstats = @athlete.basketball_stats.create!(params[:basketball_stat])
#				game.homescore = (bbstats.ftmade * 1) + (bbstats.twomade * 2) + (bbstats.threemade * 3)
#				game.homefouls = bbstats.fouls
			else
				bbstats = @athlete.basketball_stats.new(gameschedule_id: game.id.to_s)
				livestats(bbstats, @athlete, params)
#				game.homescore += params[:ftmade].to_i + (params[:twomade].to_i * 2) + (params[:threemade].to_i * 3)
#				game.homefouls += params[:fouls].to_i
				
			end

			if params[:threemade]
				game.lastplay = @athlete.logname + " 3PT"
			elsif params[:twomade]
				game.lastplay = @athlete.logname + " 2PT"
			elsif params[:ftmade]
				game.lastplay = @athlete.logname + " FT"
			elsif params[:fouls]
				game.lastplay = @athlete.logname + " Foul"
			end

			game.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @athlete, bbstats], notice: "Stat created for " + @athlete.logname }
				format.json { render status: 200, json: { bbstats: bbstats } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show
		@gameschedule = Gameschedule.find(@bbstats.gameschedule_id)
		@team = @sport.teams.find(@gameschedule.team_id)
	end

	def edit
		@gameschedule = Gameschedule.find(@bbstats.gameschedule_id.to_s)
		@team = @sport.teams.find(@gameschedule.team_id)

		if params[:livestats].nil?
			@live = nil
		elsif params[:livestats] == "Live"
			@live = "Live"
		else
			@live = "Totals"
		end
	end

	def update
		begin
			if params[:basketball_stat].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:basketball_stat][:gameschedule_id].to_s)
				live = params[:basketball_stat][:livestats].to_s
			end

			if live == "Totals"
#				game.homescore -= @bbstats.ftmade - (@bbstats.twomade * 2) - (@bbstats.threemade * 3)
#				game.homefouls -= @bbstats.fouls
				@bbstats.update_attributes!(params[:basketball_stat])
#				game.homescore += @bbstats.ftmade  + (@bbstats.twomade * 2) + (@bbstats.threemade * 3)
#				game.homefouls += @bbstats.fouls
			else
#				game.homescore -= params[:ftmade].to_i + (params[:twomade].to_i * 2) + (params[:threemade].to_i * 3)
#				game.homefouls -= params[:fouls].to_i
				livestats(@bbstats, @athlete, params)
#				game.homescore += params[:ftmade].to_i + (params[:twomade].to_i * 2) + (params[:threemade].to_i * 3)
#				game.homefouls += params[:fouls].to_i

			end

			if params[:threemade]
				game.lastplay = @athlete.logname + " 3PT"
			elsif params[:twomade]
				game.lastplay = @athlete.logname + " 2PT"
			elsif params[:ftmade]
				game.lastplay = @athlete.logname + " FT"
			elsif params[:fouls]
				game.lastplay = @athlete.logname + " Foul"
			end

			game.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @athlete, @bbstats], notice: "Stat created for " + @athlete.logname }
				format.json { render status: 200, json: { bbstats: @bbstats } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def index
		if params[:athlete_id]
			@athlete = @sport.athletes.find(params[:athlete_id].to_s)
		end

		if params[:gameschedule_id]
			@gameschedule = @sport.gameschedules.find(params[:gameschedule_id].to_s).asc(:starttime)
			@team = @sport.teams.find(@gameschedule.team_id)
		end

		if !@athlete.nil? and !@gameschedules.nil?
			@bballstats = []
			@bballstats[0] = @athlete.basketball_stats.where(gameschedule_id: @gameschedule.id.to_s)
		elsif !@athlete.nil?
			@bballstats = @athlete.basketball_stats
			@gameschedules = Gameschedule.where(team_id: @athlete.team_id).asc(:starttime)
		elsif !gameschedule.nil?
			@bballstats = @gameschedule.basketball_stats
			@athletes = Athlete.where(team_id: @gameschedule.team_id).asc(:number)
		end
			
		respond_to do |format|
			format.html
			format.json {
				stats = @bballstats
				@bballstats = []
				@gameschedules.each_with_index do |g, cnt|
					thestat = nil
					stats.each do |b|
						if g.id == b.gameschedule_id
							thestat = b
							break
						end
					end
					if thestat.nil?
						thestat = BasketballStat.new(gameschedule: g.id, athlete: @athlete.id)
					end
					@bballstats[cnt] = thestat
				end
			}
		end
	end

	def destroy
	end

	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def get_stat
			@bbstats = @athlete.basketball_stats.find(params[:id])
		end

		def livestats(bbstats, athlete, params)
			begin
				if params[:twoattempt].to_i == 1
					bbstats.twoattempt += 1
				end

				if params[:twomade].to_i == 1
					bbstats.twomade += 1
					if params[:twoattempt].to_i != 1
						bbstats.twoattempt += 1
					end
				end

				if params[:threeattempt].to_i == 1
					bbstats.threeattempt += 1
				end

				if params[:threemade].to_i == 1
					bbstats.threemade += 1
					if params[:threeattempt].to_i != 1
						bbstats.threeattempt += 1
					end
				end

				if params[:ftattempt].to_i == 1
					bbstats.ftattempt += 1
				end

				if params[:fouls].to_i == 1
					bbstats.fouls += 1
				end

				if params[:ftmade].to_i == 1
					bbstats.ftmade += 1
					if params[:ftattempt].to_i != 1
						bbstats.ftattempt += 1
					end
				end

				if params[:assists].to_i == 1
					bbstats.assists += 1
				end

				if params[:steals].to_i == 1
					bbstats.steals += 1
				end

				if params[:blocks].to_i == 1
					bbstats.blocks += 1
				end

				if params[:offrebound].to_i == 1
					bbstats.offrebound += 1
				end

				if params[:defrebound].to_i == 1
					bbstats.defrebound += 1
				end

				if params[:turnover].to_i == 1
					bbstats.turnovers += 1
				end

				bbstats.save!
			rescue Exception => e
				throw "Error updating live stats!"
			end
		end
end
