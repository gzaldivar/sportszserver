# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.eazesportz.com"
SitemapGenerator::Sitemap.public_path = 'tmp/'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(aws_access_key_id: "AKIAIPCK7WD7Z53FKBEQ", 
																	aws_secret_access_key: "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",
																	fog_provider: "AWS",
																	fog_directory: "sportzteams")


#SitemapGenerator::Sitemap.sitemaps_host = "http://sportzteams.s3.amazonaws.com/"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  add '/contacts'
  add '/home'
  add '/about'
  add '/eazefootball'
  add '/eazebasketball'
  add '/infobasketball'
  add '/iphone_basketball'
  add '/mobileinfo'

  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
