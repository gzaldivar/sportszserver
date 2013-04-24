object @site
node (:id) { |o| o.id.to_s }
attributes :sitename, :mascot
node(:logo_thumburl) { |s| s.logo(:large)}
node(:banner_thumb) { |b| b.banner(:thumb)}