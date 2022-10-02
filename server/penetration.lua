local t = "penetrationheck"
penetratingprops = {}
hook.Add("Think", t, function()
	for k, v in pairs(ents.GetAll()) do
		if v.SpawnTime and v.SpawnTime+0.1 < CurTime() then
			local obj = v.GetPhysicsObject and v:GetPhysicsObject()
			if IsValid(obj) then
				if obj.IsPenetrating and obj:IsPenetrating() then
                    penetratingprops[v] = v.CPPIGetOwner and v:CPPIGetOwner() or true
					--obj:Sleep() 
					--Penetrators[v:CPPIGetOwner()] = CurTime()
					--if v.Remove then
						--SafeRemoveEntity(v)
					--end
					--if 
					--print(tostring(v:CPPIGetOwner()) .. " is penetrating with " .. tostring(v))
                elseif penetratingprops[v] then
                    penetratingprops[v] = nil
                elseif not IsValid(v) then
                    penetratingprops[v] = nil
                end
			end
		end
	end
    if table.Count(penetratingprops) > 10 then
        for k, v in pairs(penetratingprops) do
            if IsValid(k) and k.GetPhysicsObject and IsValid(k:GetPhysicsObject()) then
                k:GetPhysicsObject():EnableMotion(false)
            else
                penetratingprops[k] = nil
            end
        end
    end
end)
hook.Add("PlayerSpawnedProp",t,function(ply, model, ent)
	if ent then
    	ent.SpawnTime = CurTime()
    end
end)
hook.Add("PlayerSpawnedVehicle",t,function(ply, ent)
    if ent then
    	ent.SpawnTime = CurTime()
    end
end)
hook.Add("PlayerSpawnedSENT",t,function(ply, ent)
    if ent then
    	ent.SpawnTime = CurTime()
    end
end)
hook.Add("PlayerSpawnedRagdoll",t,function(ply, model, ent)
	if ent then
    	ent.SpawnTime = CurTime()
    end
end)