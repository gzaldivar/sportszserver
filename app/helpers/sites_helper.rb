module SitesHelper
  
  def site_visit(site)
    if current_site != site.id
      cookies.permanent[:remember_site] = site.id
      self.current_site = site
    end
  end
  
  def current_site=(site)
    @current_site = site
  end
  
  def current_site
    if !cookies[:remember_site].nil?
     return  @current_site ||= Sport.find(cookies[:remember_site])
    else
      return nil
    end
  end
  
  def current_site?
    !current_site.nil?
  end
  
  def clear_site
    cookies.delete(:remember_site)
  end
  
  def user_pics_ok?
    current_site.enable_user_pics
  end
  
  def sportUserPics?(sport)
    if user_signed_in?
        user_pics_ok?
    else
        raise ActionController::RoutingError.new('you are not Authorized for this')
    end
  end
 
  def sportUserVideos?(sport)
    if user_signed_in?
        user_videos_ok?
    else
        raise ActionController::RoutingError.new('you are not Authorized for this')
    end
  end
 
  def user_videos_ok?
    current_site.enable_user_video
  end

  def review_media?
    current_site.review_media
  end

  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

end
