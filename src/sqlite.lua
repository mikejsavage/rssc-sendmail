local sqlite3 = require( "lsqlite3" )

local _M = { }
local DB = { }

local function stmtIter( db, query, ... )
	local stmt = db:prepare( query )
	assert( stmt, db:errmsg() )

	stmt:bind_values( ... )

	local iter = stmt:nrows()

	return function()
		return iter( stmt )
	end
end

function DB:run( query, ... )
	self( query, ... )()
end

function DB:first( query, ... )
	return self( query, ... )()
end

function DB:transaction( f )
	self:exec( "BEGIN" )

	f()

	self:exec( "COMMIT" )
end

local function addMethods( db )
	local mt = getmetatable( db )
	local oldIndex = mt.__index

	mt.__call = function( self, query, ... )
		return stmtIter( self, query, ... )
	end

	mt.__index = function( self, key )
		return DB[ key ] or oldIndex[ key ]
	end

	return db
end

function _M.open( file )
	return addMethods( sqlite3.open( file ) )
end

function _M.open_memory()
	return addMethods( sqlite3.open_memory() )
end

return _M
