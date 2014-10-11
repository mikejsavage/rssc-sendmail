local sqlite3 = require( "lsqlite3" )

local _M = { }
local DB = { }

local function stmtIter( db, query, ... )
	local stmt = db:prepare( query )
	assert( stmt, db:errmsg() )

	_M.assert( self, stmt:bind_values( ... ) )

	local iter = stmt:nrows()

	return function()
		return iter( stmt )
	end
end

function DB:run( query, ... )
	local stmt = self:prepare( query )
	assert( stmt, self:errmsg() )

	assert( stmt:bind_values( ... ) == sqlite3.OK )

	local res = stmt:step()
	return res == sqlite3.DONE and sqlite3.OK or res
end

function DB:first( query, ... )
	return self( query, ... )()
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

function _M.assert( db, result )
	if result ~= sqlite3.OK then
		error( db:errmsg() )
	end
end

return _M
