class StandingsController < ApplicationController
    before_filter	:authenticate_user!,   only: [:destroy, :new, :edit, :update, :create]
  	before_filter :get_sport

  	def index
  		schedules = @team.gameschedules.desc(:opponent_league_wins)
      puts schedules.count
      @gamerecords = []

      teamrecord = getgamerecord(@sport, schedules)
      teamrecord.oppimageurl = get_tiny_team_logo(@sport, @team)
      @gamerecords << teamrecord

      schedules.each_with_index do |s, cnt|
        if s.league
          arecord = Gamerecord.new
          arecord.teamname = s.opponent
          arecord.mascot = s.opponent_mascot

          arecord.gameschedule_id = s.id

          if s.opponent_team_id
            arecord.teamid = s.opponent_team_id
            oppsport = Sport.find(s.opponent_sport_id)
            oppteam = oppsport.teams.find(s.opponent_team_id)
            oppsport = Sport.find(s.opponent_sport_id)
            oppschedule = oppsport.teams.find(s.opponent_team_id).gameschedules
            arecord = getgamerecord(oppsport, oppschedule)
            arecord.sportid = s.opponent_sport_id
          else 
            puts s.opponent_league_wins
            puts s.opponent_mascot
            arecord.leaguewins = s.opponent_league_wins
            arecord.leaguelosses = s.opponent_league_losses
            arecord.nonleaguewins = s.opponent_nonleague_wins
            arecord.nonleaguelosses = s.opponent_nonleague_losses
            arecord.leagueties = s.opponent_leagueties
            arecord.nonleagueties = s.opponent_nonleagueties
            arecord.sportid = nil
          end
 
          arecord.oppimageurl = opponentimage(s)
          @gamerecords << arecord
        end
      end

      @gamerecords.sort_by! { |a| -a.leaguewins }

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
        gameschedule = @team.gameschedules.find(params[:gameschedule_id])
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

      def getgamerecord(sport, schedules)
        teamwins = teamlosses = 0
        leaguewins = leaguelosses = 0
        leagueties = nonleagueties = 0

        schedules.each do |s|
          stat = StatTotal.new(@sport, s)

          homescore = 0

          if sport.name == "Basketball"
            homescore = basketball_home_score(sport, s)
          elsif sport.name == "Soccer"
            homescore = soccer_home_score(sport, s)
          elsif sport.name == "Football"
            homescore = footballhomescore(sport, s)
          end

          if homescore > s.opponentscore and s.league == true and s.final == true
            teamwins += 1
            leaguewins += 1
          elsif homescore < s.opponentscore and s.league and s.final
            teamlosses += 1
            leaguelosses += 1
          elsif homescore > s.opponentscore and s.final
            teamwins += 1
          elsif homescore < s.opponentscore and s.final
            teamlosses += 1
          elsif homescore == s.opponentscore and s.league and s.final
            leagueties += 1
          elsif homescore == s.opponentscore and s.final
            nonleagueties += 1
          end
        end

        teamrecord = Gamerecord.new
        teamrecord.teamname = sport.sitename
        teamrecord.mascot = sport.mascot
        teamrecord.leaguewins = leaguewins
        teamrecord.leaguelosses = leaguelosses
        teamrecord.nonleaguewins = teamwins
        teamrecord.nonleaguelosses = teamlosses
        teamrecord.leagueties = leagueties
        teamrecord.nonleagueties = nonleagueties
        return teamrecord
      end
=begin
            arecord.sportid = s.opponent_sport_id
            oppsport = Sport.find(s.opponent_sport_id)
            oppschedule = oppsport.teams.find(s.opponent_team_id).gameschedules

            oppschedule.each do |g|
              homescore = 0
              if g.gameisfinal
                if @sport.name == "Football"
                  homescore = footballhomescore(oppsport, g)
                elsif @sport.name == "Basketball"
                  homescore = basketball_home_score(oppsport, g)
                elsif @sport.name == "Soccer"
                end

                if homescore > g.opponentscore and g.league and g.gameisfinal
                  arecord.leaguewins += 1
                elsif homescore > g.opponentscore and g.gameisfinal
                  arecord.nonleaguewins += 1
                elsif homescore < g.opponentscore and g.league and g.gameisfinal
                  arecord.leaguelosses += 1
                elsif homescore < g.opponentscore and g.gameisfinal
                  arecord.nonleaguelosses += 1
                end
              end

              opprecords << arecord
            end
=end

end
