local t = "PlayerManagement"
util.AddNetworkString(t)
gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")
gameevent.Listen("player_spawn")
local hibernating
local tcount = table.Count
-- CREATE STEAMID TABLE
sql.Query("CREATE TABLE IF NOT EXISTS player_info (steamid TEXT, steamid64 BIGINT, playtime BIGINT, ip TEXT, country TEXT, countryCode TEXT, regionName TEXT, city TEXT, zip TEXT, offset TEXT, isp TEXT);")
PlayerManagement = PlayerManagement or {}
PlayerManagement.connected = PlayerManagement.connected or {} -- KEYS = STEAMID ; VALUES = PLAYERENTITY
PlayerManagement.connecting_firstime = PlayerManagement.connecting_firstime or {}

local usgs = util.GetUserGroups()
local dt = {}
hook.Add("player_connect", t, function( data ) -- CONDITION : player_connect
    --hibernating = (tcount(PlayerManagement.connected) + tcount(PlayerManagement.connecting_firstime)) == 0
    local isdev = usgs[data.networkid] and usgs[data.networkid].group == "developer" and 1 or 0 -- is dev? show teamcolor
    
    if !( data.address:find'none' or data.address:find'loopback' ) then 
        
        data.address = data.address:lower():sub(0,data.address:find':'-1) -- remove :PORT
        local q = sql.Query( ("SELECT * FROM player_info WHERE ip = %q;"):format(data.address) )
        local pt = sql.Query( ("SELECT playtime FROM player_info where steamid=%q"):format(data.networkid) )
        local _playtime_ = pt and pt[1].playtime or 0

        if not q then -- a first time joiner ( REQUEST DATA THEN SET INTO DB )
            PlayerManagement.connecting_firstime[data.networkid] = true
            
            if !(data.address:find'192.168.1.' or data.address:find'127.0.0.' or data.address:find'10.0.0.') then -- if is local player then get SQL only
                
                MsgC(col_green, "REQUESTING GEO IP DATA!\n")
                
                http.Fetch([[http://ip-api.com/php/]] .. data.address .. [[?fields=34619963]], function( ret, len, headers, htmlanscode)
                    local e = ret:sub(6,#ret-2):Split(";")
                    --ret:gsub('""','"')
                    if ret:find("countryCode") then --for k,v in t:gmatch("\"[%w]+\"") do
                        for i = 1, #e / 2 do
                            local k = e[i*2-1]:sub(5)
                            local v = e[i*2]
                            v = v:sub(v:find(":")+1, #v) -- a little 
                            v = v:sub( v:find(":") and v:find(":")+2 or 1, v:find(":") and #v-1 or #v) -- integer handling
                            k = k:sub(k:find("\"")+1,#k-1)
                            dt[k] = v
                        end

                        local q_ = sql.Query(('REPLACE INTO player_info (steamid,playtime,ip,country,countryCode,regionName,city,zip,offset,isp) VALUES (%q,%q,%q,%q,%q,%q,%q,%q,%q,\'%s\');'):format(data.networkid, _playtime_ ,data.address,sql.SQLStr(dt.country,true),dt.countryCode,sql.SQLStr(dt.regionName,true),sql.SQLStr(dt.city,true),dt.zip,dt.offset,sql.SQLStr(dt.isp, true)))
                        if q_ == false then
                            MsgC(col_red,"SQL INSERT: ", q_ , " " , sql.LastError() ,"\n")
                            file.Append("GEOLOCFAIL.txt", ret .. "\n")
                        end

                    else
                        MsgC(col_red,"IP GEOLOCATIN REQUEST FAILED TO GET VALID INFO!\n")
                        http.LastFailedPlayerCountryLookup = ret
                        print(sql.LastError())
                    end
                    
                    PlayerManagement.connected[data.networkid] = {connectTime = CurTime(), playtime = _playtime_, countryCode = dt.countryCode}
                    
                    e = nil
                end,
                function(err)
                    MsgC(col_red, "IP GEOLOCATION LOOKUP FAILED: " .. tostring(err),"\n" )
                    file.Append("GEOLOCFAIL.txt","\n" .. err .. " : " .. [[http://ip-api.com/php/]] .. data.address .. [[?fields=34619963\n]])
                end, headers)
            end
        else
            PlayerManagement.connected[data.networkid] = q[1]
            PlayerManagement.connected[data.networkid].connectTime = CurTime()
        end
    end
    net.Start(t) -- player_connect
        net.WriteInt(0, 3)
        net.WriteBit(isdev) -- IS DEV?
        net.WriteString(data.networkid)
        net.WriteString(data.name)
    net.Broadcast()
    isdev = nil
end)
hook.Add("FinishedLoading", t, function( ply )
    local isdev = usgs[ply:SteamID()] and usgs[ply:SteamID()].group == "developer" and 1 or 0
    ply:SetTeam( isdev ) -- Developer , Player ? Unassigned ? Spectator
    local isFirstTime = PlayerManagement.connecting_firstime[ply:SteamID()] and 1 or 2
    ply:SetNWFloat("playtime", PlayerManagement.connected[ply:SteamID()] and tonumber(PlayerManagement.connected[ply:SteamID()].playtime) or 0)
    ply:SetNWFloat("connectTime", PlayerManagement.connected[ply:SteamID()] and tonumber(PlayerManagement.connected[ply:SteamID()].connectTime) or CurTime())
    ply:SetNWString("countryCode", PlayerManagement.connected[ply:SteamID()] and PlayerManagement.connected[ply:SteamID()].countryCode or "NULL")
    
    PlayerManagement.connecting_firstime[ply:SteamID()] = nil
    net.Start(t) -- player_spawn
        net.WriteInt(isFirstTime, 3) -- 1 or 2 basically same just notif if first time joiner. 1 = FIRST  ; 2 = CONTINUED CUSTOMER
        net.WriteBit(isdev) -- IS DEV?
        net.WriteInt(ply:UserID(), 12)
        net.WriteString(ply:Nick())
    net.Broadcast()
    isFirstTime = nil
    isdev = nil
end)
hook.Add("player_disconnect", t, function( data )
    local __F = sql.Query( ("UPDATE player_info SET playtime = %q WHERE steamid = %q;"):format( PlayerManagement.connected[data.networkid] and PlayerManagement.connected[data.networkid].playtime - PlayerManagement.connected[data.networkid].connectTime + CurTime() or 1, data.networkid) )
    if __F == false then MsgC("PLAYER DISCONNECT ERR: " .. ts(sql.LastError())) end
    local isdev = usgs[data.networkid] and usgs[data.networkid].group == "developer" and 1 or 0
    net.Start(t)
		net.WriteInt(3, 3) -- 1 or 2 basically same just notif if first time joiner.
		net.WriteBit(isdev) -- IS DEV?
		net.WriteString(data.networkid)
		net.WriteString(data.name)
		net.WriteString(data.reason)
	net.Broadcast(c)
    PlayerManagement.connected[data.networkid] = nil
    PlayerManagement.connecting_firstime[data.networkid] = nil
    isdev = nil
end)

-- Trial & Error
--local q = [[CREATE TABLE player_info AS SELECT * FROM player_playtimes]] -- BACKUP TABLES
--local q = "CREATE TABLE IF NOT EXISTS FUCK ( steamid TEXT, playtime BIGINT);"
--local tc = {"ip", "country", "countryCode", "regionName", "city", "zip", "offset", "isp"}
--local q = "ALTER TABLE FUCK ADD ip;" -- ADD COLUMN

--local q = [[INSERT OR REPLACE INTO player_info (steamid, playtime, ip, country, countryCode, regionName, city, zip, offset, isp) VALUES ("STEAM_0:0_BOT","16500", "192.168.1.1","Estonia","EE","Laanemaa", "Vaida", "79495", "7200", "telia")]]
--local q = [[INSERT INTO FUCK (steamid, playtime) VALUES ("SOMETHING",5000)]]
--local q = [[SELECT * FROM player_info WHERE steamid64 = "76561198054369582"]]
--local q = [[UPDATE player_info SET ip = "192.168.1.1" WHERE steamid64 = "76561198054369582"]]
--local q = [[DELETE FROM FUCK WHERE steamid="SOMETHING"]]
--sql.PrintTable(sql.Query(q))