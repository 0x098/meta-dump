--@name Chess
--@author bababooey
--@server
-- object oriented one-liner nightmare
shareScripts(false) -- like this works lmao
local col_red = Color(255,0,0,0)
local col_red_nt = Color(255,0,0)
local col_white = Color(255,255,255,255)
if SERVER then
    
    chess = {} -- may the nightmare begin 
    chess.scale = Vector(1, 1, 1) -- not implemented fully
    function spawn(pos, ang, mdl, enpassant)
        local e = holograms.create(pos, ang, mdl, chess.scale)
        e:setColor(enpassant and col_red or col_white)
        return e
    end
        
    chess.p = {} -- p = pieces (lmao)
    chess.p.pos = {
        black = {}, 
        white = {}
    }
    chess.p.rows = { --lineup
        --inner="pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn", -- pawns
        outer="rook,knight,bishop,queen,king,bishop,knight,rook",
        --outer="rook,,,,king,,,rook", -- cheap castling
        inner="pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn", -- kings queens horses etc
        --outer2="queen,queen,queen,queen,queen,queen,queen,queen",
        --inner2="queen,queen,queen,queen,queen,queen,queen,queen",
        --inner="pawn,pawn,pawn,pawn,pawn,pawn,pawn,pawn", -- pawns
    }
    chess.translate = { -- for cycols
        inner=2,
        --inner2=0,
        outer=1,
        --outer2=3,
        white=1,
        black=2,
    }
    chess.translate[1] = "white"
    chess.translate[2] = "black"
    
    chess.invert = {
        ["black"]="white",
        ["white"]="black"
    }
    
     -- blacks > 6 ; whites < 3
    -- whites = 0 blacks = 8
    -- whites then blacks 0 -> 8
    
    
    _vec = Vector(1,1,1)
    vec001 = Vector(0,0,1)
    ang000 = Angle(0,0,0)
    chipPos = chip():getPos()
    chess.ply = {black = false, white = false}
    chess.turn = chess.translate.white
    chess.togrid = function(vec) -- board : 1,1 - 8,8
        _vec = Vector(128, 128, 0)
        --chipPos = chip():getPos()
        chipPos = chess.board.ent:getPos()+vec001*20
        return math.round((vec.x - chipPos.x + _vec.x - 16) / 32) + 1, math.round((vec.y - chipPos.y + _vec.y - 16) / 32) + 1 
    end
    chess.toworld = function(x, y)
        _vec = Vector(128, 128, 0)
        chipPos = chess.board.ent:getPos()+vec001*20
        return chipPos - _vec + Vector( ( (x-1) * 32 + 16), ( (y-1) * 32 + 16), 0 )
    end
    chess.p.activeholos = {}
    chess.p.nonactiveholos = {white = {}, black = {}}
    
    local lastpos = {black={},white={}} -- for use later in the keypress and think hook
    chess.p.move = function(tbl, newx, newy, col)
        lastpos[col]["piecepos"] = chess.toworld(newx, newy)
        --tbl.ent:setPos(chess.toworld(newx, newy))
        tbl.x = newx
        tbl.y = newy
    end
    
    chess.p.getkeyfromtable = function(x_, y_, col)
        if not col then
            for col, tbl in pairs(chess.p.activeholos) do
                for k, v in pairs(tbl) do 
                    if v.x == x_ and v.y == y_ then
                        return k, col, v
                    end
                end
            end
            return false
        elseif chess.p.activeholos[col] then
            for k,v in pairs(chess.p.activeholos[col]) do
                if v.x == x_ and v.y == y_ then
                    return k, col, v
                end
            end
            return false
        end
    end
    
    chess.p.kill = { -- check if its killable and then kill it
        white = function(newx, newy)
            -- chess.p.nonactiveholos
            local k, col, tbl = chess.p.getkeyfromtable(newx, newy)
            --col = chess.invert[col]
            if k and col and tbl then
            
                local x_ = math.max(table.count(chess.p.nonactiveholos[col]), 0)+1
                local y_ = 0
                --print(x_)
                while x_ > 8 do
                    x_ = x_ - 8
                    y_ = y_ + 1
                end
                
                chess.p.nonactiveholos[col][tbl] = k
                tbl.ent:setPos(  chess.toworld(10 + y_, x_)  )
                table.remove(chess.p.activeholos[col], k)
            end
            return true
        end, 
        black = function(newx, newy)
            -- chess.p.nonactiveholos
            local k, col, tbl = chess.p.getkeyfromtable(newx, newy)
            --col = chess.invert[col]
            if k and col and tbl then
            
                local x_ = math.max(table.count(chess.p.nonactiveholos[col]), 0)+1
                local y_ = 0
                --print(x_)
                while x_ > 8 do
                    x_ = x_ - 8
                    y_ = y_ + 1
                end
            
                chess.p.nonactiveholos[col][tbl] = k
                tbl.ent:setPos(  chess.toworld(-1-y_, x_)  )
                table.remove(chess.p.activeholos[col], k)
            end
            return true
        end, 
    }
    
    chess.p.lastEnpassant = {} -- only one enpassant can exist per move https://en.wikipedia.org/wiki/En_passant
    chess.p.enpassant = function( holo, oldx, oldy, newx, newy, col ) -- Y is actually always the same the way this is coded
        chess.p.lastEnpassant["ent"] = spawn( chess.toworld(oldx + math.clamp(newx-oldx, -1, 1), oldy), holo.ent:getAngles(), holo.ent:getModel(), true)
        chess.p.lastEnpassant["realx"] = oldx + math.clamp(newx-oldx, -1, 1)
        chess.p.lastEnpassant["parent"] = holo
        chess.p.lastEnpassant["oldx"] = oldx
        chess.p.lastEnpassant["y"] = oldy
        chess.p.lastEnpassant["newx"] = newx
        chess.p.lastEnpassant["col"] = col
        return true -- cuz its in a return :D
    end
    chess.p.killenpassant = function()
        if chess.p.lastEnpassant.ent and chess.p.lastEnpassant.parent and chess.p.lastEnpassant.parent.ent then
            chess.p.lastEnpassant.ent:remove()
            chess.p.lastEnpassant.parent.ent:remove()
        end
        table.empty(chess.p.lastEnpassant)
        return true
    end
    chess.p.testcollision = function(oldx, oldy, newx, newy, col)
        local xdif, ydif = newx-oldx, newy-oldy
        local xc, yc = math.clamp(xdif,-1,1), math.clamp(ydif,-1,1)
        local xabs, yabs = math.abs(xdif), math.abs(ydif)
        for c = 1, 9 do
            local k, colgot, tbl = chess.p.getkeyfromtable(oldx + xc*c, oldy + yc*c)
            if k and colgot and tbl then
                if chess.invert[colgot]!=col then
                    return c - 1, xdif, ydif, tbl.model
                elseif chess.invert[colgot]==col then
                    return c, xdif, ydif, tbl.model
                end
            end
        end
        return 9, xdif, ydif, "empty"
    end
    chess.p.promotepawn = {
        white = function(newx, newy)
            return newx == 8 and "promote" or true
        end,
        black = function(newx, newy) 
            return newx == 1 and "promote" or true
        end,
    }
    chess.parsemove = {
        pawn = function(holo, oldx, oldy, newx, newy, ply, col)
            --print(newx, newy)
            local isEnPassant = chess.p.lastEnpassant.realx == newx and chess.p.lastEnpassant.y == newy
            local iswhite = 3-(2*chess.translate[col])
            local cankill, newcol = chess.p.getkeyfromtable(newx, newy, chess.invert[col])
            
            local _,col1 = chess.p.getkeyfromtable(newx, newy+1)
            local _,col2 = chess.p.getkeyfromtable(newx, newy-1)
            local didCommitFraud = false
            if holo.initmove == 1 and math.abs(oldx-newx) == 2 and oldy == newy and (col1 == chess.invert[col] or col2 == chess.invert[col]) then
                didCommitFraud = true
            end
            --print(isEnPassant)
            return ( ((1+holo.initmove >= iswhite*(newx-oldx) and (newx-oldx)*iswhite > 0) and (oldy == newy) and !cankill and -- check for no pieces to move str8
            ( (didCommitFraud and chess.p.enpassant(holo, oldx, oldy, newx, newy, col) ) or (!didCommitFraud) ))  -- check for no pieces to move str8
            or (math.abs(oldy-newy) == 1 and (newx-oldx)*iswhite == 1 and ((cankill and newcol == chess.invert[col]) or isEnPassant) and
            ( ( isEnPassant and chess.p.killenpassant() ) or !isEnPassant ) ) )
            and chess.p.promotepawn[col](newx, newy), isEnPassant and "enpassant" -- check for diagonal movement
            or ((oldx == newx and oldy == newy) == true or false)
        end,
        rook = function(holo, oldx, oldy, newx, newy, ply, col) -- moves along straight
            local maxmov, xdif, ydif, mdl = chess.p.testcollision(oldx, oldy, newx, newy, col)
            
            return ((oldx == newx and oldy != newy and math.abs(ydif) <= maxmov) or (oldy == newy and oldx != newx and math.abs(xdif) <= maxmov)) and (mdl or true)
            or ((oldx == newx and oldy == newy) == true or false)
        end,
        knight = function(holo, oldx, oldy, newx, newy, ply, col) -- this mf can hop over so no need to check for pieces inbetween
            local k, colgot, tbl = chess.p.getkeyfromtable(newx, newy)
            return ((math.abs(newx-oldx) == 1 and math.abs(newy-oldy) == 2) or (math.abs(oldx-newx) == 2 and math.abs(newy-oldy) == 1)) and colgot!=col and (tbl and tbl.model or true) 
            or ((oldx == newx and oldy == newy) == true or false)
        end,
        bishop = function(holo, oldx, oldy, newx, newy, ply, col) -- moves diagonally
            local maxmov, xdif, ydif, mdl = chess.p.testcollision(oldx, oldy, newx, newy, col)
            local xabs = math.abs(xdif)
            
            return (xabs == math.abs(ydif) and xabs <= maxmov) and (mdl or true)
            or ((oldx == newx and oldy == newy) == true or false)
        end,
        queen = function(holo, oldx, oldy, newx, newy, ply, col) -- moves diag and str8
            
            local maxmov, xdif, ydif, mdl = chess.p.testcollision(oldx, oldy, newx, newy, col)
            local xabs = math.abs(xdif)
            local yabs = math.abs(ydif)
            
            return (((xabs <= 1 and yabs <= 1) or (xabs == yabs) or
            (oldx == newx and oldy != newy) or (oldy == newy and oldx != newx)) and 
            ((xabs!= 0 and xabs <= maxmov) or (yabs!= 0 and yabs <= maxmov))) and (mdl or true)
            or ((oldx == newx and oldy == newy) == true or false)
        end,
        king = function(holo, oldx, oldy, newx, newy, ply, col) -- one-step mf
            local maxmov = 1
            local xdif = newx-oldx
            local ydif = newy-oldy
            local xabs = math.abs(xdif)
            local yabs = math.abs(ydif)
            local k, colgot, tbl = chess.p.getkeyfromtable(oldx + xdif, oldy + ydif)
            if k and colgot then
                if tbl.model == "rook" and tbl.initmove == 1 and holo.initmove == 1 and not holo.enemycankill then
                    print'hi castling'
                end
                maxmov = chess.invert[colgot]!=col and 0 or 1
            end
            return (xabs <= 1 and yabs <= 1) and ((xabs > 0 and xabs <= maxmov) or (yabs > 0 and yabs <= maxmov)) and (tbl and tbl.model or true)
            or ((oldx == newx and oldy == newy) == true or false)
        end,
    }
    chess.p.kings = {white={},black={}}
    chess.p.reset = function()
        for col, holos in pairs(chess.p.pos) do -- black, white
            chess.p.activeholos[col] = {}
            for row, str in pairs(chess.p.rows) do -- inner, outer
                --chess.p.activeholos[col][row] = {}
                for num_key, type in pairs(string.split(str,",")) do -- pawn, rook, knight...
                    if type == "" then continue end
                    
                    chess.p.activeholos[col][num_key+(8*(chess.translate[row]-1))] = {
                        ent = spawn(
                        chess.toworld(chess.translate[row]+( (9-chess.translate[row]) * (chess.translate[col]-1) ) - (chess.translate[col]-1)*chess.translate[row], num_key),
                        Angle(0,180-180*chess.translate[col],0),
                        chess.p.get(col, type)),
                        
                        x = chess.translate[row]+( (9-chess.translate[row]) * (chess.translate[col]-1) ) - (chess.translate[col]-1)*chess.translate[row],
                        y = num_key,
                        --promoted_to = "",
                        initmove = 1, -- for pawns 2x walk and "castling" 
                        model = type -- for pawns promotions and collision checking
                    }
                    if type == "king" then
                        chess.p.kings[col] = chess.p.activeholos[col][num_key+(8*(chess.translate[row]-1))]
                    end
                end
            end
        end
    end
    chess.p.get = function(col, type)
        return string.format("models/props_phx/games/chess/%s_%s.mdl", col, type)
    end -- white_rook
    
    chess.board = {}
    chess.board.mdl = "models/props_phx/games/chess/board.mdl"
    chess.board.base = "models/hunter/plates/plate6x6.mdl"
    chess.board.spawn = function()
        chess.board.ent = spawn(chip():getPos()-vec001*20, Angle(-90,0,0), chess.board.mdl)
        chess.board.ent:suppressEngineLighting(true)
        chess.board.baseent = prop.create(chip():getPos()-vec001*2, Angle(0,0,0), chess.board.base, true)
    end
    
    chess.setupgame = function()
        holograms.removeAll()
        chess.board.spawn()
        chess.turn = 1 -- white
        -- spawn each piece
        -- Chess.P(ieces)
        chess.p.reset()
    end
    timer.simple(0.5, chess.setupgame)
    local t = {}
    local cmd = ""
    hook.add("PlayerSay","s",function(ply, txt) -- hook "play" and "quit"
        if not isValid(ply) then return end
        t = string.split(txt, " ")
        cmd = t[1]

        if cmd == "<play" then
            chess.ply.white = chess.ply.white or (ply and ply!=chess.ply.black) and ply
            chess.ply.black = chess.ply.black or (ply and ply!=chess.ply.white) and ply
            --print(chess.white,chess.black)
        -- print(chess.black,chess.white)
        -- add player to tables
        elseif cmd == "<quit" then
            --print(chess.white,chess.black)
            chess.ply.white = false and chess.ply.white == ply
            chess.ply.black = false and chess.ply.black == ply
            --print(chess.white,chess.black)
            -- remove player from tables
        end
        if not ply == owner() then return end
        if cmd == "<w" then
            chess.ply.white = owner()
            chess.ply.black = false
            chess.turn = chess.translate.white
        elseif cmd == "<b" then
            chess.ply.white = false
            chess.ply.black = owner()
            chess.turn = chess.translate.black
        elseif cmd == "<debug" then
            -- idk debug?
            printTable(chess.p.activeholos)
        elseif cmd == "<reset" then
            chess.setupgame()
        elseif cmd == "<plist" then
            printTable(chess.ply)
        elseif cmd == "<there" then
            print(chess.p.getkeyfromtable(chess.togrid(ply:getEyeTrace().HitPos)), chess.togrid(ply:getEyeTrace().HitPos))
        end
    end)
    
    local dat, piece -- think? hook below, drawn here so keypress can access and MAYBE someone can type .play and pick a piece faster than this hook
    local lastupdate = {black=timer.curtime(),white=timer.curtime()}
    local counter = {black=0,white=0}
    
    local promoting = {}
    hook.add('keypress', '', function(ply, key)
        --if (ply == chess.ply.white) or (ply == chess.ply.black) then
        
        if ply==chess["ply"][chess.translate[chess.turn]] then
        --print(chess["ply"][chess.translate[chess.turn]])
            if key == 32 then
                local col = chess.translate[chess.turn]
                
                if chess["ply"][col]["pick"] then -- have picked up
                    local x_,y_ = chess.togrid(ply:getEyeTrace().HitPos)
                    local tbl = chess["p"]["activeholos"][col][ chess["ply"][col]["pick"] ]
                    local model = tbl.model
                    local ent = tbl.ent
                    local col = chess.translate[chess.turn]
                    local ply = chess["ply"][col]
                    --printTable(chess["ply"][col])
                    --print(chess.turn)
                    --print(chess["p"]["activeholos"][col][ chess["ply"][col]["pick"] ].x, " :X: ",x_)
                    --print(chess["p"]["activeholos"][col][ chess["ply"][col]["pick"] ].y, " :Y: ",y_)
                    if !(tbl.x == x_ and tbl.y == y_) then -- if not the same pos
                        --print("turn made") -------(holo, oldx, oldy, newx, newy, ply, col)
                        local withinbounds = x_ < 9 and x_ > 0 and y_ < 9 and y_ > 0
                        local canMove, enp = chess.parsemove[model](tbl, tbl.x, tbl.y, x_, y_, ply, col)
                        if withinbounds and canMove then
                            --print(enp)
                            if enp then
                                chess.p.killenpassant()
                                chess.p.kill[col](chess.p.lastEnpassant["newx"], chess.p.lastEnpassant["y"])
                            else 
                                chess.p.kill[col](x_, y_)
                            end
                            
                            chess.p.move( tbl, x_, y_, col )
                            
                            chess["ply"][col]["pick"] = nil
                            
                            tbl.initmove = 0
                            
                            if canMove == "promote" then
                                promoting["ply"] = ply
                                promoting["tbl"] = tbl
                                --printTable(tbl)
                            else
                                chess.turn = ((chess.turn)%2)+1 -- player interval
                            end
                            --print(chess["ply"][chess.invert[chess.translate[chess.turn]]])
                            --net.start'chess'
                                --net.writeInt(1, 8)
                                --net.writeEntity(chess["ply"][chess.invert[chess.translate[chess.turn]]])
                            --net.send()
                            
                        else
                            print(canMove)
                        end
                    else
                        chess["ply"][col]["pick"] = nil
                        --tbl.initmove = 0
                        chess.turn = ((chess.turn)%2)+1 -- player interval
                    end -- move regardless
                    --print(chess.turn)
                elseif promoting["ply"] == ply and promoting.tbl then
                    local x_,y_ = chess.togrid(ply:getEyeTrace().HitPos)
                    local _, _, newtbl = chess.p.getkeyfromtable(x_, y_)
                    if newtbl then
                    --printTable(promoting)
                        if newtbl.model == "pawn" then
                            print'no can do nigga'
                            return 
                        end
                        promoting.tbl.model = newtbl.model
                        promoting.tbl.ent:setModel(chess.p.get(chess.translate[chess.turn], newtbl.model))
                        table.empty(promoting)
                        --chess.turn = ((chess.turn)%2)+1
                    end
                else
                    local x_,y_ = chess.togrid(ply:getEyeTrace().HitPos) -- picking up the mf
                    chess["ply"][col]["pick"] = chess.p.getkeyfromtable(x_, y_, col)
                    --local trash
                    --chess["ply"][col]["pick"] = {x=x_,y=y_}
                    --printTable(chess["ply"][col]["pick"])
                end
                local isking = false
                for col, tbl in pairs(chess.p.activeholos) do -- checkmate checking
                    -- holotable.enemycankill = true
                    for k_pos, holo in pairs(tbl) do -- collision things if KING IN HEAT
                        
                        isking = chess.parsemove[holo.model](holo, holo.x, holo.y, chess.p.kings[chess.invert[col]].x,chess.p.kings[chess.invert[col]].y, ply, col)
                        if isking == "king" then
                            isking = true
                            chess.p.kings[chess.invert[col]].ent:setColor(col_red_nt)
                            chess.p.kings[chess.invert[col]].inheat = true
                            break
                        end
                        chess.p.kings[chess.invert[col]].ent:setColor(col_white)
                        chess.p.kings[chess.invert[col]].inheat = false
                        --print(holo.ent, holo.model)
                        --holo.initmove
                        --holo.model
                        --holo.ent
                        --holo.x
                        --holo.y
                    end
                end
                
            end
        end
    end)
    
    hook.add('think','a',function()
        for col, player in pairs(chess.ply) do
            if player then
                if player.pick then
                    counter[col] = math.min((counter[col]) + 5, 90)
                    lastupdate[col] = timer.curtime()
                    dat = chess.p.activeholos[col][player.pick]
                    piece = dat.ent
                    lastpos[col]["piecepos"] = lastpos[col]["piecepos"] or piece:getPos()
                    piece:setPos( (piece:getPos() + 
                    lastpos[col]["piecepos"] + 
                    Vector(0,0,32*(math.sin(math.rad(counter[col]))^2) ) )/2 )
                elseif dat and dat.ent and !player.pick then
                    counter[col] = math.max((counter[col]) - 5, 0)
                    if counter[col]==0 then
                        --piece:setPos(chess.toworld())
                        lastpos[col]["piecepos"] = nil
                    else
                        piece:setPos( (piece:getPos() + 
                        lastpos[col]["piecepos"] + 
                        Vector(0,0,32*(math.sin(math.rad(counter[col]))^2) ) )/2 )
                        --print(math.sin(math.rad(counter[col]))^2)
                    end
                end
                
            end
        end
        if chess.p.lastEnpassant.ent and isValid(chess.p.lastEnpassant.ent) then
            local col = chess.p.lastEnpassant.ent:getColor()
            if col.a < 128 then
                col.a = col.a + 1
                chess.p.lastEnpassant.ent:setColor(col)
            end
        end
        
    end)
    local i = 1
    for col, ply in pairs(chess.ply) do
        spawn(chipPos, ang000, "models/sprops/misc/alphanum/alphanum_w.mdl") -- models/sprops/misc/alphanum/alphanum_w.mdl
        spawn(chipPos, ang000, "models/sprops/misc/alphanum/alphanum_b.mdl")
    end
    timer.create("kingsoundcreator",0.20,0, function()
        if i > 6 then timer.remove("kingsounds") return end
        if !table.isEmpty(chess.p.kings.white) and !table.isEmpty(chess.p.kings.black) then
            
            if not chess.p.kings.white.ent.s then
                chess.p.kings.white.ent.s = {}
            end
            if not chess.p.kings.black.ent.s then
                chess.p.kings.black.ent.s = {}
            end
            chess.p.kings.black.ent.s[i] = sound.create(chess.p.kings.black.ent, string.format("hostage/hpain/hpain%d.wav", i))
            chess.p.kings.white.ent.s[i] = sound.create(chess.p.kings.black.ent, string.format("hostage/hpain/hpain%d.wav", i))
            i = i + 1
        end
        
    end)
    timer.create("kingfire", 0.33, 0, function()
        for k, v in pairs(chess.p.kings) do
            if v.inheat then
                local ef = effect.create()
                ef:setOrigin(chess.toworld(v.x, v.y)+Vector(0,0,64))
                ef:setScale(10)
                ef:play("BloodImpact")
                local s = table.random(v.ent.s)
                table.random(v.ent.s):stop()
                table.random(v.ent.s):play()
                --print(string.format("hostage/hpain/hpain%d.wav",math.random(1,6)))
                -- CAUSE FIRE AT KINGS POS
            end
        end
    end)
end
