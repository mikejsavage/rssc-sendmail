local sqlite = require( "sqlite" )
local config = require( "config" )

local db = sqlite.open( "/var/lib/rss/feeds.sq3" )
local cfg = config.read( "/etc/rssc_sendmail.conf", {
	sendmail = "sendmail",
} )

for article in db( [[
	SELECT
		articles.title,
		articles.url,
		articles.content,
		articles.timestamp,
		feeds.title as feedtitle
	FROM articles
	INNER JOIN feeds
	ON articles.feedid = feeds.id
	WHERE articles.unread = 1
	ORDER BY articles.timestamp DESC
]] ) do
	local cmd = ( "%s -f %q %q" ):format( cfg.sendmail, cfg.from, cfg.to )
	local body = ( "Subject: [%s] %s\n\nPosted %s\n%s\n\n%s" ):format(
		article.feedtitle,
		os.date( "%a %w %b, %X", article.timestamp ),
		article.url,
		article.title,
		article.content
	)

	local pipe = assert( io.popen( cmd, "w" ) )
	assert( pipe:write( body ) )
	assert( pipe:close() )
end

assert( db:exec( "UPDATE articles SET unread = 0" ) )

assert( db:close() )
