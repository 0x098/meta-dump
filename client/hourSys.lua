local tag = "HourSys"
hook.Add("InitPostEntity",tag,function()
    --LocalPlayer():SetAllowWeaponsInVehicle( true )
    local me = LocalPlayer()
    local convarexists = SQLConVar("cl_show_playtime")
    if convarexists==false then
        SQLConVar("cl_show_playtime",0)
    end

    local cl_show_playtime = tonumber(SQLConVar("cl_show_playtime"))
    local col_white = col_white or Color(255,255,255)
    local col_black = col_black or Color(0,0,0)

    if cl_show_playtime == 1 then
        hook.Add("HUDPaint",tag,function()
            draw.SimpleTextOutlined(("Playtime: %.2fh"):format(me:GetPlaytime()/3600), "Default", 10, 10, col_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, col_black)
        end)
    end
    concommand.Add("cl_show_playtime", function(a,b,args)
        if args[1] and tonumber(args[1]) > 0 then
            hook.Add("HUDPaint",tag,function()
                draw.SimpleTextOutlined(("Playtime: %.2fh"):format(me:GetPlaytime()/3600), "Default", 10, 10, col_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, col_black)
            end)
            SQLConVar("cl_show_playtime",1)
        else
            hook.Remove("HUDPaint",tag)
            SQLConVar("cl_show_playtime",0)
        end
    end)
end)