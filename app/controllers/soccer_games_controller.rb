class SoccerGamesController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport
  	before_filter	:get_game, only: [:show, :update, :changeperiod, :substitute_player, :addsubstitute_player, :deletesub]
	before_filter only: [:update, :show, :changeperiod, :addsubstitute_player] do |controller| 
		controller.SiteOwner?(@gameschedule.team_id)
	end

	def index
		@soccer_game = @gameschedule.soccer_game
		@players = @sport.athletes.where(team_id: @team.id)
		@homesubs = @soccer_game.soccer_subs.where(home: true).asc(:gametime)
		@visitorsubs = @soccer_game.soccer_subs.where(home: false).asc(:gametime)
		
		if @gameschedule.soccer_game.visiting_team
			@visiting_team = VisitingTeam.find(@gameschedule.soccer_game.visiting_team_id)
		end

		if @visiting_team
			visitorstats = @soccer_game.soccer_stats.where(:visiting_team.exists => true)
			visitorscores = []
			@visitorpenalties = []

			visitorstats.each do |v|
				visitorscores << v.soccer_scorings if v.soccer_scorings
				@visitorpenalties << v.soccer_penalties if v.soccer_penalties
			end
		end

		homestats = @soccer_game.soccer_stats.where(:visiting_team.exists => false)
		homescores = []
		@homepenalties = []

		homestats.each do |h|
			homescores << h.soccer_scorings if h.soccer_scorings

			if h.soccer_penalties
				h.soccer_penalties.each do |p|
					@homepenalties << p
				end
			end
		end

		if visitorscores.nil?
			@totalscores = homescores.flatten
		else
			@totalscores = (homescores << visitorscores).flatten
		end

		if !@totalscores.nil?
			@totalscores = @totalscores.sort! { |a,b| a.gametime <=> b.gametime }
		end

		if @homepenalties.any?
			@homepenalties = @homepenalties.sort! { |a,b| a.gametime <=> b.gametime }
		end

		if !@visitorpenalties.nil?
			@visitorpenalties.flatten
			@visitorpenalties = @visitorpenalties.sort! { |a,b| a.gametime <=> b.gametime }
		end

		if params[:period]
			@period = params[:period].to_i
		else
			@period = 1
		end
	end

	def update
		begin
			@soccer_game.update_attributes!(params[:soccer_game])

			if params[:home] and params[:home] == sport_home_team
				if @soccer_game.homeplayers.nil?
					@soccer_game.homeplayers = []
				end

				params[:players].each do |p|
					@soccer_game.homeplayers << p
				end

				@soccer_game.save!
			elsif params[:home] and params[:home] == sport_visitor_team
				if @soccer_game.visitorplayers.nil?
					@soccer_game.visitorplayers = []
				end

				params[:players].each do |p|
					@soccer_game.visitorplayers << p
				end

				@soccer_game.save!
			end

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: 'Update Succesful!' }
				format.json { render status: 200, json: { soccer_game: @soccer_game } }
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

	def changeperiod
		redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game, period: params[:period])
	end

	def substitute_players
		@subs = @soccer_game.soccer_subs.all.asc(:gametime)
	end

	def addsubstitute_player
		subs = @soccer_game.soccer_subs.new(inplayer: params[:inplayer], outplayer: params[:outplayer], gametime: params[:minutes] + ':' + params[:seconds])

		if params[:home] == sport_home_team
			subs.home = true
		else
			subs.home = false
		end

		subs.save!

		begin
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game) }
				format.json { render status: 200, json: { soccer_subs: subs } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def deletesub
		begin
			@gameschedule.soccer_game.soccer_subs.find(params[:subs]).destroy

			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: 'Substitute deleted!' }
				format.json { render status: 200, json: { success: 'success' } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_team_gameschedule_soccer_games_path(@sport, @team, @gameschedule, @soccer_game), notice: 'Substitute deleted!' }
				format.json { render status: 404, json: { error: e.message} }
			end
		end
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
			@team = @sport.teams.find(params[:team_id])
			@gameschedule = @team.gameschedules.find(params[:gameschedule_id])
		end

		def get_game
			@soccer_game = @gameschedule.soccer_game
		end

end
