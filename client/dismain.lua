NamaExec = "0x098" -- the skiddening
main = {}
main.custom_sound = "overused thud"
main.t = "tits are nice ngl"
concommand.Add("main_revive_sound_effect", function(ply, str, tbl, vararg)
    --print(vararg)
    main.custom_sound = tostring(vararg)
end)
concommand.Add("main_aimat", function(ply, str, tbl)
    AimAt(Vector(tonumber(tbl[1]), tonumber(tbl[2]), tonumber(tbl[3])))
end)
concommand.Add("main_bell", function()
    system.FlashWindow()
    sound.PlayFile('sound/buttons/bell1.wav',"",function(cb) cb:Play() end)
end)

RunConsoleCommand("cl_interp_ratio", 0)
RunConsoleCommand("cl_interp", 0)
main.files = {
    "local/fontLib.lua","local/kbLib.lua","local/funcLib.lua","local/allowPM.lua","main.lua"
}
function main.IsNetString(str) -- skidpaste
    local validate,_ = pcall( net.Start, str )
    if validate then
        return validate;
    end
    return false;
end
function reload()
    for k,v in pairs(main.files) do
        include(v)
    end
end
function rel_f()
    for _filekey,_filename in pairs(main.files) do
        if _filename != "main.lua" then  
            include(_filename)
        end
    end
