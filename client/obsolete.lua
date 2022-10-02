-- RESPAWN WEAPONS  [[ !!!!!!!!!!!!!!!! SCUFFED CODE BEWARE !!!!!!!!!!!!!!!! ]]
local wl = list.Get'Weapon'
local _q
local autocomplete_ret = {}
local rl = {}
local q = SQLConVar'cl_respawn_weapons'

gameevent.Listen("player_spawn")

local function cl_respawn_weapons_ondie(data)
	timer.Simple(0.3, function()
		if IsValid(LocalPlayer()) and Player(data.userid) == LocalPlayer() and LocalPlayer():Alive() then
			if not table.IsEmpty(rl) then
				local c = 0
				for k, v in pairs(rl) do 
					if c > table.Count(wl) then return end -- limit the weapon count, 1 of each is enough
					c = c + 1
					LocalPlayer():CMD("gm_giveswep " .. ts(k))
				end
			end
		end
	end)
end

concommand.Add("cl_respawn_weapons",function(ply, c, args)
    local hooktable = hook.GetTable()
    args[1] = table.concat(args, ",")
	if args[1] then
		args[1] = args[1]:Trim():PatternSafe():gsub("  ",""):gsub(", ",","):gsub(",,",","):gsub(",,",",") -- "WHAT ABOUT THE ',,' IN HERE?"
	end
	if not args[1] then MsgC(col_gold,"[Respawn Weapons] ",col_white, SQLConVar'cl_respawn_weapons',"\n","--Hint: To disable respawn weapons input \"\" instead\n") return end
	if (args[1] == "") and hooktable.player_spawn and hooktable.player_spawn.cl_respawn_weapons then hook.Remove("player_spawn","cl_respawn_weapons") MsgC(col_gold,"[Respawn Weapons Disabled]\n") return end
	if (args[1] == "") then return end
	if not IsValid(ply) then return end
	table.Empty(rl)
	for k, v in pairs(args[1]:Split',') do
		if wl[v] then
			rl[v] = true
		end
	end
	if not table.IsEmpty(rl) and not (hooktable.player_spawn or hooktable.player_spawn and hooktable.player_spawn.cl_respawn_weapons) then
		hook.Add("player_spawn","cl_respawn_weapons", cl_respawn_weapons_ondie)
		MsgC(col_gold,"[Respawn Weapons Enabled]\n")
	end
	MsgC(col_gold,"[Respawn Weapons] ", col_white, (args[1] != "") and args[1] or "[NONE]","\n" )
	SQLConVar("cl_respawn_weapons", args[1])
end, function(cmd, arg)
	wl = list.Get'Weapon' -- refresh maybe someone add another weapon yk
	autocomplete_ret = {}
	if arg:find(",", 0, true) then
		local last, count = arg:PatternSafe():gsub("[%w_]-,","") -- get the last word
		local b4last = arg:PatternSafe():gsub("[ %w_]+$","") -- get everything before the last word [[ I KNOW I COULD'VE USED arg:sub(#last,#arg)]]
		for k, v in pairs( wl ) do
			if k:Trim():lower():find(last:Trim():lower(), 0, true) then
				autocomplete_ret[#autocomplete_ret+1] = cmd .. ts(b4last) .. ts(k)
			end
		end
		return autocomplete_ret
	else
		for k, v in pairs( wl ) do
			if k:Trim():lower():find(arg:Trim():lower(), 0, true) then
				autocomplete_ret[#autocomplete_ret+1] = cmd .. " " .. ts(k)
			end
		end
		return autocomplete_ret
	end
	
end, "Weapons to give when player respawns. Essential weapons remain. Consult with devs if you wish to change that.")



if not q then
	SQLConVar("cl_respawn_weapons","")
else
	_q = SQLConVar'cl_respawn_weapons'
	if _q != "" and _q:Trim():PatternSafe():gsub(",","") != "" then
		for k, v in pairs(_q:Split',') do rl[v]=true end
		hook.Add("player_spawn", "cl_respawn_weapons", cl_respawn_weapons_ondie)
	end
end

