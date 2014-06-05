class LacrosstatsController < ApplicationController

	include LacrosseStatistics

	before_filter	:authenticate_user!, only: [:destroy]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_lacrossestats, only: [:destroy]
	before_filter 	only: [:destroy] do |controller| 
		controller.SiteAdmin?(@sport)
	end

	def destroy
		begin
			@team = @sport.teams.find(@athlete.team_id)
			
			@gameschedule = Gameschedule.where('lacross_game._id' => Moped::BSON::ObjectId(@lacrossestats.lacross_game_id)).first

			if params[:lacross_scoring_id]
				scorestat  @lacrossestats.lacross_scorings.find(params[:lacross_scoring_id])
				playerstat = @lacrossestats.lacross_player_stats.find_by(period: scorestat.period)

				if playerstat.shot.count > 0
					cnt = 0

					playerstat.shot.each do |p|
						if p == 'G'
							break
						else
							cnt += 1
						end
					end

					playerstat.shot.delete_at(cnt)
					playerstat.save!
				end

				scorestat.destroy
			elsif params[:lacross_penalty_id]
				@lacrossestats.lacross_penalties.find(params[:lacross_penalty_id]).destroy
			elsif params[:lacross_goalstat_id]
				@lacrossestats.lacross_goalstats.find(params[:lacross_goalstat_id]).destroy
			elsif params[:lacross_player_stat_id]
				@lacrossestats.lacross_player_stats.find(params[:lacross_player_stat_id]).destroy
			else
				@lacrossestats.destroy
			end

			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "Stat deleted!" }
				format.json { render status: 200, json: { success: "success" } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def remove_allshots
		begin
			stat = @lacrossetats.lacross_player_stats.find(params[:lacross_player_stat_id])
			stat.shot = []
			stat.save!
			
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), notice: "All shots deleted for player!" }
				format.json { render status: 200, json: { success: "success" } }
			end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to lacrossescoresheet_sport_team_gameschedule_path(@sport, @team, @gameschedule), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end		
	end

	private

		def createGamelog(lacrosse, game, time)
			game.gamelogs.create!(period: game.currentperiod.to_s, time: time, logentry: "Goal Scored", score: "Goal", lacrosse_id: lacrosse.id)
		end

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def get_lacrossestats
			@lacrossestats = @athlete.lacrosstats.find(params[:id])
		end

end
