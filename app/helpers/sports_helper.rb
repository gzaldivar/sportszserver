module SportsHelper
    
  def deletesport(sport)
    current_user.default_site = ""
    current_user.save!
  end

  def find_a_sport(thesport)
    sports = []
    if !params[:zip].blank? and !params[:city].blank? and !params[:state].blank? and !params[:sitename].blank?
      site = Sport.where(name: thesport).full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s + " " + 
            params[:sitename].to_s, match: :all)      
    elsif !params[:zip].blank? and !params[:city].blank? and !params[:state].blank?
      site = Sport.where(name: thesport).full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s, match: :all)
    elsif !params[:zip].blank?
      site = Sport.where(name: thesport).full_text_search(params[:zip].to_s)
    elsif !params[:city].blank?
      site = Sport.where(name: thesport).full_text_search(params[:city].to_s)
    elsif !params[:state].blank?
      site = Sport.where(name: thesport).full_text_search(params[:state].to_s)
    elsif !params[:sitename].blank?
      site = Sport.where(name: thesport).full_text_search(params[:sitename].to_s)
    elsif params[:all]
      site = Sport.where(name: thesport)
     end

    if site 
      site.each_with_index do |s, cnt|
         sports[cnt] = s
      end
    end

    return sports
  end
  
  def sports_list
    [
      ['Football', 'Football'],
      ['Basketball', 'Basketball'],
      ['Soccer', 'Soccer']
#      ['Baseball', 'Baseball']
    ]
  end

  def offense_football_positions
    [
      ['Running Back', 'RB'],
      ['Tail Back', 'TB'],
      ['Fullback', 'FB'],
      ['Quarterback', 'QB'],
      ['Offesnsive Line', 'OL'],
      ['Center', 'C'],
      ['Guard', 'G'],
      ['Tackle', 'T'],
      ['Wide Receiver', 'WR'],
      ['Tight End', 'TE']
    ]
  end

  def defense_football_positions
    [
      ['Defensive Line', 'DL'],
      ['Nose Guard', 'NG'],
      ['Defensive Tackle', 'DT'],
      ['Defensive End', 'DE'],
      ['Line Backer', 'LB'],
      ['Defensive Back', 'DB'],
      ['Corner', 'CB'],
      ['Safety', 'S'],
      ['Strong Safety', 'SS']
    ]
  end

  def specialteams_football_positions
    [      
      ['Kicker', 'K'],
      ['Place Kicker', 'PK'],
      ['Punter', 'P'],
      ['Returner', "RET"],
      ['Kicker/Punter', 'KP'],
      ['Kicker/Punter/Place Kicker', 'PKP']
    ]
  end

  def football_score
    [
      ["TD", "TD"],
      ["FG", "FG"],
      ["XP", "XP"],
      ["2P", "2P"],
      ["S", "S"]
    ]
  end

  def basketball_positions
    [
      ['Center','C'],
      ['Guard', 'G'],
      ['Forward', 'F'],
      ['Guard/Forward', 'G/F']
    ]
  end

  def quarters
    [
      ["First", "Q1"],
      ["Second", "Q2"],
      ["Third", "Q3"],
      ["Fourth", "Q4"]
    ]
  end

  def halfs
    [
      ["First Half", "1"],
      ["Second Half", "2"]
    ]
  end

  def soccer_positions
    [
      ['Goal Keeper','GK'],
      ['Sweeper', 'SWEP'],
      ['Defender', 'D'],
      ['Mid Fielder', 'MF'],
      ['Forward', 'FORW'],
      ['Fullback', 'FB'],
      ['Stryker', 'STRK']
    ]
  end
  
end
