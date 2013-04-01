object @newsfeed
node(:id) { |o| o.id.to_s }
attributes :title, :news, :athlete, :coach, :external_url, :team
