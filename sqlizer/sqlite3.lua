
local ffi = require "ffi"

local sql3 = require "sqlite3_ffi"

local sqlite = {};

--[[
DBConnection.__gc(self)
		if self.conn then
			self:Close()
		end
end
--]]
local DBConnection = {};
setmetatable(DBConnection, {
	__call = function(self, ...)
		return self:open(...);
	end,
});

local DBConnection_mt = {
	__index = DBConnection;
}

DBConnection.init = function(self, handle, dbname)
	local obj = {
		conn = handle,
		dbname = dbname,
	}
	setmetatable(obj, DBConnection_mt);

	return obj;
end

DBConnection.getNativeHandle = function(self)
	return self.conn;
end

DBConnection.open = function(self, dbname)
	dbname = dbname or ":memory:";

	local lpdb = ffi.new("sqlite3*[1]")
	local err = sql3.sqlite3_open(dbname, lpdb);

	if err ~= 0 then
		return nil, err;
	end

	return self:init(lpdb[0], dbname);
end

DBConnection.close = function(self)
	local rc = sql3.sqlite3_close(self.conn)
	if rc == SQLITE_OK then
		self.conn = nil
	end

	return rc
end

DBConnection.exec = function(self, statement, callbackfunc, userdata)
--print("Exec: ", statement);
	local lperrMsg = ffi.new("char *[1]");
	local rc = sql3.sqlite3_exec(self.conn, statement, callbackfunc, userdata, lperrMsg);
	local errmsg = lperrMsg[0]

	if rc ~= SQLITE_OK then
		errmsg = ffi.string(errmsg);

		-- Free this to avoid a memory leak
		sql3.sqlite3_free(lperrMsg[0])
	end

	return rc, errmsg
end

DBConnection.getLastRowID = function(self)
	return sql3.sqlite3_last_insert_rowid(self.conn);
end

DBConnection.prepare = function(self, statement)
	return sqlite.DBStatement(self, statement);	
end

DBConnection.interrupt = function(self)
	local rc = sql3.sqlite3_interrupt(self.conn)
end

-- DDL
DBConnection.createTable = function(self, params)
	params.Connection = self;
	return sqlite.DBTable:create(params);
end

DBConnection.dropTable = function(tablename)
	local stmnt = string.format("DROP TABLE %s ", tablename);
	local rc, errmsg = self:exec(stmnt)

	if rc ~= SQLITE_OK then
		return nil, rc, errmsg
	end
end


