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
		articles.timestamp,
		feeds.title as feedtitle
	FROM articles
	INNER JOIN feeds
	ON articles.feedid = feeds.id
	WHERE articles.unread = 1
	ORDER BY articles.timestamp DESC
]] ) do
	local cmd = ( "%s -t -f %q %q" ):format( cfg.sendmail, cfg.from, cfg.to )
	local body = ( "To: %s\nSubject: [%s] %s\n\nPosted %s\n%s" ):format(
		cfg.to,
		article.feedtitle,
		article.title,
		os.date( "%a %w %b %Y, %X", article.timestamp ),
		article.url
	)

	local pipe = assert( io.popen( cmd, "w" ) )
	assert( pipe:write( body ) )
	assert( pipe:close() )
end

assert( db:exec( "UPDATE articles SET unread = 0" ) )

assert( db:close() )
