
hook.Add("OnEntityCreated", "stickyslams", function(ent) -- sticky slams
    timer.Simple(0.001, function() 
        if IsValid(ent) and ent.GetClass and ent:GetClass() == "npc_satchel" then
            --print'a'
            local ply = ent:GetInternalVariable("m_hThrower")
            --print(ply)
            ent:CPPISetOwner( ply )
            local sticky = ply:GetInfoNum('slam_sticky', 0)
            if sticky != 0 and not ent.collisioncallbackexists then
                ent.collisioncallbackexists = true
                ent.id = ent:AddCallback("PhysicsCollide", function(collider, coldata)
                    --print'collided'
                    --if not ent.tabled then PrintTable(coldata) end
                    ent:SetPos(coldata.HitPos)
                    ent:SetAngles(coldata.HitNormal:Angle()-Angle(90,0,0))
                    ent:GetPhysicsObject():Sleep()
                    ent:RemoveCallback("Think", ent.id)
                end)
            end
        end
    end)
end)

function cmd(str, arg)
    RunConsoleCommand(str, arg)
end

PropBlacklist = {
    
}
hook.Add('PlayerSpawnObject','blacklist',function( ply , mdl )
	if PropBlacklist[mdl:lower()] then
		ply:Kill()
		return false
	end
end)

util.AddNetworkString("ServerMessage")
function Say(...)
    local a = {...}
    
    local str = ""
    for k,v in pairs(a) do
        str = str .. " " .. tostring(v)
    end
    if type(a[1])=="Player" then
        net.Start("ServerMessage")
        net.WriteString(str)
        net.Send(a[1])
    else
        net.Start("ServerMessage")
        net.WriteString(str)
        net.Broadcast()
    end
end


local tag = "FinishedLoading"
hook.Add("InitPostEntity", tag, function()
	hook.Add("PlayerInitialSpawn", tag, function(ply)
		if ply:IsBot() then return end
		ply._just_spawned = true
	end)
	hook.Add("SetupMove", tag, function(ply, _, ucmd)
		if ply._just_spawned and not ucmd:IsForced() then
			ply._just_spawned = nil
			hook.Run(tag, ply)
		end
	end)
	hook.Remove("InitPostEntity", tag)
end)

local nstr = "SuggestionBox"
local recentlySuggested = {}
util.AddNetworkString( nstr )
net.Receive( nstr, function(len, ply)
    if IsValid(ply) and ply.GetPlaytime and ply:GetPlaytime() > 3600 * 2 then -- if playtime > 2h
        if (recentlySuggested[ply:SteamID()] and recentlySuggested[ply:SteamID()] < CurTime() - 300) or not recentlySuggested[ply:SteamID()] then -- 5 min delay
            local suggestion = net.ReadString()
            MsgC("[", ply:SteamID(), "]", ts(ply):Replace("Player ",""), col_chat_white, (" suggested %q\n"):format(suggestion) )
            suggestion = os.date("[%d/%m/%Y - %H:%M:%S] ", os.time()) .. "[" .. ply:SteamID() .. "]" .. ply:Nick() .. " Suggested: " .. suggestion:PatternSafe():gsub("\n\n",". "):gsub("\r\r",". ").."\n"
            if file.Exists(nstr .. ".txt","DATA") then
                file.Append(nstr .. ".txt", suggestion)
            else
                file.Write(nstr .. ".txt", suggestion)
            end
            recentlySuggested[ply:SteamID()] = CurTime()
        end
    end
end)

karmagod = karmagod or {}
karmagod.players = karmagod.players or {}
local efdata = EffectData()
hook.Add("EntityTakeDamage","karmagod",function(ply, dmg)
    local criminal = dmg:GetAttacker()
	if karmagod.players[ply] then
		local infl = dmg:GetInflictor()
		efdata:SetOrigin(dmg:GetDamagePosition())
		util.Effect("cball_explode", efdata)
		infl:EmitSound("weapons/ric" .. math.random(1,5) .. ".wav")
		if type(criminal) ~= "Player" then
			if infl.CPPIGetOwner and IsValid(infl:CPPIGetOwner()) then
				if infl:CPPIGetOwner() ~= ply then
					infl = infl:CPPIGetOwner()
				end
			end
		end
		local po=ply:GetPhysicsObject()
		if IsValid(po) then
			--print("bounce",po,-po:GetVelocity()*2)
			po:SetVelocity(-po:GetVelocity()*2)
			po:AddAngleVelocity(-po:GetAngleVelocity())
		end
		if IsValid(criminal) and criminal~=ply and not karmagod.players[criminal] then
			local po = criminal:GetPhysicsObject()
			local df = dmg:GetDamageForce()
			dmg:SetAttacker(ply)
			dmg:SetInflictor(ply)
			dmg:SetDamageForce(df)
			dmg:SetReportedPosition(ply:GetPos()-(ply:GetPos()-criminal:GetPos())*2)
			criminal:TakeDamageInfo(dmg)
		end
		return true
	end
end)

