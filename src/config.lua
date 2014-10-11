local _M = { }

function _M.read( path, defaults )
	local conf = defaults
	local fn

	if _VERSION == "Lua 5.1" then
		fn = assert( loadfile( path ) )

		local env = setmetatable( { }, {
			__newindex = function( self, key, value )
				conf[ key ] = value
			end,

			__index = { },
		} )

		setfenv( fn, env )
	else
		fn = assert( loadfile( path, "t", conf ) )
	end

	local ok, err = pcall( fn )

	if not ok then
		error( "couldn't read config: " .. err )
	end

	return conf
end

return _M
