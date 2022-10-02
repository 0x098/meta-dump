--- START OF funcLib.lua ---
local main = main or {}
local NamaExec = NamaExec or "0x098"
em = FindMetaTable("Entity")
pm = FindMetaTable("Player")
cm = FindMetaTable("CUserCmd")
wm = FindMetaTable("Weapon")
am = FindMetaTable("Angle")
vm = FindMetaTable("Vector")
cn = FindMetaTable("ConVar")
im = FindMetaTable("IMaterial")

igmac = FindMetaTable("IGModAudioChannel")
vehm = FindMetaTable("Vehicle")
loaded = FindMetaTable("_LOADED")
vmtrx = FindMetaTable("VMatrix")
npcmt = FindMetaTable("NPC")
surfmt = FindMetaTable("SurfaceInfo")
filemt = FindMetaTable("File")
nodegmt = FindMetaTable("Nodegraph")
physcmt = FindMetaTable("PhysCollide")
bspmt = FindMetaTable("Bsp")
physobjmt = FindMetaTable("PhysObj")
csent = FindMetaTable("CSEnt")

function table.IsEmpty( tab )
	return next( tab ) == nil
end
local MetaServers = {
    ["195.154.166.219:27015"]=true,
    ["176.9.65.121:27015"]=true,
    ["66.42.103.116:27015"]=true,
}
function main.isMetastruct()
    local ip = game.GetIPAddress()
    return MetaServers[ip] or false
end