DevZone = DevZone or {}
DevZone.Maps = DevZone and DevZone.Maps or {}
DevZone.Maps["gm_boreas"] = {
    pos1 = Vector (-13330.400390625, -5858.1831054688, -8183.0068359375),
    pos2 = Vector (-15866.606445313, -7950.0571289063, -3872.8271484375)
}
DevZone.Maps["gm_construct"] = {
    pos1 = Vector (-1604.031, -3231.969, 2304.031),
    pos2 = Vector (-3003.969, -2244.031, 2815.969)
}
DevZone.Maps["gm_drivingmap_workshop"] = {
    pos1 = Vector (10697.031, -4250.031, 561.969),
    pos2 = Vector (10149.959, -3699.969, 842.031)
}
if DevZone.Maps[ game.GetMap() ] then
    DevZone.Pos1 = DevZone.Maps[ game.GetMap() ].pos1
    DevZone.Pos2 = DevZone.Maps[ game.GetMap() ].pos2
    DevZone.IsPermitted = DevZone and DevZone.IsPermitted or {}
    local center = (DevZone.Pos1+DevZone.Pos2)/2
    local boxSize = center-DevZone.Pos1
    local pos3 = Vector(0,0,0)
    local PreviousPermissionStatus = {}
    pos3:Set(center)
    pos3.z = DevZone.Pos1.z > DevZone.Pos2.z and DevZone.Pos2.z or DevZone.Pos1.z
    hook.Add("OnPhysgunPickup","devzone",function(ply, ent)
        if type(ent) == "Player" then
            --print("grant",ply, ent)
            PreviousPermissionStatus[ent] = DevZone.IsPermitted[ent] or nil
            DevZone.IsPermitted[ent] = true
        end
    end)
    hook.Add("PhysgunDrop","devzone",function(ply, ent)
        if type(ent) == "Player" then
            --print("revoke",ply, ent)
            DevZone.IsPermitted[ent] = PreviousPermissionStatus[ent] or nil
            PreviousPermissionStatus[ent] = nil
        end
    end)
    DevZone.ReCalc = function(self)
        center = (self.Pos1 + self.Pos2)/2
        boxSize = center-self.Pos1
        pos3:Set(center)
        pos3.z = self.Pos1.z > self.Pos2.z and self.Pos2.z or self.Pos1.z
    end
    local e = ents.FindInBox(center-boxSize, center+boxSize)
    hook.Add("Think","devzone",function()
        e = ents.FindInBox(center-boxSize, center+boxSize)
        for k, ent in pairs(e) do
            if ent.IsPlayer and ent:IsPlayer() and !(ent.IsSuperAdmin and ent:IsSuperAdmin()) and not DevZone.IsPermitted[ent] then
                ent:SetPos(ent:GetPos()+(pos3-ent:GetShootPos()+Vector(0,0,64)):Angle():Forward()*(boxSize/3))
            elseif IsValid(ent) and (ent:GetClass():find("prop", 0, true) or ent:GetClass():find("npc",0,true) or ent:GetClass():find("player",0,true)) and not ent:CreatedByMap() and not ent:IsPlayer() then
                if not (ent.CPPIGetOwner and ent:CPPIGetOwner() and ent:CPPIGetOwner().IsSuperAdmin and ent:CPPIGetOwner():IsSuperAdmin()) then
                    ent:SetPos(ent:GetPos()+(pos3-ent:GetPos()+Vector(0,0,64)):Angle():Forward()*(boxSize/3))
                end
            end
        end
    end)
else
    timer.Create("DevZone Lacking", 3, 1, function()
        print(game.GetMap() .. " is lacking DevZone™.\n")
    end)
end
concommand.Add("p", function(_,cmd)
    local players = player.GetAll()
    if next(players) then
        print("[" .. cmd .. "] players list")
        for k, v in ipairs(players) do
            print(("[%s] %s[%s]:"):format(cmd, v:Name(), v:EntIndex(), v:SteamID()))
        end
    else
        print("[" .. cmd .. "] no players online")
    end
    players = nil
end)

hook.Add("PlayerSay","chats",function( sender, text, teamChat )
	if teamChat then return end
	if text:lower():find("kek",0,true) then
		sender:EmitSound'npc/metropolice/vo/chuckle.wav' -- underrated sound
	end
    if text:lower():find("top kek",0,true) then
		--sender:EmitSound'npc/metropolice/vo/chuckle.wav'
        for i=1,5 do
            timer.Simple(0.03*i, function() sender:EmitSound'npc/metropolice/vo/chuckle.wav' end)
        end
	end
    if text:lower():find("ultra kek",0,true) then
        for i=1,10 do
            timer.Simple(0.03*i, function() sender:EmitSound("npc/metropolice/vo/chuckle.wav", 100+i*i*10, 100+i*i*10) end)
        end
    end
end)

--[[hook.Remove("PlayerSpawn","give_weapons", function(ply, bool)
    --ply:Give'none'
    ply:CMD'gm_giveswep none'
end)]]
local tag="sh_physgun"
hook.Add("PhysgunPickup",tag,function(ply, ent)
    --if !ent:CPPIGetOwner() and ent:GetClass()!="player" then return false end
    if ply:IsSuperAdmin() and ent:GetClass()=="player" then
        if SERVER then
            ent:RemoveFlags(FL_FROZEN)
            ent:SetMoveType(MOVETYPE_NOCLIP)
        end
        return true 
    end
end)
hook.Add("PhysgunDrop",tag,function(ply, ent)
    if ent:GetClass()=="player" then
        if ply:KeyDown(2048) then
            ent:AddFlags(FL_FROZEN)
            ent:SetMoveType(MOVETYPE_NOCLIP)
        else
            ent:SetMoveType(MOVETYPE_WALK)
        end
    end
end)

hook.Add("InitPostEntity","physenv",function()
	physenv.SetPerformanceSettings({ MaxCollisionChecksPerTimestep = 1024, MaxCollisionsPerObjectPerTimestep = 256, MaxAngularVelocity = 16384, MaxVelocity = 16384 })
end)

