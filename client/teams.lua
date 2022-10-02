local t = "PlayerManagement"
local col_join = Color(70,255,70)
local col_leave = Color(255,70,70)
local col_connect = Color(255,255,70)
net.Receive(t, function( len )
	local status = net.ReadInt(3)
	local isdev = net.ReadBit()
	local col = team.GetColor(isdev)
	if status == 0 then -- player_connect
		local networkid = net.ReadString()
		local name = net.ReadString()
		--local countrycode = net.ReadString()
		chat.AddText(col_connect," » ",col, name, col_white, " joining")
	elseif status == 1 or status == 2 then -- player_spawn 1 = FIRST  ; 2 = CONTINUED CUSTOMER
		local userid = net.ReadInt(12)
		local name = net.ReadString()
		local ply = Player(userid)
		--if ply and ply.SteamID then
			chat.AddText(col_join," • ", col, name, col_white, " ( ",col_gold, ply.SteamID and ply:SteamID() or "nil", col_white," ) spawned", status == 1 and " for the first time!" or nil)
		--end
	elseif status == 3 then -- player_disconnect
		local networkid = net.ReadString()
		local name = net.ReadString()
		local reason = net.ReadString()
		chat.AddText(col_leave," « ", col, name, col_white, " left ( ", reason, " )")
	end
end)