class StandingsController < ApplicationController
	before_filter	:authenticate_user! #,   only: [:destroy, :new, :edit, :update, :create]
  	before_filter :get_sport

  	def index
  		schedules = @team.gameschedules.desc(:opponent_league_wins)
      @gamerecords = []

      teamrecord = getgamerecord(schedules)

      opprecords = []
      schedules.each_with_index do |s, cnt|
        if s.league
          arecord = Gamerecord.new
          arecord.teamname = s.opponent
          arecord.mascot = s.opponent_mascot
          arecord.leaguewins = s.opponent_league_wins
          arecord.leaguelosses = s.opponent_league_losses
          arecord.nonleaguewins = s.opponent_nonleague_wins
          arecord.nonleaguelosses = s.opponent_nonleague_losses
          arecord.gameschedule_id = s.id
          arecord.teamid = s.opponent_team_id

          if s.opponentpic?
            arecord.oppimageurl = s.opponentpic.url(:thumb)
          elsif s.opponent_team_id
            oppsport = Sport.find(s.opponent_sport_id)
            oppteam = oppsport.teams.find(s.opponent_team_id)

            if oppteam.team_logo?
              arecord.oppimageurl = oppteam.team_logo.url(:thumb)
            else
              arecord.oppimageurl = oppsport.sport_logo.url(:thumb)
            end
          end

          if !s.opponent_sport_id.nil? 
            arecord.sportid = s.opponent_sport_id
          else
            arecord.sportid = nil
          end

          opprecords << arecord
        end
      end

      found = false
      opprecords.each_with_index do |r, cnt|
        if teamrecord.leaguewins > r.leaguewins and !found
          @gamerecords << teamrecord
          @gamerecords << opprecords[cnt]
          found = true
        else
          @gamerecords << opprecords[cnt]
        end
      end

      if !found
        @gamerecords << teamrecord
      end

      respond_to do |format|
        format.html
        format.json
      end
  	end

    def addgamerecord
        @gameschedule = @team.gameschedules.find(params[:gameschedule_id])
    end

    def savegamerecord
      begin
        game = @team.gameschedules.find(params[:gameschedule_id])
        game.opponent_league_wins = params[:league_wins].to_i
        game.opponent_league_losses = params[:league_losses].to_i
        game.opponent_nonleague_wins = params[:nonleague_wins].to_i
        game.opponent_nonleague_losses = params[:nonleague_losses].to_i
        game.save!

        respond_to do |format|
          format.html { redirect_to sport_team_standings_path(@sport, @team) }
          format.json { render status: 200, json: { game: game } }
        end
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to :back, alert: e.message }
          format.json { render status: 404, json: { error: e.message } }
        end
      end
    end

    def importteamrecord
      begin
        puts params[:gameschedule_id]
        gameschedule = @team.gameschedules.find(params[:gameschedule_id])
        puts gameschedule.opponent_mascot
        sport = Sport.find(gameschedule.opponent_sport_id)
        team = sport.teams.find(gameschedule.opponent_team_id)
        schedules = team.gameschedules.desc(:opponent_league_wins)
        teamrecord = getgamerecord(schedules)
        gameschedule.opponent_nonleague_losses = teamrecord.nonleaguelosses
        gameschedule.opponent_nonleague_wins = teamrecord.nonleaguewins
        gameschedule.opponent_league_wins = teamrecord.leaguewins
        gameschedule.opponent_league_losses = teamrecord.leaguelosses
        gameschedule.save!

        respond_to do |format|
          format.html { redirect_to sport_team_standings_path(@sport, @team) }
          format.json { render status: 200, json: { gameschedule: gameschedule } }
        end
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to :back, alert: e.message }
          format.json { render status: 404, json: { error: e.message } }
        end
      end
    end

  	private

  		def get_sport
    		@sport = Sport.find(params[:sport_id])
    		@team = @sport.teams.find(params[:team_id])
   		end

      def getgamerecord(schedules)
        teamwins = teamlosses = 0
        leaguewins = leaguelosses = 0

        schedules.each do |s|
          if s.homescore > s.opponentscore and s.league == true and s.final == true
            teamwins += 1
            leaguewins += 1
          elsif s.league and s.final
            teamlosses += 1
            leaguelosses += 1
          elsif s.homescore > s.opponentscore and s.final
            teamwins += 1
          elsif s.final
            teamlosses += 1
          end
        end

        teamrecord = Gamerecord.new
        teamrecord.teamname = @sport.sitename
        teamrecord.mascot = @sport.mascot
        teamrecord.leaguewins = leaguewins
        teamrecord.leaguelosses = leaguelosses
        teamrecord.nonleaguewins = teamwins
        teamrecord.nonleaguelosses = teamlosses
        return teamrecord
      end

end
