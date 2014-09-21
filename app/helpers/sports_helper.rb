module SportsHelper
    
  def deletesport(sport)
    current_user.default_site = ""
    current_user.save!
  end

  def find_a_sport(thesport)
    if !params[:zip].blank? and !params[:city].blank? and !params[:state].blank? and !params[:sitename].blank? and !params[:country].blank?
      site = Sport.where(name: thesport).full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s + " " + 
            params[:sitename].to_s + " " + params[:country].to_s, match: :all)      
#      site = Sport.where(name: thesport, city: params[:city], state: params[:state], country: params[:country]).full_text_search(params[:sitename].to_s, match: :all)
    elsif !params[:zip].blank? and !params[:city].blank? and !params[:state].blank? and !params[:country].blank?
      site = Sport.where(name: thesport).full_text_search(params[:zip].to_s + " " + params[:city].to_s + " " + params[:state].to_s +
            " " + params[:country].to_s, match: :all)
#      site = Sport.where(name: thesport, city: params[:city], state: params[:state], country: params[:country])
    elsif !params[:country].blank? and !params[:city].blank?
      site = Sport.where(name: thesport).full_text_search(params[:country].to_s + " " + params[:city].to_s, match: :all)
#      site = Sport.where(name: thesport, country: params[:country], city: params[:city])
    elsif !params[:country].blank? and !params[:state].blank?
#      site = Sport.where(name: thesport, country: params[:country], state: params[:state])
      site = Sport.where(name: thesport).full_text_search(params[:country].to_s + " " + params[:state].to_s, match: :all)
    elsif !params[:zip].blank?
#      site = Sport.where(name: thesport, zip: params[:zip])
      site = Sport.where(name: thesport).full_text_search(params[:zip].to_s)
    elsif !params[:city].blank?
#      site = Sport.where(name: thesport, city: params[:city])
      site = Sport.where(name: thesport).full_text_search(params[:city].to_s)
    elsif !params[:state].blank?
#      site = Sport.where(name: thesport, state: params[:state])
      site = Sport.where(name: thesport).full_text_search(params[:state].to_s)
    elsif !params[:country].blank?
#      site = Sport.where(name: thesport, country: params[:country])
      site = Sport.where(name: thesport).full_text_search(params[:country].to_s)
    elsif !params[:sitename].blank?
      site = Sport.where(name: thesport).full_text_search(params[:sitename].to_s)
    elsif !params[:searchkeyword]
      site = Sport.where(name: thesport).full_text_search(params[:searchkeyword].to_s)        
    elsif
      site = Sport.where(name: thesport).or(sportname: thesport)
    end

    return site
  end

    def sport_home_team
        "Home"
    end

    def sport_visitor_team
        "Visitor"
    end

  def months
    [
      ["January", "1"],
      ["February", "2"],
      ["March", "3"],
      ["April", "4"],
      ["May", "5"],
      ["June", "6"],
      ["July", "7"],
      ["August", "8"],
      ["September", "9"],
      ["October", "10"],
      ["November", "11"],
      ["December", "12"],
    ]
  end
  
  def get_sport_logo(sport)
    if sport.sport_logo?
      sport.sport_logo(:thumb)
    else
      return "photo_not_available.png"
    end
  end

  def get_tiny_sport_logo(sport)
    if sport.sport_logo?
      sport.sport_logo(:tiny)
    else
      "photo_not_available.png"
    end
  end

  def sports_list
    [
      ['Football', 'Football'],
      ['Basketball', 'Basketball'],
      ['Hockey', 'Hockey'],
      ['Lacrosse', 'Lacrosse'],
      ['Soccer', 'Soccer'],
      ['Water Polo', 'Water Polo']
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
      ['Sweeper', 'SW'],
      ['Left Back', 'LB'],
      ['Right Back', 'RB'],
      ['Full Back', 'FB'],
      ['Left Wing Back', 'LWB'],
      ['Right Wing Back', 'RWB'],
      ['Defending Midfielder ', 'DM'],
      ['Central Midfielder', 'CM'],
      ['Attacking Midfielder', 'AM'],
      ['Left Wing Back', 'LWB'],
      ['Right Wing Back', 'RWB'],
      ['Center Forward', 'CF'],
      ['Stryker', 'ST']
    ]
  end

  def waterpolo_positions
    [
      ['Hole Set', 'HS'],
      ['Driver', 'DR'],
      ['Hole Guard', 'HG'],
      ['Goalie', 'G']
    ]    
  end

  def themes
    raw [
         [image_tag('slate.png'), 'application'],
         [image_tag('spacelab.png'), 'spacelab']
        ].join()
  end

  def textminutes(upper)
      minutes = Array.new(upper) { |i| i < 10 ? '0' + i.to_s : i.to_s }
      return minutes
  end

  def textseconds
      seconds = Array.new(60) { |i| i < 10 ? '0' + i.to_s :  i.to_s }
      return seconds
  end

  def waterpolo_abbreviations
    [
      ['Goal', 'G'],
      ['Exclusion', 'E'],
      ['Penalty', 'P'],
      ['Brutality', 'B'],
      ['Misconduct', 'M'],
      ['Time-out', 'TO'],
      ['Yellow Card', 'YC'],
      ['Red Card', 'RC']
    ]
  end

end
