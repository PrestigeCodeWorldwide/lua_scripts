---@type Mq
local mq = require('mq')
local Log = require("biggerlib.Log")
local PackageMan = require('mq/PackageMan')
local sql = PackageMan.Require("lsqlite3")
local Sql = {
    ---@param dbFilePath string # Takes a file path starting from config directory child, like "CWTN\\example.db" or "example.db"
    createDb = function(self, dbFilePath, dbConfigSchema)
        if dbFilePath then
            self.DbFilePath = ("%s\\%s"):format(mq.configDir, dbFilePath)
        else
            Log.error("No db file path provided")
        end
        self.db = sql.open(self.DbFilePath)
        -- build table from dbConfigSchema
        for tableName, tableData in pairs(dbConfigSchema) do
            local columnDefs = {}
            for columnName, columnValue in pairs(tableData) do
                local columnType = type(columnValue) == "number" and "INTEGER" or "TEXT"
                table.insert(columnDefs, string.format("%s %s", columnName, columnType))
            end
            local createTableSql = string.format("CREATE TABLE %s (%s);", tableName, table.concat(columnDefs, ", "))
            self.db:exec(createTableSql)
        end
        print("Created dummy table and inserted data")
        self.db:close()
        print("Closed db")
    end,
    loadConfigDatabase = function(self, dbFilePath)
        if dbFilePath then
            self.DbFilePath = ("%s\\%s"):format(mq.configDir, dbFilePath)
        else
            Log.error("No db file path provided")
        end
        self.db = sql.open(self.DbFilePath)
        local luaObject = {}
        
        for tableName in self.db:rows("SELECT * FROM sqlite_master WHERE type ='table'") do
            luaObject[tableName] = {}
            Log.dump(tableName, "SQLIte table")
            for idx, val in ipairs(tableName) do 
                --Log.dump(val, "val")
                Log.dump(type(val), "type(val)")
                if type(val) == "table" then
                    Log.dump(idx, "idx")
                    Log.dump(val, "val")
                end
            end
        end

        self.db:close()
        --Log.dump(luaObject, "luaObject")
        return luaObject
    end
    
}

local exampleConfigSchema = {    
    ['General'] = {
        spawn = "charname",
        spawnId = 5431,
        isPaused = false,
        shouldOpenGui = true,
    },
    ['ScriptSpecific'] = {
        channel = "Raid",
        resetCooldowns = false
    }


}

Sql:createDb("demosql.db", exampleConfigSchema)
local readDb = Sql:loadConfigDatabase("demosql.db")
Log.dump(readDb, "readDb")
print("Done creating db")
