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
  end
  
  def sports_list
    [
      ['Football', 'Football'],
      ['Basketball', 'Basketball']
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
      ['Punter', 'P'],
      ['Kicker/Punter', 'KP']
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
  
end
