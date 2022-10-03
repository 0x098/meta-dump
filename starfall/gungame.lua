--@name GunGame
--@author Niccep
--@shared
local tag = "GunGame"
local mdl = "models/props_junk/PopCan01a.mdl"
local bgprop,bgpropmat = "models/props_phx/construct/wood/wood_panel2x2.mdl","sprops/textures/sprops_wood1"
local cl = "prop_physics"
function UndecorateNick(str) return string.gsub(str,"<.->","") end
function find.bySteamID64(...)
        local b = {...} 
        local a = {}
        for k,v in pairs(b) do
            a[k] = find.allPlayers(function(a) return a:getSteamID64()==v end)[1]
        end
    return a
end
if SERVER then
    target = "nil"
    local msgSent,Game = 1,{}
    Game.running,Game.His = false,{}
    local screen = { ["ent"]=chip():getLinkedComponents()[1] }
    screen.pos = screen.ent:obbCenterW()
    screen.offsetfrombg = Vector(91,0,0)
    local p = { ["cans"]=0, ["ply"]=nil, ["miss"]=0, ["allShots"]=0, }
    local cans = find.byModel(mdl,function(a) return a:getClass()==cl and hasPermission("entities.setPos",a) and a:obbCenterW():getDistanceSqr(chip():getPos())<500^2 end)
    local background = find.byModel(bgprop,function(a) return a:getMaterial()==bgpropmat and a:getClass()==cl and hasPermission("entities.setPos",a) and a:obbCenterW():getDistanceSqr(chip():getPos())<500^2 end)
    local background = find.sortByClosest(background,chip():getPos())[1]
    local bgpos = background:getPos()
    for k,v in pairs(cans)do
        v:setColor(Color(255,255,255,255))
        v:setMaterial("models/debug/debugwhite")
        --v:setRenderMode(2)
    end
    
    hook.add("think",tag,function()
        if Game.ran then
            if p.ply then
                if(p.ply:isValid()) then
                    if(p.ply:isAlive()) then
                        if Game.startTime and Game.endTime and Game.running==true then
                            if timer.curtime()>Game.endTime and msgSent == 0 then
                                msgSent = 1
                                quitGame(p.ply) -- send scores to player and
                            end
                        end
                    else -- if p.ply:isAlive()
                        quitGame()
                    end
                else -- if p.ply:isValid()
                    quitGame()
                end
            else -- if p.ply
                quitGame()
            end
        end
        if table.count(Game.His)>0 then
            for k,v in pairs(Game.His) do
                if find.bySteamID64(k)[1] then
                    Game.His[k].ply = UndecorateNick(find.bySteamID64(k)[1]:getName())
                end
            end
        end
    end)
    
    function sendData()
        local data = ""
        for k,v in pairs(Game.His) do
            if v.ply then
                if type(v.ply)=="string" then
                    data = data .. tostring(k) .. "," .. tostring(v.shotCount) .. "," .. tostring(v.shotCans) .. "," .. string.replace(UndecorateNick(v.ply),",","&%_COMMA") .. "\n"
                elseif type(v.ply)=="Player" then
                    data = data .. tostring(k) .. "," .. tostring(v.shotCount) .. "," .. tostring(v.shotCans) .. "," .. string.replace(UndecorateNick(v.ply:getName()),",","&%_COMMA") .. "\n"
                end
            end
        end
        net.start("HiScores")
        net.writeBit(0)
        net.writeString(data)
        net.send(owner())
        syncData()
    end
    
    function resetGame() -- kinda obsolete atm
        p = { ["cans"]=0, ["miss"]=0, ["ply"]=nil, ["steamid"]=0, }
    end
    function selectNew() -- select new can
        if target!="nil" then target:setColor(Color(255,255,255,0)) end
        if #cans > 0  then
            target = cans[math.random(1,#cans)]
            if hasPermission("entities.setPos",target) and hasPermission("entities.setRenderProperty",target) then
                target:setColor(Color(p.cans*90,1,1):hsvToRGB())
            end
        end
    end
    function startGame(ply)
        if ply:obbCenterW():getDistanceSqr(chip():getPos()) < 150^2 then
            p.ply, p.cans, p.miss, p.steamid, p.allShots, msgSent, Game.ran = ply, 0, 0, ply:getSteamID64(), 0, 0, true
            --print(ply:getName() .. " started playing")
            for k,v in pairs(cans) do if hasPermission("entities.setRenderProperty",v) and hasPermission("entities.emitSound",v) then v:setColor(Color(255,255,255,0)) end end
            --Game.startTime = timer.curtime()+3 -- make it so it starts on first hit
            --Game.endTime = timer.curtime()+63
            TIMER_PLAYER = ply
            function plyyyquit()
                quitGame(TIMER_PLAYER)
            end
            timer.create("quit_",20,1,plyyyquit)
            scr(0)
            selectNew()
            sendINGAME(UndecorateNick(p.ply:getName()))
        end
    end
    function sendINGAME(name)
        net.start("INGAME")
        net.writeString(name)
        net.send()
    end
    function quitGame(ply)
        timer.remove("quit_")
        if p.ply then
            net.start("show")
            net.writeBit(0)
            net.writeString(UndecorateNick(p.ply:getName()))
            net.writeInt(p.cans,16) -- hits
            net.writeInt(p.allShots,16)
            net.send()
            if Game.His[p.steamid] then
                if Game.His[p.steamid].shotCans < p.cans then
                    --printTable(Game.His)
                    --printTable(p)
                    Game.His[p.steamid] = { ["shotCount"]=p.allShots, ["shotCans"]=p.cans, ["ply"]=p.ply, }
                    --print("New High Score!: " .. tostring(p.cans))
                    sendData()
                end
            else
                --print("no data yet, creating")
                Game.His[p.steamid] = { ["shotCount"]=p.allShots, ["shotCans"]=p.cans, ["ply"]=p.ply, }
                sendData()
            end
            --print(ply:getName() .. " quit game")
        end
        for k,v in pairs(cans) do v:setColor(Color(255,255,255,255)) end
        scr(1)
        p.ply,Game.running,Game.ran = nil,false,false
    end
    
    
    hook.add("PlayerSay",tag,function(ply,text)
        local pre = {["!"]=true,["."]=true,["/"]=true} -- prefixes
        if not pre[string.sub(text,1,1)] then return end
        text = string.sub(text,2,string.len(text))
        local t = string.split(string.lower(text)," ")
        
        if t[1] == "play" and not p.ply then
            startGame(ply)
        elseif t[1] == "quit" and (p.ply == ply or ply == owner()) then
            quitGame(ply)
        elseif t[1] == "save" and ply == owner() then
            sendData()
        elseif t[1] == "stats" and ply == owner() then
            printTable(Game.His)
        elseif t[1] == "screenup" and ply == owner() then
            scr(1)
        elseif t[1] == "screendn" and ply == owner() then
            scr(0)
        end
    end)
    
    hook.add("EntityTakeDamage",tag,function(hTar, hAtt, hInf, hAmount, hType, hPos, hForce) -- HITREG target, attacker, inflictor, amount, type, position, force
        if p.ply then
            if hAtt == p.ply and hInf == p.ply and hType%4096==2 then
            --print(hType)
                p.allShots = p.allShots + 1 -- all shots you take will be counted!
                if hTar==target then
                    if Game.running==false then
                        --print("game started")
                        Game.running = true
                        timer.remove("quit_")
                        Game.startTime = timer.curtime()
                        net.start("INGAMESTART")
                            net.writeFloat(Game.startTime)
                        net.send()
                        Game.endTime = timer.curtime()+60
                    end
                    p.cans = p.cans + 1
                    target:emitSound("Buttons.snd17",0,300)
                    selectNew()
                    --print("Hits: " .. tostring(p.cans))
                elseif table.hasValue(cans, hTar) or hTar == background then
                    p.miss = p.miss + 1
                    --print("Misses: " .. tostring(p.miss))
                end
            elseif hAtt == p.ply and hType%4096!=2 and hInf != p.ply then
                quitGame()
            end
        end
    end)
    
    function scr(n) -- scr(nr) show screen==1 hide screen=0
        if hasPermission("entities.setPos",screen.ent) and hasPermission("entities.setRenderProperty",screen.ent) then
            screen.ent:setPos(background:localToWorld(background:obbCenter()+Vector(0,-48+(48*n),91)))
        end
    end
    
    net.receive("HiScores",function(len,ply)
        if ply != owner() then return end
        local data = net.readString()
        for k,v in pairs(string.split(data,"\n")) do
            DATA = string.split(v,",")
            if DATA[1]!="" then
                Game.His[DATA[1]]={ ["shotCount"]=tonumber(DATA[2]), ["shotCans"]=tonumber(DATA[3]), }
                if find.bySteamID64(DATA[1])[1] then
                    --print(DATA[4] .. " found by steamid64")
                    Game.His[DATA[1]].ply=UndecorateNick(find.bySteamID64(DATA[1])[1]:getName())
                else
                    Game.His[DATA[1]].ply=string.replace(DATA[4],"&%_COMMA",",")
                end
            end
        end
        timer.simple(0.7,syncData)
    end)
    net.receive("startgame",function()
        local ent = net.readEntity()
        startGame(ent)
    end)
    function syncData()
        local data = ""
        for k,v in pairs(Game.His) do
            if type(v.ply)=="string" then
                data = data .. tostring(k) .. "," .. tostring(v.shotCount) .. "," .. tostring(v.shotCans) .. "," .. string.replace(UndecorateNick(v.ply),",","&%_COMMA") .. "\n"
            elseif type(v.ply=="entity") then
                data = data .. tostring(k) .. "," .. tostring(v.shotCount) .. "," .. tostring(v.shotCans) .. "," .. string.replace(UndecorateNick(v.ply:getName()),",","&%_COMMA") .. "\n"
            end
        end
        net.start("syncFS")
        net.writeString(data)
        net.send()
    end
    scr(1)
else -- CLIENT 
-- ADD GETTING SCORES FROM OWNER DB
    local Game = {["His"]={},["Positions"]={}}
    local Hiscores = {}
    if player()==owner() then -- OWNER STUFF
        local fp = "sf_gungame_playerdata.txt"
        function sendData()
            if file.exists(fp) then ----------------------- FILE OPERATIONS SYNCING
                local data = file.read(fp)
                net.start("HiScores")
                net.writeString(data)
                net.send()
            end
        end
        function writeToFile(str)
            file.write(fp,str)
            print("saved data.")
        end
        if !file.exists(fp) then ----------------------- FILE OPERATIONS SYNCING
            print("DATABASE MISSING, CREATING NEW")
            file.write(fp,"") -- file format: SteamID64,HighScoreInCans,AllShotsInCans,LastKnownName
        else
            sendData() -- sync on startup
        end
        net.receive("HiScores",function()
            local a = net.readBit()
            if a==0 then
                local data = net.readString(data)
                writeToFile(data)
            elseif a==1 then
                sendData()
            end
        end)
    end
    function sort(temp)
        local small,steamid = getBig(temp)
        if Game.His[steamid] then
            Game.Positions[#Game.Positions+1]={
                ["steamid"]=Game.His[steamid].steamid, 
                ["shotCount"]=Game.His[steamid].shotCount,
                ["shotCans"]=Game.His[steamid].shotCans, 
                ["ply"]=Game.His[steamid].ply,
            }
            temp[steamid] = nil
            if table.count(temp)>0 then
                sort(temp)
            end
        end
    end
    net.receive("syncFS",function()
        local data = net.readString()
        --print(data)
        for k,v in pairs(string.split(data,"\n")) do
            local D = string.split(v,",")
            function getBig(tab)
                local a = -1
                local b = ""
                for k,v in pairs(tab) do
                    if a < v.shotCans then
                        a = v.shotCans
                        b = v.steamid
                    end
                end
                return a,b
            end
            if D[1]!="" then
                Game.His[D[1]]={ 
                    ["steamid"]=D[1], 
                    ["shotCount"]=tonumber(D[2]), 
                    ["shotCans"]=tonumber(D[3]), 
                    ["ply"]=string.replace(D[4], "&%_COMMA", ",") 
                }
            end
        end
        local tem = Game.His
        Game.Positions = {}
        if Game.His then
            sort(tem)
        end
    end)
    
    local a = render.createFont("Coolvetica", 36, 100, false, false, false, false, 0)
    local ent_ = UndecorateNick(player():getName())
    local hits = 0
    local allShots = 0
    local misses = 0
    local hitPerc = 0
    local highScores = ""
    local PANEL = "MAINMENU"
    local TIMEDISPLAY = false
    local TIME = timer.curtime()
    local offset = 62
    local bH = 186
    local bH2 = 160
    function i(a,b,c,d)
        return a,b+offset,c,d
    end
    net.receive("INGAME",function()
        TIMEDISPLAY = false
        PANEL = "INGAME"
        Game.currentplayingname = net.readString()
    end)
    net.receive("INGAMESTART",function()
        TIMEDISPLAY = true
        TIME = net.readFloat()
    end)
    
    
    function refresh() -- obsolete
        if PANEL == "HIGHSCORES" then
            if Game.His then
                for k,v in pairs(Game.His) do
                    if find.bySteamID64(k)[1] then
                        Game.His[k].ply = UndecorateNick(find.bySteamID64(k)[1]:getName())
                    end
                end
                Game.Positions = {}
                local tem = Game.His
                sort(tem)
            end
        end
    end
    hook.add("render",tag,function()
        if quotaAverage() > quotaMax()*0.8 then return end
        render.setBackgroundColor(Color(0,0,0,0))
        render.setColor(Color(0,0,20,255))
        local x,y = render.cursorPos()
        
        if PANEL == "MAINMENU" then
            render.drawRect(0,offset,512,230)
            render.setColor(Color(200,200,200,255))
            render.drawRect(22    , offset+bH2, 256-22-11, 48) -- PLAY GAME
            render.setColor(Color(200,200,200,255))
            render.drawRect(256+11, offset+bH2, 256-22-22, 48) -- HIGH SCORES
            
            render.setColor(Color(0,0,50,255)) -- INNER BOXES
            render.drawRect(22+4    , offset+bH2+4, 256-22-11-8, 48-8) -- PLAY GAME
            render.setColor(Color(0,0,50,255))
            render.drawRect(256+11+4, offset+bH2+4, 256-22-22-8, 48-8) -- HIGH SCORES
            
            render.setColor(Color(255,255,255,255))
            render.drawText(256,offset+3,"-=Can Shooter=-\nShoot as many cans as you can within 60 seconds.\nHigh Scores will be recorded and try to be accurate ;)\nThe timer will start as soon as you shoot the first can\nYou have 20 seconds to shoot the first one after pressing start\nShotguns and explosives deal damage to all cans so you lose in hit/miss ratio.\nYou can use [prefix]play and [prefix]quit to play and quit the game\n[prefix] = \". / !\"",1)
            render.drawText(22+(256-22-11)/2 ,  (offset+bH2)+(48/3)  , "New Game" , 1)
            render.drawText(256+11+(256-22-11)/2 ,  (offset+bH2)+(48/3)  , "High Scores" , 1)
            if x and y then
                if x>22 and x<256-11 and y>offset+bH2 and y<offset+bH2+48 then
                    if (player():keyDown(1) or player():keyDown(32)) and pressed != true then
                        pressed = true
                    elseif (!player():keyDown(1) and !player():keyDown(32)) and pressed == true then
                        pressed = false
                        net.start("startgame")
                        net.writeEntity(player())
                        net.send()
                        --print("send start game")
                    end
                    render.setColor(Color(255,255,255,100))
                    render.drawRect(22    , offset+bH2, 256-22-11, 48) -- PLAY GAME
                end
                if x>256+11 and x<512-11-22 and y>offset+bH2 and y<offset+bH2+48 then
                    if (player():keyDown(1) or player():keyDown(32)) and pressed != true then
                        pressed = true
                    elseif (!player():keyDown(1) and !player():keyDown(32)) and pressed == true then
                        pressed = false
                        PANEL = "HIGHSCORES"
                        --print("send high scores")
                    end
                    render.setColor(Color(255,255,255,100))
                    render.drawRect(256+11, offset+bH2, 256-22-22, 48) -- HIGH SCORES
                end
            end
        elseif PANEL == "HIGHSCORES" then
            render.drawRect(0,offset,512,230)
            local positions = Game.Positions or {}
            local c,r = 1,0
            local ct = table.count(positions)
            --Game.His[D[1]]={ ["shotCount"]=tonumber(D[2]), ["shotCans"]=tonumber(D[3]), ["ply"]=string.replace(D[4], "&%_COMMA", ",") }
            if ct>0 then
                for k, v in pairs(positions) do
                    if r < 2 then
                        render.setColor(Color((k-1)*36,1-(k*0.1),1):hsvToRGB())
                        render.drawText(30+r*(256-24),offset+42+(c*16),tostring(v.ply),0) -- Name
                        render.drawText(150+30+r*(256-24),offset+42+(c*16),tostring(v.shotCans),1) -- Total Hits
                        if v.shotCans>0 then
                            render.drawText(254+r*(256-24),offset+42+(c*16),tostring(math.round(100*(v.shotCans/v.shotCount),2)) .. "%",2) -- Hit%
                        else
                            render.drawText(254+r*(256-24),offset+42+(c*16),"0%",2) -- Hit%
                        end
                        c = c + 1
                        if c>10 then
                             c = 1
                             r = r + 1
                        end
                    end
                end
            end
            render.setColor(Color(200,200,200,255))
            render.drawRect(22    , offset+22, 512-22-22, 32) -- BACK BUTTON
            render.setColor(Color(0,0,50,255)) -- INNER BOXES
            render.drawRect(22+4    , offset+22+4, 512-22-22-8, 32-8) -- BACK BUTTON
            render.setColor(Color(255,255,255,255))
            render.drawText(256,offset+22+8,"Back",1)
            render.drawText(256,offset+3,"High-Scores (100% Integrity)",1)
            if x and y then
                if x>22 and x<512-22 and y>offset+22 and y<offset+22+32 then
                    render.setColor(Color(255,255,255,100))
                    render.drawRect(22    , offset+22, 512-22-22, 32) -- BACK BUTTON
                    if (player():keyDown(1) or player():keyDown(32)) and pressed != true then
                        pressed = true
                    elseif (!player():keyDown(1) and !player():keyDown(32)) and pressed == true then
                        pressed = false
                        PANEL = "MAINMENU"
                        --print("send get main menu")
                    end
                end
            end
        elseif PANEL == "POSTGAME" then
            render.drawRect(0,offset,512,230)
            render.setColor(Color(200,200,200,255)) -- first box
            render.drawRect(i(20,bH,256-20*2,32))
            render.drawRect(i(20+256,bH,256-20*2,32))
            
            render.setColor(Color(0,0,50,255)) 
            render.drawRect(i(20+4,bH+4,256-20*2-8,32-8))
            render.drawRect(i(20+4+256,bH+4,256-20*2-8,32-8))
            
            render.setColor(Color(255,255,255,255))
            render.drawText(128,bH+offset+8,"Back",1)
            render.drawText(256+128,bH+offset+8,"New Game",1)
            if x and y then
                if x>20 and x<256-20 and y>bH+offset and y<bH+offset+32 then
                    render.setColor(Color(255,255,255,100))
                    render.drawRect(i(20,bH,256-20*2,32))
                    if (player():keyDown(1) or player():keyDown(32)) and pressed != true then
                        pressed = true
                    elseif (!player():keyDown(1) and !player():keyDown(32)) and pressed == true then
                        pressed = false
                        PANEL = "MAINMENU"
                        --print("send get main menu")
                    end
                end
                if x>20+256 and x<512-20 and y>bH+offset and y<bH+offset+32 then
                    render.setColor(Color(255,255,255,100))
                    render.drawRect(i(20+256,bH,256-20*2,32))
                    if (player():keyDown(1) or player():keyDown(32)) and pressed != true then
                        pressed = true
                    elseif (!player():keyDown(1) and !player():keyDown(32)) and pressed == true then
                        pressed = false
                        net.start("startgame")
                        net.writeEntity(player())
                        net.send()
                        --print("send start new game")
                    end
                end
            end
            --render.setFontSize()
            render.setColor(Color(255,255,255,255))
            render.setFont(a)
            if ent_ then
            render.drawText(256,110,ent_,1)
            end
            render.drawText(100,200,"Hits",1)
            render.drawText(100,150,tostring(hits),1)
            render.drawText(512-100,200,"Misses",1)
            
            render.drawText(512-100,150,tostring(allShots-hits),1)
            render.drawText(256,200,"Hit %",1)
            if allShots == 0 then
                render.drawText(256,150,"???",1)
            else
                render.drawText(256,150,tostring(hitPerc),1)
            end
            render.setFont(render.getDefaultFont())
            render.drawText(256,offset+3,"Post-Game Screen",1)
        elseif PANEL == "INGAME" then
            if Game.currentplayingname and TIMEDISPLAY then
                render.setFont(a)
                render.setColor(Color(255,255,255,255))
                render.drawText(256,0,Game.currentplayingname .. " Time: " ..  tostring(math.round(TIME-timer.curtime()+60,1)),1)
                render.setFont(render.getDefaultFont())
            elseif Game.currentplayingname and not TIMEDISPLAY then
                render.setFont(a)
                render.setColor(Color(255,255,255,255))
                render.drawText(256,-6,"Waiting for: " .. Game.currentplayingname,1)
                render.setFont(render.getDefaultFont())
            end
        end
        if (x and y) then -- CURSOR
            if PANEL=="INGAME" then return end
            render.setColor(Color(0,0,0,255))
            render.drawRect(x-2,y-2,4,4)
            render.setColor(Color(255,255,255,255))
            render.drawRect(x-1,y-1,2,2)
        end
        --render.drawText()
    end)
    net.receive("show",function()
        local b = net.readBit()
        if b==0 then
            ent_ = net.readString()
            hits = net.readInt(16)
            allShots = net.readInt(16)
            hitPerc = math.round(hits/allShots*100,2)
            misses = allShots-hits
            --print(ent_,hits,allShots)
            PANEL = "POSTGAME"
        else -- if 1 read scores
            highScores = net.readString()
        end
    end)
end