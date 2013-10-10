# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.eazesportz.com"
SitemapGenerator::S3Adapter
SitemapGenerator::S3Adapter:AWS_ACCESS_KEY_ID = "AKIAIPCK7WD7Z53FKBEQ"
SitemapGenerator::S3Adapter:AWS_SECRET_ACCESS_KEY = "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"
SitemapGenerator::S3Adapter:FOG_PROVIDER = "AWS"
SitemapGenerator::S3Adapter:FOG_DIRECTORY = "sportzteams"


SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  Add '/contacts'
  Add '/home'
  Add '/about'
  Add '/eazefootball'
  Add '/eazebasketball'
  Add '/infobasketball'
  Add '/iphone_basketball'
  Add '/mobileinfo'

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
