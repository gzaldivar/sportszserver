object @user
node(:id) { |o| o.id.to_s }
attributes :season, :bio_alert, :blog_alert, :stat_alert, :score_alert, :media_alert, :name
node(:avatar) { |t| t.avatar(:thumb) }
