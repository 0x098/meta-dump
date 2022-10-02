local targets = { npc_metropolice=true, npc_combine_s=true, npc_manhack=true } -- last modified in 06.05.2021
local scrw,scrh = ScrW()/2,ScrH()/2
local final = {}
local c__ = ""
local enttable = ents.GetAll()
local visibles = {}
local traceinfo = {}
local xy = {x=1,y=1}
local firstTarget = {}
local sequentialfirsttarget = {}
local srt1,srt2 = 0,0
local keydownhist = false
local AIMTARGETPOS = Vector(0,0,0)
local co1
PT(targets)
local function getNPCs()
	final = {}
	enttable = ents.GetAll()
	for k, v in pairs(enttable) do
		if targets[v:GetClass()] and v:Health() > 0 then
			final[v] = {
				hp=v:Health(),
				xy=v:OBBCenterW():ToScreen()
			}
		end
	end
	return final
end

final = getNPCs()
local function sort_out_to_visibles()
	visibles = {}
	for k,v in pairs(final) do
		if IsValid(k) then
			traceinfo = util.QuickTrace(p:EyePos(), k:OBBCenterW()-p:EyePos(), p)
			if traceinfo.Entity == k then
                visibles[k]=true
			else
				visibles[k]=false
			end
		end
	end
	for k,v in pairs(visibles) do
		if v then
			firstTarget[k]=final[k]
		else
			firstTarget[k]=nil
		end
	end
    sequentialfirsttarget = {}
	for k,v in pairs(firstTarget) do
		if IsValid(k) then
            sequentialfirsttarget[#sequentialfirsttarget+1] = k
		end
	end
	
    table.sort(sequentialfirsttarget, function(a, b)
        return p:OBBCenterW():Distance(a:OBBCenterW()) < p:OBBCenterW():Distance(b:OBBCenterW())
	end)
end
local cMet = false
local attach
local VPANGLES
local function GETAIMBOTTARGETPOS()
    if sequentialfirsttarget[1]:GetClass()!="npc_manhack" then
        attach = sequentialfirsttarget[1]:GetAttachment(sequentialfirsttarget[1]:LookupAttachment("eyes"))
        AIMTARGETPOS = attach.Pos
    else
        AIMTARGETPOS = sequentialfirsttarget[1]:OBBCenterW()
    end
end

hook.Add("Think","something",function()
	VPANGLES = p:GetViewPunchAngles()
	sort_out_to_visibles()
	cMet = not table.IsEmpty(sequentialfirsttarget)
    if not co1 or not coroutine.resume( co1 ) then
		co1 = coroutine.create( GETAIMBOTTARGETPOS )
		coroutine.resume( co1 )
    end

end)

local wpnlist = {
    weapon_357=true,
    weapon_pistol=true,
    weapon_crossbow=true,
    weapon_ar2=true,
    weapon_shotgun=true,
    weapon_smg1=true,
    weapon_crowbar=true
}

hook.Add("CreateMove","Aimbot?",function(ccmd)
    if input.IsMouseDown(MOUSE_LEFT) and wpnlist[self_data.WepClass] and p and cMet then
        ccmd:SetViewAngles( ( AIMTARGETPOS - p:EyePos() ):Angle()-VPANGLES )
    end
end)


hook.Add("OnEntityCreated", "something", function(ent)
	for k,v in pairs(final) do
		if not IsValid(k) then
			final[k] = nil
		end
	end
	if not IsValid(ent) then print("FALSE ENTITY CREATED: " .. ts(ent)) return end
	if targets[ent:GetClass()] and ent:Health() > 0 then
		final[ent] = {
			hp = ent:Health(),
			xy = ent:OBBCenterW():ToScreen()
		}
	end
end)

hook.Add("HUDPaint","NPC_HUD",function()
	for k,v in pairs(final) do
		if IsValid(k) then
			xy = k:OBBCenterW():ToScreen()
			draw.SimpleTextOutlined(ts(k:Health()), "hudpaint_font", xy.x, xy.y, col_red, 1, 1, 1, col_black)
		end
	end
	if not table.IsEmpty(sequentialfirsttarget) then
		if IsValid(sequentialfirsttarget[1]) then
			xy = sequentialfirsttarget[1]:OBBCenterW():ToScreen()
			draw.SimpleTextOutlined("Target: " .. ts(sequentialfirsttarget[1]:Health()),"hudpaint_font", xy.x, xy.y, col_green, 1, 1, 1, col_black)
		end
	end
end)

MsgC(col_green,"IDK bruv seems like it worken")