end
col_lime,col_white,col_black,col_red,col_green,col_blue,col_purple,col_yellow = Color(178,255,0),Color(255,255,255),Color(0,0,0),Color(255,0,0),Color(0,255,0),Color(0,0,255),Color(255,0,255),Color(255,255,0)
ent_data = {}
function cl_init() -- put lua and other shit here that require all ents to be ready eg LocalPlayer() stuff
    rel_f() -- mandatory
    local ent_
    hook.Add("Think", "entity_inspect", function()
        
        if LocalPlayer().PlayerTrace then
            if IsValid(LocalPlayer().PlayerTrace.Entity) and LocalPlayer().PlayerTrace.Entity != game.GetWorld() then
                ent_ = LocalPlayer().PlayerTrace.Entity
                ent_data.Model = ent_:GetModel()
                ent_data.Material = ent_:GetMaterial()
                ent_data.Position = ent_:GetPos()
                ent_data.Angle = ent_:GetAngles()
                ent_data.Skin = ent_:GetSkin()
                ent_data.Velocity = ent_:GetVelocity()
                ent_data.This = ent_
                if ent_.GetNetworkVars then
                    ent_data.NVar = ent_:GetNetworkVars()
                end
                if ent_.GetNetworkedVarTable then
                    ent_data.NWVar = ent_:GetNetworkedVarTable()
                end
                ent_data.Health = ts(ent_:Health()) .. " / " .. ts(ent_:GetMaxHealth())
            end
        end
    end)

    self_data = {}
    main.ignorereloadfunx = {
        gmod_tool=true,
        gmod_camera=true,
        weapon_physgun=true,
        weapon_crowbar=true,
        mining_pickaxe=true,
        weapon_slap=true,
        weapon_vape=true,
        weapon_fishing_rod=true,
        none=true,
        remotecontroller=true,
    }
    
    include("local/showPeople.lua")
    if mgn then
        mgn.VOX = function(...) print(...) end
    end


    -- coding or something
    

    if main.isMetastruct() then
        local me = LocalPlayer()
        local prev = 0
        local new = -1
        local _E = ""
        hook.Add("EntityRemoved","OreCounter",function(e)
            timer.Simple(0.1,function()
                new = me:GetNWFloat("ms.Ores.Mult")
                if prev != new then
                    prev = new
                    epoe.MsgN(os.date('%X') .. " | ♦ [Ores] Multiplier is now: " .. ts(new))
                end
            end)
        end)
        
        concommand.Add("main_hoard",function(ply)
            if ply != LocalPlayer() then return end
            for k,v in pairs(ents.FindByClass([[*_item_sent]])) do 
                if v:GetPos():Distance(LocalPlayer():GetPos()) < 100 then
                    v:CallOption("Add to Backpack","__backpack","start")
                end
            end
        end)
        Rox = ents.FindByClass("mining_rock")
        Xen = ents.FindByClass("mining_xen_crystal")
        local RockPos = Vector()
        local hudpaint_string = ""
        local properties_true = false
        --local C_ROCKER = coroutine.create()
        main.e2_override = false
        concommand.Add("main_e2_override", function(a,b,tbl)
            main.e2_override = tobool(tbl[1])
        end)
        local toggler = 0

        local _pos = Vector()
        local _rPos = Vector()
        RockPos = Vector()
        hook.Add("Think","msGlobals",function()
            Xen = ents.FindByClass("mining_xen_crystal")
            Rox = ents.FindByClass("mining_rock")
            --table.sort(Rox, function(a, b) return a:GetHealthEx() > b:GetHealthEx() end)
            Xen = SortDistPly(Xen)
            Rox = SortDistPly(Rox)
            if not table.IsEmpty(Xen) then
                RockPos = Xen[1]:OBBCenterW() + Xen[1]:GetVelocity() * engine.TickInterval()
                if IsValid(self_data.Wep) and self_data.Wep.GetClass then
                    properties_true = (self_data.Wep:GetClass() == "mining_pickaxe" and input.IsMouseDown(MOUSE_LEFT) and not vgui.CursorVisible()) or main.e2_override
                end
            elseif not table.IsEmpty(Rox) then
                if Rox[1].BonusSpots and Rox[1].BonusSpots[1] and Rox[1].BonusSpots[1].Pos then
                    _pos = Rox[1].BonusSpots[1].Pos
                    _rPos:Set(_pos)
                    _rPos:Rotate(Rox[1]:GetAngles())
                    RockPos:Set(Rox[1]:GetPos() + _rPos)
                    --print(RockPos)
                    --_pos:Rotate(-Rox[1]:GetAngles())
                else
                    RockPos = Rox[1]:OBBCenterW() + Rox[1]:GetVelocity() * 2 * engine.TickInterval() - me:GetVelocity()*engine.TickInterval() -- predixion
                end
                if IsValid(self_data.Wep) and self_data.Wep.GetClass then
                    properties_true = self_data.Wep:GetClass() == "mining_pickaxe" and input.IsMouseDown(MOUSE_LEFT) and not vgui.CursorVisible() and RockPos:Distance(p:EyePos()) < 150
                end
            end
        end)
        hook.Add("HUDPaint","msXen",function()
            if not table.IsEmpty(Xen) then
                for k,v in pairs(Xen) do
                    if IsValid(v) then
                        xy = v:OBBCenterW():ToScreen()
                        draw.SimpleTextOutlined(ts(v), "hudpaint_font", math.Clamp(xy.x,100,ScrW()-100), math.Clamp(xy.y,100,ScrH()-100), col_purple, 1, 1, 0.5, col_black)
                    end
                end
            end
        end)
        hook.Add("CreateMove", "RockAimbot", function(ccmd)
            if properties_true and not table.IsEmpty(Rox) and self_data.Wep then
                ccmd:SetViewAngles((RockPos-p:EyePos()):Angle())
            end
        end)
        timer.Create("CheckNearest",5,0,function() 
            if p and p.IsTabbedOut and p:IsTabbedOut() then
                net.Start("tabout") 
                    net.WriteBool(false) 
                net.SendToServer()
            end 
        end)
        
    end

    hook.Add("Think","globalls",function()
        local p = LocalPlayer()
        if LocalPlayer().PlayerTrace then
            this = LocalPlayer().PlayerTrace.Entity
            self_data.AimTraceLength = LocalPlayer().PlayerTrace.StartPos:Distance(p.PlayerTrace.HitPos)
        end
       
        hooks = hook.GetTable()
        self_data.HP = p:Health()
        self_data.AP = p:Armor()
        self_data.Wep = p:GetActiveWeapon() or self_data.Wep
        
        if IsValid(self_data.Wep) then 
            self_data.WepClass = self_data.Wep:GetClass() or self_data.Wep
            if not main.ignorereloadfunx[self_data.WepClass] then
                self_data.Wep.Reload = function(self)
                    cmd('drop;gm_giveswep ' .. self:GetClass())
                end
            end
        end
        
        self_data.Clip1 = self_data.Wep.Clip1 and self_data.Wep:Clip1() or 0 
        self_data.Pos = p:GetPos()
        self_data.Ang = p:GetAngles()
        self_data.EyeAng = p:EyeAngles()
        self_data.HitPos = p:GetEyeTrace().HitPos
        
        hudpaint_string = ""
        for a,b in pairs(self_data) do
            hudpaint_string = hudpaint_string  .. ts(a) .. " : " .. ts(b) .. " | "
        end
    end)
    local count, margin = 0, 5
    local t_hite = 12
    local outlinewidth = 0.8
    local outlinecolor = col_black
    
    
    -- rule of 3rds
    
    
    
    main.scw, main.sch = ScrW(), ScrH()
    local w3, h3 = main.scw/3, main.sch/3
    --[[hook.Add("DrawOverlay","ruleOfThirds",function()
        if not input.IsMouseDown(MOUSE_LEFT) and not vgui.CursorVisible() and self_data.WepClass == "gmod_camera" then
            surface.SetDrawColor(255,255,255,255)
            for i=1,2 do
                surface.DrawLine(w3*i,0,w3*i,main.sch)
                surface.DrawLine(0,h3*i,main.scw,h3*i)
            end
        end
    end)]]--
    hook.Add("HUDPaint","entity_inspect",function()
        -- self_data
        local p = LocalPlayer()
        draw.SimpleTextOutlined(hudpaint_string, "hudpaint_font", main.scw-margin, margin, col_lime, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, outlinewidth, outlinecolor)
        if not ent_data or LocalPlayer().PlayerTrace.Entity == game.GetWorld() then return end
        count = 0
        for k,v in pairs(ent_data) do
            if type(v) == "table" then
                for k_,v_ in pairs(v) do
                    draw.SimpleTextOutlined(ts(k) .. " - " .. ts(k_) .. " : " .. ts(v_) .. "  ", "hudpaint_font", main.scw-margin, t_hite*3+margin+t_hite*count, col_lime, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, outlinewidth, outlinecolor)
                    count = count + 1
                end
            else
                draw.SimpleTextOutlined(ts(k) .. " : " .. ts(v), "hudpaint_font", main.scw-margin, t_hite*3+margin+t_hite*count, col_lime, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, outlinewidth, outlinecolor)
                count = count + 1
            end
        end
    end)
    
    
    hook.Add("CalcViewModelView","minimizedvms",function(wep,vm,oldPos,oldAng,pos,ang)
        return pos-vm:GetUp()*10+vm:GetForward()*25,ang
    end)
    
    hook.Remove("RenderScreenspaceEffects","weapon_lawp")
end -- END OF POST INIT


function util.PlayHEV(...) -- add get stack level 4 or sth idk
    local args = {...}
    print(debug.Trace())
    args = nil
end
hook.Add("InitPostEntity", "Autorun?", function()
    cl_init()
    cmd'easychat_reload'
end)



--print(HTTP(HTTPRF))


cl_init()