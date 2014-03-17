object @admin
node(:id) { |o| o.id.to_s }
attributes :streamingurl, :streamingbucket, :disableads, :highlightAppVersion, :broadcastAppVersion