CV = {} -- this is the cursed Client SQL ConVar database thingy
_G.SQLConVar=CV
CV.__index = CV

CV.DatabaseName = "sex_settings"
sql.Query(("CREATE TABLE IF NOT EXISTS %q (convar TEXT UNIQUE, value TEXT)"):format(CV.DatabaseName))
CV.Description = [[SQLConVar uses the clients local database to write convars which the client has set for themself. 
Table is "DatabaseName" (convar TEXT UNIQUE, value TEXT)
Usage: SQLConVar("cl_convar") to GET
       SQLConVar("cl_convar",1) to SET]]
CV.Clean = function(str)
    return sql.SQLStr(('%s'):format(str), true)
end
setmetatable(CV, {__call = function(self, convar, set) -- SQLConVar("cl_something") to get  ;  SQLConVar("cl_something", 1) to set
    if convar and set then -- do a "SET"
        return sql.Query( ('INSERT OR REPLACE INTO %q (convar, value) VALUES (%q, %q)'):format(CV.Clean(CV.DatabaseName), CV.Clean(convar), CV.Clean(set)) )
    elseif convar and not set then -- return a "GET" 
        local ans = sql.Query( ('SELECT value FROM %q WHERE convar = %q'):format(CV.Clean(CV.DatabaseName), CV.Clean(convar)) ) -- so we dont have to call it multiple times.
        return ans and ans[1] and ans[1].value
    end
end})
