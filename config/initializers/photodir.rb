  begin
    FileUtils.mkdir(Rails.root + 'public/system')
  rescue Exception => e
    puts e
  end
  
  begin
    FileUtils.mkdir(Rails.root + 'public/system/pictemp')
  rescue Exception => e
    puts e
  end

  begin
    FileUtils.mkdir(Rails.root + 'public/system/pictemp/temp')
  rescue Exception => e
    puts e
  end

  begin
    FileUtils.mkdir(Rails.root + 'public/system/pictemp/thumb')
  rescue Exception => e
    puts e
  end 

  begin
    FileUtils.mkdir(Rails.root + 'public/system/pictemp/medium')
  rescue Exception => e
    puts e
  end

  begin
    FileUtils.mkdir(Rails.root + 'public/system/pictemp/large')
  rescue Exception => e
    puts e
  end