local _BB = {}
_BB.concRun = concommand.Run
if CLIENT then
	function concommand.Run(ply, str, args, str2)
		--print(ply, str, args, str2)
		_BB.concRun(ply,str,args,str2)
	end
	p = LocalPlayer()
	me = p
    net.Receivers.mailgun = function() end
	function util.ScreenShake() return end
	I_ = ents.GetByIndex
	sphere = ents.FindInSphere
	humans = player.GetHumans
	players = player.GetAll
	clean = game.CleanUpMap
	ts = tostring
	CA = chat.AddText
	P = print
	PT = PrintTable
	BNVT = BuildNetworkedVarsTable
    
    local __ply = LocalPlayer
	function CMD(str)
		__ply():ConCommand(ts(str))
	end
    cmd = cmd or CMD
    local stFolderName = "scriptversions/"
    local d = "DATA"
    local ts = tostring
    st = {} -- scipt tester
    
	

	function AimAt(pos)
		p:SetEyeAngles((pos-p:EyePos()):Angle())
	end
	function copy(...)
		local a = {...}
		if #a == 1 then
			easylua.CopyToClipboard(a[1], p)
		else
			easylua.CopyToClipboard(a, p)
		end
		a = nil
	end
	function PredictPos(pos)
		return pos - (LocalPlayer():GetVelocity() * engine.TickInterval())
	end

	local syst1, syst2, syst3, avg, func, E = 0, 0, {}, 0, 0, 50
	local startTime, endTime = 0, 0
    local benchReturnText = ""
	function main.bench(func_)
        benchReturnText = ""
		startTime = SysTime()
		if type(func_) == "function" then
			func = func_
		elseif type(func_) == "string" then
			func = CompileString(func_,"bench_identifier",false)
		else
			return "bench failed cuz type = " .. ts(type(func))
		end
		syst1,syst2,syst3 = 0, 0, {}
		for i=1,E do
			syst1 = SysTime()
			for j=1,1000 do
				func()
			end
			syst2 = SysTime()
			local math = E / math.Clamp(((syst2-syst1)*10),1,50)
			if syst2-syst1 > 0.5 and i > math then
				break
			end
			benchReturnText = benchReturnText .. tostring(i) .. "'th bench: " .. tostring(syst2-syst1) .. "\n"
			syst3[i]=syst2-syst1
		end
		avg = 0
		for k,v in pairs(syst3) do
			avg = avg + v
		end
		endTime = SysTime()
		return benchReturnText .. "bench result average: " .. tostring(avg / #syst3) .. " total time used: " .. tostring(endTime-startTime) .. "\n"
	end

	function em:OBBCenterW()
		if IsValid(self) then
			return self:LocalToWorld(self:OBBCenter())
		end
	end

	
	function spawnThis(amount)
		amount = amount or 1
		for i=1,amount do
			cmd("gm_spawn " .. p.PlayerTrace.Entity:GetModel())
		end	
	end

	function thisTable()
		PT(self_data.this:GetTable())
	end
	
	BRANCH = "Gucci Fridge S" .. ts(os.time())
	VERSION = tonumber(os.date("%y%m%d"))
	VERSIONSTR = os.date("%Y.%m.%d")
	_VERSION = "Lua 6.9"
	
	function string.leet(string_)
		local repLib = {
			["e"] = "3",
			["i"] = "1",
			["s"] = "5",
			["a"] = "4",
			["o"] = "o",
		}
		stringMod = string_
		for k,v in pairs(repLib) do
			stringMod = string.replace(stringMod,k,v)
		end
		return stringMod
	end
    function util.wrap(...) return {...} end -- kek
    
    function hook.RestoreAll() 
        for k,v in pairs(hook.GetFailed()) do
            local e,_f = next(v)
            hook.Restore(k, e)
        end
    end
    
    if main.isMetastruct() then -- META CUMSTRUCT SPECIFIC
        function main.allOreMults()
            local tbl = {}
            for k, v in pairs(player.GetAll()) do
                tbl[v] = v:GetNWFloat'ms.Ores.Mult'
            end
            PrintTable(tbl)
            return tbl
        end
        local lib = "\xef\xbc\x91,\xef\xbc\x92,\xef\xbc\x93,\xef\xbc\x94,\xef\xbc\x95,\xef\xbc\x96,\xef\xbc\x97,\xef\xbc\x98,\xef\xbc\x99,\xef\xbc\x90,\xef\xbc\x8b,\xc2\xb4,\xef\xbd\x91,\xef\xbd\x97,\xef\xbd\x85,\xef\xbd\x92,\xef\xbd\x94,\xef\xbd\x99,\xef\xbd\x95,\xef\xbd\x89,\xef\xbd\x8f,\xef\xbd\x90,\xc3\xbc,\xc3\xb5,\xef\xbd\x81,\xef\xbd\x93,\xef\xbd\x84,\xef\xbd\x86,\xef\xbd\x87,\xef\xbd\x88,\xef\xbd\x8a,\xef\xbd\x8b,\xef\xbd\x8c,\xc3\xb6,\xc3\xa4,\xef\xbc\x87,<,\xef\xbd\x9a,\xef\xbd\x98,\xef\xbd\x83,\xef\xbd\x96,\xef\xbd\x82,\xef\xbd\x8e,\xef\xbd\x8d,\xef\xbc\x8c,\xef\xbc\x8e,\xef\xbc\x8d,\xef\xbc\x81,\",\xef\xbc\x83,\xc2\xa4,\xef\xbc\x85,\xef\xbc\x86,\xef\xbc\x8f,\xef\xbc\x88,\xef\xbc\x89,\xef\xbc\x9d,\xef\xbc\x9f,`,\xef\xbc\xb1,\xef\xbc\xb7,\xef\xbc\xa5,\xef\xbc\xb2,\xef\xbc\xb4,\xef\xbc\xb9,\xef\xbc\xb5,\xef\xbc\xa9,\xef\xbc\xaf,\xef\xbc\xb0,\xc3\x9c,\xc3\x95,\xef\xbc\xa1,\xef\xbc\xb3,\xef\xbc\xa4,\xef\xbc\xa6,\xef\xbc\xa7,\xef\xbc\xa8,\xef\xbc\xaa,\xef\xbc\xab,\xef\xbc\xac,\xc3\x96,\xc3\x84,\xef\xbc\x8a,>,\xef\xbc\xba,\xef\xbc\xb8,\xef\xbc\xa3,\xef\xbc\xb6,\xef\xbc\xa2,\xef\xbc\xae,\xef\xbc\xad,\xef\xbc\x9b,\xef\xbc\x9a,_,\xe3\x80\x80"
        local libt = [[1_;2_;3_;4_;5_;6_;7_;8_;9_;0_;+_;´_;q_;w_;e_;r_;t_;y_;u_;i_;o_;p_;ü_;õ_;a_;s_;d_;f_;g_;h_;j_;k_;l_;ö_;ä_;'_;<_;z_;x_;c_;v_;b_;n_;m_;,_;._;-_;!_;"_;#_;¤_;%_;&_;/_;(_;)_;=_;?_;`_;Q_;W_;E_;R_;T_;Y_;U_;I_;O_;P_;Ü_;Õ_;A_;S_;D_;F_;G_;H_;J_;K_;L_;Ö_;Ä_;*_;>_;Z_;X_;C_;V_;B_;N_;M_;;_;:_;__; ]]
        local to = lib:Split','
        local _from = libt:Split'_;'
        local from = {}
        for k,v in pairs(_from) do
            from[v] = k
        end
        function string.vapor(str)
            local new = {}
            for k, v in pairs(str:split'') do
                new[k] = to[from[v]]
            end
            return table.concat(new)
        end
               
        function main.gtrx() -- FIND TREX GAME ENTINDEX
            local LS = ents.FindByClass("lua_screen")
            for k,v in pairs(LS) do
                if(v["DATA"]["place"] == "trex_game") then
                    P("TRex game EntIndex = " .. ts(v:EntIndex()))
                    LS = nil
                    return v
                end
            end
        end
        function say(str)
            cmd("say_local " .. ts(str))
        end    
        function sit(input)
            if type(input) == "string" then
                local plys = player.GetAll()
                for k,v in pairs(plys) do
                    if string.find(string.lower(v:GetName()),input) then
                        cmd('aowl go _' .. tostring(v:EntIndex()) .. ';aowl siton _' .. tostring(v:EntIndex()))
                        return
                    end
                end
            elseif type(input) == "Player" then
                cmd('aowl go _' .. tostring(input:EntIndex()) .. ';aowl siton _' .. tostring(input:EntIndex()))
            end
        end
        --[[local _f = game.OpenBSP and game.OpenBSP()
        local MapProps = _f.staticprops and _f.staticprops.entries or false
        if MapProps then
            function game.GetMapProp(position)
                position = position or self_data.HitPos
                table.sort(MapProps, function(a,b) return a.Origin:Distance(self_data.HitPos) < b.Origin:Distance(self_data.HitPos) end)
                return MapProps[1].PropType, MapProps[1].Origin
            end
        end]]
        function main.steal(ent_)
            local ret
            if ent_ then
                if ent_.coh_cached_msg_data.msg then
                    SetClipboardText(ent_.coh_cached_msg_data.msg)
                    return ent_.coh_cached_msg_data.msg
                end
                    
            elseif IsValid(LocalPlayer():GetEyeTrace().Entity) then
                if LocalPlayer():GetEyeTrace().Entity.coh_cached_msg_data.msg then
                    SetClipboardText(LocalPlayer():GetEyeTrace().Entity.coh_cached_msg_data.msg)
                    return LocalPlayer():GetEyeTrace().Entity.coh_cached_msg_data.msg
                end
            end
            --return ret
        end
        function ms.SlideDMS(ply, msg, amount)
            net.SendToServer()
            if ply:IsPlayer() then ply = ply:SteamID() end
            amount = amount or 10
            msg = msg or "Hi, don't mind me just spamming your DMs :)"
            for i=1,amount do
                msg = msg
                timer.Simple(0+i*0.3,function()
                    net.Start("pmail")
                        net.WriteBit(false)
                        net.WriteString(msg)
                        net.WriteString(ply)
                    net.SendToServer()
                end)
            end
        end
        ms.CorePosition = Vector(-11682, -8560, 2472)
        function ms.OresToPoints(ply, Copper, Silver, Gold, Platinum)
            Copper = Copper or 0
            Silver = Silver or 0
            Platinum = Platinum or 0
            Gold = Gold or 0
            ply = ply or LocalPlayer()
            local rSettings = ms.Ores.__R
            return "Points/Coins Worth: "..string.Comma(math.Round(((Copper * rSettings[0].Worth)+(Silver * rSettings[1].Worth)+(Gold* rSettings[2].Worth)+(Platinum * rSettings[3].Worth))* (1 + ply:GetNWFloat("ms.Ores.Mult"))))
        end
    end

    local baddies = {
        ["{"]=true,
        ["}"]=true,
        [""]=true,
        ["end"]=true
    }
    function util.GetRealLineCount(theCode)
        local count = 0
        for k,v in pairs(theCode:Split("\n")) do 
            if baddies[string.Trim(v)] or string.sub(string.Trim(v),1,2)=="--" or string.sub(string.Trim(v),1,1)=="#" then 
                count = count + 1
                print(v)
            end
        end
        return count
    end

	function DistFromPly(_ent)
		return _ent:LocalToWorld(_ent:OBBCenter()):Distance(p:EyePos())
	end
	function SortDistPly(_table)
		if(table.IsEmpty(_table)) then return _table end
		table.sort(_table, function( a, b )
			return a:LocalToWorld(a:OBBCenter()):Distance( p:EyePos() ) < b:LocalToWorld(b:OBBCenter()):Distance( p:EyePos() ) 
		end )
		return _table
	end
	function vgui.RemoveByTitle(_str)
        if type(_str) != "string" then print'kys' end
        for k,v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if v.GetTitle and v:GetTitle():lower() == _str:lower() then
                v:Remove()
                print(v:GetTitle())
            end
        end
    end
    
    
	function pm.GetHeadPos(ent)
		local model = ent:GetModel():lower() or ""
		if model:find("crow") or model:find("seagull") or model:find("pigeon") then
			return ent:LocalToWorld(ent:OBBCenter() + Vector(0, 0, -5))
		elseif ent:GetAttachment(ent:LookupAttachment("eyes")) ~= nil then
			return ent:GetAttachment(ent:LookupAttachment("eyes")).Pos
        end
		return ent:WorldSpaceCenter()
	end
	function pm.LookupBonePosition(ent, bone) 
		if(ent:IsValid() and ent:Alive()) then
			return ent:GetBonePosition(ent:LookupBone(bone))
		end
        return ent:WorldSpaceCenter()
	end

end

MsgC(Color(178,255,0,255),'[' .. tostring(NamaExec) .. '] Functions Loaded\n')