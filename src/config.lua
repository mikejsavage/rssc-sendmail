local _M = { }

function _M.read( path, defaults )
	local fn = assert( loadfile( path ) )
	local conf = defaults

	local env = setmetatable( { }, {
		__newindex = function( self, key, value )
			conf[ key ] = value
		end,

		__index = { },
	} )

	setfenv( fn, env )
	local ok, err = pcall( fn )

	if not ok then
		error( "couldn't read config: " .. err )
	end

	return conf
end

return _M
