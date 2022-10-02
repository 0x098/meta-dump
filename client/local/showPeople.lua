local main = main or {}
local NamaExec = NamaExec or "0x098"
RunString(file.Read("local/colLib.lua","LUA"))
RunString(file.Read("local/fontLib.lua","LUA"))
main.tag = "Bababooey"
main.wh = {}
main.wh.enabled = 1
local ts = tostring
local PT = PrintTable
local xy = {x=0,y=0,visible=false}

concommand.Add("main_wh", function(a,b,c)
    main.wh.enabled = tonumber(c[1]) or 0
end)

gameevent.Listen("player_connect_client")

main.wh.plys = {frens = {}, custom = {}, non_fr = {}, names = {}, isafk = {}, istabbedout = {}}
if file.Find("wh.dat", "DATA") then
    main.wh.plys.customLiteral = util.Decompress(file.Read("wh.dat","DATA"))
    for k, v in pairs( string.Split( main.wh.plys.customLiteral, "\n") ) do
        local ply = player.GetBySteamID(v)
        if ply and ply.IsPlayer and ply:IsPlayer() then
            main.wh.plys.custom[v] = ply
        end
    end
end
UndecorateNick = UndecorateNick or function(str) return str end
local function addPlyCustom(e)
    local str = ""
    main.wh.plys.custom[e:SteamID()] = e
    main.wh.plys.names[e:SteamID()] = UndecorateNick(e:GetName())
    for k,v in pairs(main.wh.plys.custom) do
        if str=="" then
            str = v:SteamID() .. "\n"
        else
            str = str .. v:SteamID() .. "\n"
        end
    end
    str = main.wh.plys.customLiteral .. "\n" .. str
    file.Write("wh.dat", util.Compress(str))
    --file.Write()
    MsgC(col_yellow,ts(e) .. " has been added.\n")
end
local function addPly(e)
    if IsValid(e) then
        if e:GetFriendStatus() == "friend" then
            main.wh.plys["frens"][e:SteamID()] = e
        elseif string.find(main.wh.plys.customLiteral, e:SteamID(), 1, true) then
            main.wh.plys.custom[e:SteamID()] = e
        else
            main.wh.plys.non_fr[e:SteamID()] = e
        end
        main.wh.plys.names[e:SteamID()] = UndecorateNick(e:GetName())
        MsgC(col_green,ts(e) .. " has been added.\n")
    end
end
local function attemptAddPlayer(userid)
    -- Player(userid)
    if Player(userid) and IsValid(Player(userid)) then
        --MsgC(col_red,"Attempting to add " .. ts(userid) .. "\n")
        addPly(Player(userid))
    else
        timer.Simple(15, function() attemptAddPlayer(userid) end)
        --MsgC(col_red,"Trying " .. ts(userid) .. " again in 15sec.\n")
    end
end
local ffff_ply
concommand.Add("main_whadd", function(a,b,tbl,str)
    ffff_ply = easylua.FindEntity(str)
    if IsValid(ffff_ply) and ffff_ply:IsPlayer() then
        addPlyCustom(ffff_ply)
    end
end)
concommand.Add("main_whlist", function() 
    PT(string.Split(main.wh.plys.customLiteral, "\n"))
end)
for k, v in pairs(player.GetAll()) do
    if v != p then
        addPly(v)
    end
end
hook.Add("player_connect_client", main.tag, function(a)
    --PT(a)
    timer.Simple(5, function() attemptAddPlayer(a.userid) end)
end)
local xy = {x=0,y=0,visible=false}
local vec001 = Vector(0,0,1)
hook.Add("HUDPaint", main.tag, function()
    if main.wh.enabled <= 0 then return end
    if main.wh.enabled == 2 then
        for k,v in pairs(main.wh.plys.non_fr) do
            if IsValid(v) then
                xy = (v:EyePos()+vec001*16):ToScreen()
                draw.SimpleTextOutlined(main.wh.plys.names[k],"hudpaint_font",xy.x,xy.y,col_white,1,1,0.5,col_black)
                if v:Health() < 31 then
                    draw.SimpleTextOutlined("[" .. ts(v:Health()) .. "]","hudpaint_font",xy.x,xy.y-10,col_red,1,1,0.5,col_black)
                else
                    draw.SimpleTextOutlined("[" .. ts(v:Health()) .. "]","hudpaint_font",xy.x,xy.y-10,col_green,1,1,0.5,col_black)
                end
                --draw.SimpleTextOutlined(k,"hudpaint_font",xy.x,xy.y-20,col_white,1,1,0.5,col_black)
            end
        end
    end
    if not table.IsEmpty(main.wh.plys.custom) then
        for k,v in pairs(main.wh.plys.custom) do
            if IsValid(v) then
                xy = (v:EyePos()+vec001*16):ToScreen()
                draw.SimpleTextOutlined(main.wh.plys.names[k],"hudpaint_font",xy.x,xy.y,col_yellow,1,1,0.5,col_black)
                if v:Health() < 31 then
                    draw.SimpleTextOutlined("[" .. ts(v:Health()) .. "]","hudpaint_font",xy.x,xy.y-10,col_red,1,1,0.5,col_black)
                else
                    draw.SimpleTextOutlined("[" .. ts(v:Health()) .. "]","hudpaint_font",xy.x,xy.y-10,col_green,1,1,0.5,col_black)
                end
                --draw.SimpleTextOutlined(k,"hudpaint_font",xy.x,xy.y-20,col_white,1,1,0.5,col_black)
            end
        end
    end
    if not table.IsEmpty(main.wh.plys.frens) then
        for k,v in pairs(main.wh.plys.frens) do
            if IsValid(v) then
                xy = (v:EyePos()+vec001*16):ToScreen()
                draw.SimpleTextOutlined(main.wh.plys.names[k],"hudpaint_font",xy.x,xy.y,col_green,1,1,0.5,col_black)
                if v:Health() < 31 then
                    draw.SimpleTextOutlined("[" .. ts(v:Health()) .. "]","hudpaint_font",xy.x,xy.y-10,col_red,1,1,0.5,col_black)
                else
                    draw.SimpleTextOutlined("[" .. ts(v:Health()) .. "]","hudpaint_font",xy.x,xy.y-10,col_green,1,1,0.5,col_black)
                end
                --draw.SimpleTextOutlined(k,"hudpaint_font",xy.x,xy.y-20,col_white,1,1,0.5,col_black)
            end
        end
    end
end)
MsgC(Color(178,255,0,255),'[' .. tostring(NamaExec) .. '] Showpeople Loaded\n')