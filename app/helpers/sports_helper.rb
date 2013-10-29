module SportsHelper
    
  def deletesport(sport)
    PhotoQueue.where(sport: sport.id).each do |p|
      p.delete
    end
    Photo.where(sport: sport.id).each do |p|
      p.deletephoto
      p.delete
    end
    PhotoError.where(sport: sport.id).each do |p|
      p.delete
    end
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
      ['Wide Receiver', 'WR'],
      ['Offesnsive Line', 'OL'],
      ['Running Back', 'RB'],
      ['Fullback', 'FB'],
      ['Quarterback', 'QB'],
      ['Center', 'C'],
      ['Tight End', 'TE']
    ]
  end

  def defense_football_positions
    [
      ['Defensive Back', 'DB'],
      ['Defensive Line', 'DL'],
      ['Line Backer', 'LB'],
      ['Corner', 'CR'],
      ['Safety', 'S']
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

  def is_soccer_goalie?(positions)
    if positions.include? "GK"
      return true
    else
      return false
    end
  end
  
end
