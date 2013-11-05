local ffi = require "ffi"

local sqlite = require "sqlite3"


-- A simple function to report errors
-- This will halt the program if there
-- is an error
-- Use this when you consider an error to
-- be an exception
-- But really, it's just to test things out
function dbcheck(rc, errormsg)
	if rc ~=  SQLITE_OK then
		print("Error Code: ", rc)
		error(errormsg)
	end

	return rc, errormsg
end


-- Establish a database connection to an in memory database
local dbconn,err = sqlite.DBConnection:open();

print("DBConnection: ", dbconn, err);


-- Create a table in the 'main' database
local tbl, rc, errormsg = dbconn:createTable({Name = "People", Columns="First, Middle, Last"});

print("Create Table: ", tbl, rc, errormsg);


-- Insert some rows into the table
dbcheck(tbl:insertValues({Values="'Bill', 'Albert', 'Gates'"}));
dbcheck(tbl:insertValues({Values="'Larry', 'Devon', 'Ellison'"}));
dbcheck(tbl:insertValues({Values="'Steve', 'Jahangir', 'Jobs'"}));
dbcheck(tbl:insertValues({Values="'Jack', '', 'Sprat'"}));
dbcheck(tbl:insertValues({Values="'Marry', '', 'Lamb'"}));
dbcheck(tbl:insertValues({Values="'Peter', '', 'Piper'"}));

-- This routine is used as a callback from the Exec() function
-- It is just an example of one way of interacting with the
-- thing.  All values come back as strings.
function dbcallback(userdata, dbargc, dbvalues, dbcolumns)
	--print("dbcallback", dbargc);
	local printheadings = userdata ~= nil

	if printheadings then
		-- print column names
		for i=0,dbargc-1 do
			io.write(ffi.string(dbcolumns[i]))
			if i<dbargc-1 then
				io.write(", ");
			end

			if i==dbargc-1 then
				io.write("\n");
			end
		end
	end

	-- print values
	for i=0,dbargc-1 do
		if dbvalues[i] == nil then
			io.write("NULL");
		else
			io.write(ffi.string(dbvalues[i]))
		end

		if i<dbargc-1 then
			io.write(",");
		end

		if i==dbargc-1 then
			io.write("\n");
		end
	end

	return 0;
end

-- Perform a seclect operation using the Exec() function
dbconn:exec("SELECT * from People", dbcallback)



-- Using prepared statements, do the same connect again
stmt, rc = dbconn:prepare("SELECT * from People");

print("Prepared: ", stmt, rc);

-- Prepared columns tells you how many columns should be
-- in the result set once you start getting results
print("Prepared Cols: ", stmt:preparedColumnCount());

-- DataRow Columns is the number of columns that actually
-- exist for a given row, after you've started getting
-- rows back.
print("Data Row Cols: ", stmt:dataRowColumnCount());


-- A simple utility routine to print out the values of a row
function printRow(row)
	local cols = #row;
	for i,value in ipairs(row) do
		io.write(value);
		if i<cols then
			io.write(',');
		end
	end
	io.write('\n');
end

-- Using the Results() iterator to return individual
-- rows as Lua tables.
for row in stmt:results() do
	printRow(row);
end

-- Finish off the statement
stmt:finish();

-- Close the database connection
dbconn:close();

