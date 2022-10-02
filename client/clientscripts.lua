col_red = Color(255,0,0)
col_gold = Color(204,240,33)
col_green = Color(0,255,0)
col_blue = Color(0,0,255)
col_yellow = Color(255,255,0)
col_cyan = Color(0,255,255)
col_purple = Color(255,0,255)
col_black = Color(25,25,25)
col_white = Color(255,255,255)
col_gray = Color(170,170,170)
col_darkblue = Color(0,0,160)
col_darkorange = Color(200,180,0)
surface.CreateFont( "sumFont", {
	font = "Arial", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 15,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
local convarexists = SQLConVar'cl_ragdoll_alivetime'
if not convarexists then
    SQLConVar('cl_ragdoll_alivetime', 10)
end
local cl_ragdoll_alivetime = tonumber(SQLConVar'cl_ragdoll_alivetime') or 10

concommand.Add("cl_ragdoll_alivetime", function(a,b,args)
	cl_ragdoll_alivetime = tonumber(args[1]) or 10
    SQLConVar("cl_ragdoll_alivetime", cl_ragdoll_alivetime)
end, function() return {"cl_ragdoll_alivetime " .. ts(cl_ragdoll_alivetime)} end)
hook.Add("CreateClientsideRagdoll","Ragdoll Remover", function(ent, rag)
	if IsValid(rag) and tonumber(cl_ragdoll_alivetime) or 3 >= 1 then
		timer.Simple( cl_ragdoll_alivetime, function() if rag and IsValid(rag) and rag.SetSaveValue then rag:SetSaveValue( "m_bFadingOut", true ) end end)
	end
end)

concommand.Add("aimbot", function(a,b,c,d) a:CMD'kill' a:Say'am gay :D' end, function() return {"Loads ragehacks."} end, "Loads ragehacks!")

local svft = engine.ServerFrameTime()
local transparency = 0
local tb = {}
local function show_server_performance()
    svft, stdthing = engine.ServerFrameTime()
    transparency = transparency + svft + stdthing
    table.insert(tb, svft)
    if #tb > 200 then
        table.remove(tb, 1)
    end
    transparency = math.max(transparency * 0.1, 0)
    --if transparency > 0.02 then
    --end
    for k, v in ipairs(tb) do
        surface.SetDrawColor( v*512, 255-v*512, 0 )
        surface.DrawLine(ScrW()-k, 0, ScrW()-k, v*ScrH()*0.1+1) -- simple math. really.
    end
end
local t = "Server Performance Monitor"
local CV = SQLConVar('cl_show_server_performance')
if not CV then SQLConVar('cl_show_server_performance', 0) end
if CV and tonumber(CV) > 0 then
    hook.Add('HUDPaint', t, show_server_performance)
end
concommand.Add("cl_show_server_performance", function(a, b, args, d)
	if args[1] and tonumber(args[1]) > 0 then
        SQLConVar("cl_show_server_performance", args[1])
		hook.Add("HUDPaint", t, show_server_performance)
	else
		hook.Remove("HUDPaint", t)
        SQLConVar("cl_show_server_performance", 0)
	end
end)

local col = 0
net.Receive("ServerMessage", function()
    local str = net.ReadString()
    col = col + 5
    local col = HSVToColor(col, 1, 1)
    chat.AddText(col,"[SERVER]:" , col_white, str)
end)

hook.Add("InitPostEntity","PostInitBruv", function()
    local me = LocalPlayer()
    local em = FindMetaTable("Entity")
    local function BunnyHop(pCmd)
        if(em.GetMoveType(me) == MOVETYPE_NOCLIP or 
            LocalPlayer():IsFlagSet(1024) or 
                me:Team() == TEAM_SPECTATOR or 
                    me:Health() < 1 or not me:Alive()) then return end
        if(!me:IsOnGround() && pCmd:KeyDown(IN_JUMP)) then
            pCmd:RemoveKey(IN_JUMP)
        end
    end
    hook.Add("CreateMove","Bhop Ban",function(pcmd)
        BunnyHop(pcmd)
    end)
    hook.Remove("InitPostEntity","Bhop Ban")

    
    local tag="nametags"
    surface.CreateFont(tag, {
        font = "Tahoma",
        size = 200,
        weight = 650,
    } )
    
    hook.Add("PostDrawTranslucentRenderables", tag, function() 
        for k,v in pairs(player.GetAll()) do
            if v:IsDormant() then continue end
            if v==LocalPlayer() and !v:ShouldDrawLocalPlayer() then continue end
            local ply_or_ragdoll=v:GetRagdollEntity()==NULL and v or v:GetRagdollEntity()
            local head_attach=ply_or_ragdoll:LookupBone("ValveBiped.Bip01_Head1")
            if not head_attach then continue end
            local head,headang = ply_or_ragdoll:GetBonePosition(head_attach)
            if head == ply_or_ragdoll:GetPos() then
                head = ply_or_ragdoll:GetBoneMatrix(head_attach)
            end
            local head_up= ply_or_ragdoll:GetUp()
            local pos = head+head_up*20
            local ang = LocalPlayer() and EyeAngles() or (pos-EyePos()):Angle()
            --local angmod=Angle(0,math.sin(CurTime()+v._randoffset)*15,math.cos(CurTime()+v._randoffset)*5)
            --local ang=(v==LocalPlayer()) and EyeAngles()+angmod or (pos-EyePos()):Angle()+angmod
            ang:RotateAroundAxis( ang:Up(), -90 )
            ang:RotateAroundAxis( ang:Forward(), 90 )
            cam.Start3D2D(pos,ang,0.03)
                local text = v:Name()
                local namecolor = team.GetColor( v:Team() )
                local aimnorm=EyeAngles():Forward()
                local themnorm=(pos-EyePos()):GetNormalized()
                local distalpha=255-math.Clamp(-3500+EyePos():Distance(pos)*5,0,255)
                local diralpha=math.Clamp(2000-(1-aimnorm:Dot(themnorm))*(EyePos():Distance(pos)*50),0,255)
                namecolor.a = distalpha < diralpha and distalpha or diralpha
                draw.SimpleText(text,tag,5,10,Color(0,0,0,namecolor.a),TEXT_ALIGN_CENTER)
                draw.SimpleText(text,tag,0, 0,namecolor,TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end)
end)

function sus() print'e' return "e" end

CreateConVar("slam_sticky", "0", {FCVAR_ARCHIVE, FCVAR_USERINFO},"Sticky Slams?") -- sticky slams
hook.Add("PlayerBindPress","stickyslams",function(ply, bind, pressed, code)
    --print(ply, bind, pressed, code)
    if ply != LocalPlayer() then return end
    if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "weapon_slam" then
        if bind == "+reload" then
            ply:CMD("slam_sticky " .. tostring(ply:GetInfoNum('slam_sticky', 0) == 1 and 0 or 1))
            chat.AddText(col_green,"[Sticky SLAM]: " .. (ply:GetInfoNum('slam_sticky', 0) == 1 and "OFF" or "ON"))
        end
    end
end)

function cmd(str)
    me:ConCommand(tostring(str))
end
function Say(...)
	local first = true
	local msg = ""
	for k, v in pairs{...} do
	  	if first then
			first = false
	   	else
			msg=msg .. ' '
	   	end
	   	msg=msg .. tostring(v)
	end
	msg = msg:gsub("\n",""):gsub(";",":"):gsub("\"","'")
	RunConsoleCommand("say", msg)
end


sphere = ents.FindInSphere
--[[ -- SHITCODE!??!?!
hook.Remove("Think","luahelper",function()
    me = LocalPlayer()
    if IsValid(me) then
        if me.PlayerTrace then
            this = me.PlayerTrace.Entity
            here = me:GetPos()
            there = me.PlayerTrace.HitPos
            us = sphere(here or me.GetPos and me:GetPos(), 333)
            all = player.GetAll()
        end
        if me.GetActiveWeapon then
            wep = me:GetActiveWeapon()
        end
    end
end)]]

local gw = game.GetWorld
function GetHostName()
    return gw():GetNWString'ServerName'
end

local keys = {}
for k, num in pairs(_G) do
	if ts(k):lower():find'key_' then
		keys[k]=num
	end
end

local help = "Show binds. Can pass 1 argument. [ binds input ]. Will attempt to find autocompletive suggestion. Omitting ALL will print all keys."

concommand.Add("binds",function(ply, cm, args)
	if next(args) != nil then
		args[1] = args[1]:Replace("[^a-zA-Z0-9]",""):Trim():lower():Replace("ctrl","control"):Replace("ctr","contr"):Replace("ct","cont"):Replace("+","plus"):Replace("-","min"):Replace("*","mult"):Replace("/","slash")
		--PrintTable(args,args[1],args[1]=="all")
		if args[1]=="all" then
			for k, v in pairs(keys) do
				--if k:lower():find(args[1]) then
					print(k, input.LookupKeyBinding(v) == nil and '[NOTHING BOUND]' or input.LookupKeyBinding(v))
				--end
			end
		end
		
		if !args[1]:find('key_',1,true) and args[1] then 
			if keys['KEY_' .. args[1]:upper()] then
				print(input.LookupKeyBinding(keys['KEY_' .. args[1]:upper()])==nil and "[NOTHING BOUND]" or input.LookupKeyBinding(keys['KEY_' .. args[1]:upper()]))
			else
				for k, v in pairs(keys) do
					if k:lower():find(args[1],1,true) then
						print(k, input.LookupKeyBinding(v) == nil and '[NOTHING BOUND]' or input.LookupKeyBinding(v))
					end
				end
			end
		elseif keys[args[1]:upper()] and not args[2] then
			if isnumber(tonumber(args[1])) then
				print(input.LookupKeyBinding(tonumber(args[1])))
				print'21'
			else
				print(input.LookupKeyBinding(keys[args[1]:upper()])==nil and "[NOTHING BOUND]" or input.LookupKeyBinding(keys[args[1]:upper()]))
		 	end
		else
			for k, v in pairs(keys) do
				if k:lower():find(args[1],1,true) then
					print(k, input.LookupKeyBinding(v) == nil and '[NOTHING BOUND]' or input.LookupKeyBinding(v))
				end
			end
		end
	end
end, function(cm, args) 
		local res = {}
		args = args:Replace("[^a-zA-Z0-9]",""):Trim():lower():Replace("ctrl","control"):Replace("ctr","contr"):Replace("ct","cont")
		for k, v in pairs(keys) do
			if k:lower():find(args,1,true) then
				res[#res+1] = "binds " .. ts(k)
			end
		end
		return res
	--end 
end, help)

--increasing speed undo
local _CODE = input.GetKeyCode(input.LookupBinding("gmod_undo"))
local undoing = false
local keycode = 0
local time = 1
local UDFID = "this is a undo fast identifier not to collide with any other timers"
local _ply = LocalPlayer()
local function alittleundo()
	if input.IsKeyDown(keycode) and not table.IsEmpty(undo.GetTable()) then
		time = math.max(time * 0.7, 0.05)
		_ply:CMD'gmod_undo'
		timer.Adjust(UDFID, time)
	end
end

hook.Add("PlayerBindPress","undofast", function(ply, bind, pressed, code)
	if code == input.GetKeyCode(input.LookupBinding("gmod_undo")) then
		_ply = ply
		keycode = code
		time = 1
		timer.Create(UDFID, time, 0, function()
			time = time * 0.7
			ply:CMD'gmod_undo'
			timer.Create(UDFID, time, 0, alittleundo)
		end)
	end
end)
hook.Add("PlayerButtonUp","undofast", function(ply, code)
	if code == input.GetKeyCode(input.LookupBinding("gmod_undo")) then
		timer.Remove(UDFID)
		--print'removed undofast'
	end
end)

hook.Add("OnGamemodeLoaded","f3menu",function() -- string.format this mf
    local f3menuenabled = false
    local leftside, rightside = {},{}
    local rft, round, abs, ts, ticki, gethostn, entt, pcount, gamegetskilllevel = RealFrameTime, math.Round, math.abs, tostring, engine.TickInterval, GetHostName, ents.GetAll, player.GetCount, game.GetSkillLevel
    local ply = LocalPlayer
    leftside[1] = "Garry's Mod 13 (" .. VERSIONSTR .. "/" .. GAMEMODE_NAME .. ")"
    local dxver = tostring(render.GetDXLevel())
    local hdrsup = render.SupportsHDR() and "Yes" or "No"
    local hdren = render.GetHDREnabled() and "Yes" or "No"
    local pxr14 = render.SupportsPixelShaders_1_4() and "Yes" or "No"
    local pxr20 = render.SupportsPixelShaders_2_0() and "Yes" or "No"
    local vxr20 = render.SupportsVertexShaders_2_0() and "Yes" or "No"
    local str2 = " fps DX: " .. dxver .. " HDR: " .. hdren .. "/" .. hdrsup
    local str3 = gethostn()
    local me_ = NULL
    local myPos = Vector()
    local a = Angle()
    local dormants = 0
    local strmaxply = "/" .. game.MaxPlayers()
    for k, v in pairs(entt()) do
        dormants = dormants + (v:IsDormant() and 1 or 0)
    end
    leftside[3] = "S: " .. pxr14 .. "/" .. pxr20 .. "/" .. vxr20
    leftside[7] = game.GetMap()
    leftside[8] = ""

    rightside[1] = _VERSION .. " " .. jit.arch
    rightside[2] = BRANCH
    rightside[4] = ""
    rightside[5] = "Display: " .. ScrW() .. "x" .. ScrH()
    rightside[6] = ""
    local ents___ = entt()
    timer.Create("F3Menu", 0.25, 0, function()
        if f3menuenabled then
            if not IsValid(me_) then me_ = ply() return end
            ents___ = entt()
            myPos = me_:GetPos()
            a = me_:EyeAngles()
            dormants = 0
            for k, v in pairs(ents___) do
                dormants = dormants + (v:IsDormant() and 1 or 0)
            end
            leftside[2] = ts(round(1/rft())) .."/" .. me_:GetInfo'fps_max' .. str2
            leftside[4] = GetHostName() .. " @" .. ts(round(ticki()*1000,3)) .. " ms ticks"
            leftside[5] = "E: " .. ts(dormants) .. "/" .. ts(#ents___)
            leftside[6] = "P: " .. ts(pcount()) .. strmaxply
            leftside[12] = "Difficulty: " .. ts(gamegetskilllevel()) .. " // " .. (ts(round(me_:GetPlaytime()/3600, 2)) or "0.00") .. "h"
            rightside[3] = (round(gcinfo()/1000) or round(collectgarbage'count'/1000)) .. "MB"
        end
    end)
    local cachedEnt
    local str_west = "WEST (Towards negative X)"
    local str_east = "EAST (Towards positive X)"
    local str_north = "NORTH (Towards positive Y)"
    local str_south = "SOUTH (Towards negative Y)"
    local str_facing = "Facing: "
    local str_slash = " / "
    local str_hitpos = "HitPos: "
    local str_xyz = "XYZ: "
    hook.Add("Think","F3Menu",function()
        if f3menuenabled then
            if not IsValid(me_) then me_ = ply() return end
            myPos = me_:GetPos()
            a = me_:EyeAngles()
            leftside[9] = str_xyz .. ts(round(myPos.x, 3)) .. str_slash .. ts(round(myPos.y, 3)) .. str_slash .. ts(round(myPos.z, 3))
            if me_.PlayerTrace then
                leftside[10] = str_hitpos .. ts(round(me_.PlayerTrace.HitPos.x)) .. str_slash .. ts(round(me_.PlayerTrace.HitPos.y)) .. str_slash .. ts(round(me_.PlayerTrace.HitPos.z))
                if IsValid(me_.PlayerTrace.Entity) or IsValid(cachedEnt) then
                    cachedEnt = IsValid(me_.PlayerTrace.Entity) and me_.PlayerTrace.Entity or IsValid(cachedEnt) and cachedEnt
                    rightside[6] = ts(cachedEnt)
                    rightside[7] = (ts(cachedEnt:Health()) or "0") .. "hp"
                    rightside[8] = ts(cachedEnt:GetModel()) or ""
                    --rightside[10] = ts(me_.PlayerTrace.Entity
                else
                    rightside[6] = ""
                    rightside[7] = ""
                    rightside[8] = ""
                
                end
            end
            leftside[11] = str_facing .. (abs(a.yaw) > 135 and str_west or abs(a.yaw) < 45 and str_east or a.yaw > 45 and str_north or str_south) .. " (" .. ts(round(a.yaw)) .. str_slash .. ts(round(a.pitch)) .. ")" -- string.format this?
        end
    end)
    local font = "Default"
    hook.Add("HUDPaint","F3Menu",function()
        if f3menuenabled then
            for k, txt in pairs(leftside) do
                draw.SimpleTextOutlined(txt,font,1,k*10, col_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, col_black)
            end
            for k, txt in pairs(rightside) do
                draw.SimpleTextOutlined(txt,font,ScrW()-1,k*10, col_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, col_black)
            end
        end
    end)
    local autocomp = {"f3menu on","f3menu 1","f3menu true"}
    concommand.Add("f3menu", function(ply, cmd, args)
        f3menuenabled = not f3menuenabled
    end)
    hook.Remove("OnGamemodeLoaded","f3menu")
end)
