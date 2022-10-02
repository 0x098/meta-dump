p = LocalPlayer()
CMD = CMD or function(str)
  p:ConCommand(tostring(str))
end
hook.Add("Think", "autoheal", function()
	if p:Health() < 80 and p:Health() > 1 then
		CMD("msitems equip minimedkit")
		if p:GetActiveItem() then
			p:GetActiveItem():CallOption([[Use]], [[OnUse]], p)
		end
	end
end)


local RCC = debug.getupvalues(RunConsoleCommand).RCC or RunConsoleCommand -- concommand detour
function RunConsoleCommand(...)
	local ae = {...}
	local ea = ae[1]
	print(table.concat(ae, " "))
	table.remove(ae,1)
	RCC(ea, unpack(ae))
end

local nwt = debug.getupvalues(net.WriteTable).nwt or net.WriteTable
function net.WriteTable(tbl)
	nwt(tbl)
	debug.Trace()
	net.LastTable = tbl
	PrintTable(net.LastTable)
end



local res = {}
local s = ""
local _C = "+"
local _H = "-"
local _V = "|"
local _N = "\n"
local _FIN = ""
timer.Create("f2k", 3, 0, function()
	table.Empty(res)
	s = file.Read("cursongf2k.txt","BASE_PATH")
	for i=1, #s+2 do
		table.insert(res, (i==1 or i==#s+2) and _C or _H )
	end
	table.insert(res, _N) -- hehe
	table.insert(res, _V)
	table.insert(res, s)
	table.insert(res, _V)
	table.insert(res, _N)
	for i=1, #s+2 do
		table.insert(res, (i==1 or i==#s+2) and _C or _H )
	end
	_FIN = table.concat(res)
end)
hooks.FinishChat.rtchat = nil
hook.Add("Think","f2k",function()
	rtchat.StartChat()
	rtchat.QueueMessage(_FIN)
	rtchat.SendQueue()
end)


local me = LocalPlayer()
lines = file.Read("npc_lines.txt","DATA"):Split'\r\n'

local doRespond = false
local line = ""
local lastmsg = ""
hooks.OnPlayerChat.NPC = function(pl, msg, tm, ded, locl)
	if not IsValid(me) then me = LocalPlayer() end
	if pl == me then return end
	if msg == lastmsg then return end
	lastmsg = msg
	--if #msg < 10 then return end
	
	msg = msg:lower()
	
	doRespond = false
	
	for k, v in ipairs(lines) do
		if #v < 10 and v:lower() == msg then
			--print'literally'
			doRespond = true 
			break
		elseif #v >= 10 and msg:find(v, 0, true) then
			--print('not literally', v, msg, msg:find(v, 0, true))
			doRespond = true
			break
		end
		--print(k,v,msg,doRespond)
	end
	--print(doRespond)
	if not doRespond then return end
	timer.Create("Balls", math.Rand(2, 4), 1, function()
		line = table.Random(lines)
		while line == msg do
			line = table.Random(lines)
		end
		if locl then SayLocal(line)
		else Say(line) end
	end)
end



-- a little lua'ing
local _runee = NULL
local _msgee = ""
local thr
local function MSG(ply, text)
	if msg and IsValid(ply) then
		net.Start("pmail")
	        net.WriteBit(false)
	        net.WriteString(text)
	        net.WriteString(ply:SteamID())
	    net.SendToServer()
	elseif msg and not IsValid(ply) then
		say(msg)
	end
end
local function kys(a)
	debug.sethook()
	thr = nil
end
local me = LocalPlayer()
hook.Add("OnPlayerChat", "Lua-Meme", function(ply, text)
	--if ply == me then return end
	if text:sub(1,3) !=  "_nt" then return end
	local cood = text:sub(5, #text)
	local f = CompileString(cood != "" and #cood > 0 and cood,"",falqse)
	if type(f) == "function" then
		saylocal("Running shitcood from: ", ply:GetName())
		_runee = ply
		_msgee = text
		thr = coroutine.create(f)
		debug.sethook(thr, kys, "c", 100000)
		coroutine.resume(thr)
	else
		local msg = type(f) == "table" and table.concat(f,"\n") or type(f) == "string" and f or "a little erroring"
		MSG(ply, msg)
	end
end)

-- creator of sex
local hxcallo = msitems.Classes.hax_monitor.CallOption -- HAX COMMAND DETOUR
msitems.Classes.hax_monitor.CallOption = function(name, func, ...)
	local ae = {...}
	print("Hax CallOption: ", name,func,unpack(ae))
	hxcallo(name, func, unpack(ae))
end


local songName = ""
    local STREM_URL = "https://skymedia.babahhcdn.com/NRJdnb"
    local txt = ""
    local ntxt = ""
    local col = Color(255,0,255,255) -- adjust color if needed
    timer.Create("chekSonk", 1, 0, function()
        if not MediaPlayer or not MediaPlayer.List then timer.Remove("chekSonk") print("mediaplayer stream ting removed") end
        if table.IsEmpty(MediaPlayer.List) then return end
        for k,v in pairs(MediaPlayer.List) do
            if v._Media then
                if v._Media.url == STREM_URL then
                    sound.PlayURL( STREM_URL, "noplay", 
                    function(ac) 
                        sky_plus_stream = ac
                        if sky_plus_stream then
                            ntxt = sky_plus_stream:GetTagsMeta()
                            if txt != ntxt and string.sub(ntxt,14,ntxt:len()-2) != "Sky Plus DNB" then
                                txt = ntxt
                                MsgC(col,"    [Sky Plus DNB]\n    ",string.sub(txt,14,txt:len()-2),"\n") -- pyramids!
                            end
                        end
                    end)
                end
            end
        end
    end)

local tars = sphere(p:GetPos(),500)
local tars_temp = {}
local targetPos = Vector()
local conditions = false
local justreloaded = 0
for k,v in pairs(tars) do
	if IsValid(v) and v:GetModel() and string.find(v:GetModel():lower(),"popcan") and v:GetMaterial():lower() == "models/debug/debugwhite" then
		tars_temp[#tars_temp+1] = v
		print(v)
	end
end

hook.Add('think','a',function() -- the can shooter aimbot lmao
	conditions = not vgui.CursorVisible and input.IsMouseDown(107) and self_data.WepClass == "weapon_g3sg1"
	if justreloaded > 1000 and self_data.Clip1 < 2 and self_data.WepClass == "weapon_g3sg1" then
		justreloaded = 0
		cmd'aowl drop;gm_giveswep weapon_g3sg1'
	end
	justreloaded = justreloaded + 1
	for k, v in pairs(tars_temp) do
		print(v)
		if v:GetColor().a > 10 then
			targetPos = v:OBBCenterW()
			print(targetPos)
			--return
		end
	end
end)

hook.Add("CreateMove",'a',function(pcmd)
	if conditions then
		pcmd:SetViewAngles( (targetPos-p:EyePos()):Angle()-p:GetViewPunchAngles()*0.45 )
	end
end)

function pmdb()
	PT(tars_temp)
	PT(targetPos)
	PT(conditions)
end




local t_e = {
	["mining_xen_crystal"] = true,
}
hook.Add("OnEntityCreated", "sus", function( e )
	if t_e[e:GetModel()] then
		local pos = e:GetPos()
		cmd'main_bell'
		cmd(("main_aimat %d %d %d"):format(pos.x, pos.y, pos.z))
	end
end)

hook.Add("HUDPaint","sus",function(depth, skybox, is3dskybox)
    cam.Start3D()
        for k, v in pairs(Rox) do
            if v:IsValid() then
                v:DrawModel()
            end
        end
        for k, v in pairs(Xen) do
            if v:IsValid() then
                v:DrawModel()
            end
        end
    cam.End3D()
end)


PrintTable(plys)
hook.Add("Think",t_,function()
	FreeCam = input.IsKeyDown(KEY_T) and !vgui.CursorVisible()
	for k, v in pairs(plys) do
		if not IsValid(v) then
			table.remove(plys, k)
		end
	end
	plys = sortdist(plys)
	closest = plys[1]
	if type(closest)=="Player" and closest.GetPos then
		local _offset = ply:GetPos() - closest:GetPos() + heightOffset
		local offset = (_offset:GetNormalized())*32 
		_table.origin = closest:EyePos() - offset + heightOffset
		_table.angles = _offset:Angle()
	end
	if not BALL then
		BALL = BALL or ClientsideModel("models/hunter/misc/sphere1x1.mdl")
		BALL:SetPos(ply:EyePos())
		BALL:SetParent(ply:GetViewModel())
		BALL:SetMaterial("!ball")
		BALL:Spawn()
	end
end)
_Frame = vgui.Create( "DFrame" )
_Frame:SetSize( 400, 200)
_Frame:SetPos(0, 0)
--_Frame:Center()
_Frame:SetVisible( true )
_Frame:ShowCloseButton( false )
_Frame:SetTitle"amogus"
function _Frame:OnClose()
	_Frame:Remove()
end
function _Frame:Paint( w, h )
	if not _Frame then self:Close() end
	local x, y = self:GetPos()
	local old = DisableClipping( true ) -- Avoid issues introduced by the natural clipping of Panel rendering
	_table.x = x
	_table.y = y
	_table.w = w
	_table.h = h
	render.RenderView( _table )
	DisableClipping( old )
end


local BALL = ClientsideModel("models/hunter/misc/sphere1x1.mdl")
BALL:SetPos(ply:EyePos())
BALL:SetParent(ply:GetViewModel())
BALL:SetMaterial("!ball")
BALL:Spawn()
if _Frame then _Frame:Remove() end
local CMAT = CreateMaterial("ball", "UnlitGeneric", {
	["$basetexture"] = "models/debug/debugwhite", 
})


local me = me -- meme
local s = "hello okayu, please pick up my batteries"
local s2 = "steal my panties"
local supposedProfit = 0
hook.Add("OnPlayerChat","sus",function(ply, s_)
	print(ply,me,ply==me)
	if ply == me then return end
	supposedProfit = 0
	if s_:lower():find(s, 0, true) then
		local batteries = ents.FindByClass'battery_item_sent'
		for k, v in pairs(batteries) do
			if v:GetPos():Distance(me:GetPos()) < 70 then
				supposedProfit = supposedProfit + 1
				v:CallOption("Add to Backpack","__backpack","start")
			end
		end
		timer.Simple(0.5, function()
			if supposedProfit > 0 then 
				cmd("aowl dropcoins " .. tostring((supposedProfit^1.5)*10000))
				Say(string.anime(("Ty so much %s, here, have %d"):format(ply:Nick(), (supposedProfit^1.5)*10000)))
			else 
				Say(string.anime("I couldn't reach any batteries!")) 
			end
		end)
	elseif s_:lower():find(s2, 0, true) then
		Say(string.anime(("No, %s! I will not steal any panties!"):format(ply:Nick())))
	end
end)



local lines = file.Read("npc_lines.txt","DATA"):Split'\r\n'
timer.Create("NPCLines",1,0,function()
	timer.Adjust("NPCLines", math.random(5,30))
	local sentc = table.Random(lines)
	Say(sentc)
	sentc = nil
end)




rtr = rtr or {}
rtr.title = rtr.title or ""
if !timer.Exists'radio' then
	http.Fetch("https://scraper2.onlineradiobox.com/ee.skyplusdnb?l=999999999", function(a) rtr.title = util.JSONToTable(a).title end)
	timer.Create("radio",10,0,function()
		http.Fetch("https://scraper2.onlineradiobox.com/ee.skyplusdnb?l=999999999", function(a) rtr.title = util.JSONToTable(a).title end)
	end)
end
rtr.s = ""
rtr.titlehist = ""
hook.Add("Think","sus",function()
	if rtr.title != rtr.titlehist then
		rtr.titlehist = rtr.title
		rtr.s = ""
		rtr.line1 = ""
		rtr.line2 = "\n| " .. rtr.title .. " |\n"
		rtr.line3 = ""
		for i=1, #rtr.title+4 do
			rtr.s = rtr.s .. ((i == 1 or i==#rtr.title+4) and "+" or "-")
			rtr.line1 = rtr.line1 .. ((i == 1 or i==#rtr.title+4) and "+" or "-")
		end
		rtr.s = rtr.s .. "\n| " .. rtr.title .. " |\n"
		for i=1, #rtr.title+4 do
			rtr.s = rtr.s .. ((i == 1 or i==#rtr.title+4) and "+" or "-")
			rtr.line3 = rtr.line3 .. ((i == 1 or i==#rtr.title+4) and "+" or "-")
		end
	end
	rtchat.StartChat()
	rtchat.QueueMessage(rtr.s or "fetching...")
	rtchat.SendQueue()
end)
timer.Create("rtrmovement", 1, 0, function()


end)
hook.Add("HUDPaint","sus",function()
	draw.DrawText(rtr.s, "DefaultFixed", 201, 16, color_black, TEXT_ALIGN_LEFT)
	draw.DrawText(rtr.s, "DefaultFixed", 200, 15, color_white, TEXT_ALIGN_LEFT)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawLine(0, 0, 3, 3)
end)