--[[
==============================================
		CRUD Operations with Tables
==============================================
--]]
DBTable = {};
setmetatable(DBTable, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
DBTable_mt = {
	__index = DBTable;
};


DBTable.init = function(self, dbconn, tablename)
	local obj = {
		conn = dbconn,
		tablename = tablename,
	};
	setmetatable(obj, DBTable_mt);

	return obj;
end


DBTable.create = function(self, params)
	local stmnt = string.format("CREATE TABLE %s (%s) ", params.Name, params.Columns);

print("create: ", stmnt);

	local rc, errmsg = params.Connection:exec(stmnt)

	if rc ~= SQLITE_OK then
		return nil, rc, errmsg
	end

	return self:init(params.Connection, params.Name);
end


DBTable.insertValues = function(self, params)
	local stmnt
	if params.Columns then
		stmnt = string.format("INSERT INTO %s (%s) VALUES c(%s)", self.tablename, params.Columns, params.Values);
	else
		stmnt = string.format("INSERT INTO %s VALUES (%s)", self.tablename, params.Values);
	end

	return self.conn:exec(stmnt)
end

function DBTable:delete(expr)
	if not expr then return 0 end

	local stmnt = string.format("DELETE FROM %s WHERE %s ", self.tablename, expr)

	return self.conn:exec(stmnt)
end

function DBTable:select(expr, columns)
	local stmnt

	if expr then
		stmnt = string.format("SELECT %s FROM %s", columns, self.tablename)
	else
		stmnt = string.format("SELECT %s FROM %s WHERE %s", columns, self.tablename, expr)
	end

	return self.conn:exec(stmnt)
end

--[[
int DBTable_column_metadata(
  sqlite3 *db,                /* Connection handle */
  const char *zDbName,        /* Database name or NULL */
  const char *zTableName,     /* Table name */
  const char *zColumnName,    /* Column name */
  char const **pzDataType,    /* OUTPUT: Declared data type */
  char const **pzCollSeq,     /* OUTPUT: Collation sequence name */
  int *pNotNull,              /* OUTPUT: True if NOT NULL constraint exists */
  int *pPrimaryKey,           /* OUTPUT: True if column part of PK */
  int *pAutoinc               /* OUTPUT: True if column is auto-increment */
);

		-- Handy CRUD operations



		Update = function(self, tablename, columns, values)
		end;



		GetErrorMessage = function(self)
			return ffi.string(sql3.sqlite3_errmsg(self.conn))
		end;
--]]

--[[
==============================================
		Statements
==============================================
--]]
local value_handlers = {
	[SQLITE_INTEGER] = function(stmt, n) return sql3.sqlite3_column_int(stmt, n) end,
	[SQLITE_FLOAT] = function(stmt, n) return sql3.sqlite3_column_double(stmt, n) end,
	[SQLITE_TEXT] = function(stmt, n) return ffi.string(sql3.sqlite3_column_text(stmt,n)) end,
	[SQLITE_BLOB] = function(stmt, n) return sql3.sqlite3_column_blob(stmt,n), sql3.sqlite3_column_bytes(stmt,n) end,
	[SQLITE_NULL] = function() return nil end
}

DBStatement = {}
setmetatable(DBStatement, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
DBStatement_mt = {
	__index = DBStatement,
}


DBStatement.init = function(self, dbconn, stmt)

	local obj = {
		conn = dbconn,
		stmt = stmt,
		PositionedOnRow = false,
	};
	setmetatable(obj, DBStatement_mt);

	return obj;
end

--[[
 int sqlite3_prepare_v2(
  sqlite3 *db,            /* Database handle */
  const char *zSql,       /* SQL statement, UTF-8 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */
);
]]

DBStatement.create = function(self, dbconn, statement)
	local ppStmt = ffi.new("sqlite3_stmt *[1]");
	local pzTail = ffi.new("const char *[1]");

	local rc = sql3.sqlite3_prepare_v2(dbconn:getNativeHandle(), statement, #statement+1, ppStmt, pzTail);

	if rc ~= SQLITE_OK then
		return false, rc;
	end

	return self:init(dbconn, ppStmt[0]);
end


function DBStatement:getColumnValue(n)
	return value_handlers[sql3.sqlite3_column_type(self.stmt,n)](self.stmt,n)
end

function DBStatement:getRowTable()
	if not self.PositionedOnRow then return nil end

	local res = {}
	local nCols = self:dataRowColumnCount()
	for i=0,nCols-1 do
		table.insert(res, self:getColumnValue(i))
	end

	return res;
end

--[[
	This is an iterator
	It will call the Step() function before
	returning rows as lua tables

	Usage:

	for row in stmt:Results() do
	    printRow(row)
	end
--]]

function DBStatement:results()
	-- Assume the statement has already been Prepared

	local function step()
		local rc = sql3.sqlite3_step(self.stmt);
		self.PositionedOnRow = rc == SQLITE_ROW;

		return rc
	end

	local closure = function()
		local rc = step();

		if rc ~= SQLITE_ROW then
			return nil
		end

		return self:getRowTable();
	end

	return closure;
end

function DBStatement:finish()
	local rc = sql3.sqlite3_finalize(self.stmt);
	self.PositionedOnRow = false;
end

function DBStatement:step()
	local rc = sql3.sqlite3_step(self.stmt);
	self.PositionedOnRow = rc == SQLITE_ROW;

	return rc
end

function DBStatement:reset()
	local rc = sql3.sqlite3_reset(self.stmt);
	self.PositionedOnRow = false;

	return rc
end

-- Some attributes of the statement
-- Get number of columns from the prepared statement
function DBStatement:preparedColumnCount()
	return sql3.sqlite3_column_count(self.stmt);
end

function DBStatement:dataRowColumnCount()
	return sql3.sqlite3_data_count(self.stmt);
end

function DBStatement:isBusy()
	local rc = sql3.sqlite3_busy(self.stmt);
	return rc ~= 0
end

function DBStatement:isReadOnly()
	local rc = sql3.DBStatement_readonly(self.stmt);
	return rc ~= 0
end




sqlite.DBConnection = DBConnection;
sqlite.DBTable = DBTable;
sqlite.DBStatement = DBStatement;

return sqlite
