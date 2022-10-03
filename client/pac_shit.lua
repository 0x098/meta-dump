local tbl = { -- Earu: WHY DO YOU EXPLODE?
-- kek i dont use this version
    AddOwnerSpeed    = false,
    AimDir           = false,
    AimPartName      = "",
    AimPartUID       = "",
    AngleOffset      = Angle (         0,          0,          0),
    Angles           = Angle (         0,          0,          0),
    Attract          =          0,
    AttractMode      = "projectile_nearest",
    AttractRadius    =        200,
    Bone             = "",
    Bounce           =          0,
    BulletImpact     = true,
    CollideWithOwner = false,
    CollideWithSelf  = false,
    Collisions       = true,
    Damage           =          20000000,
    DamageRadius     = 5000,
    DamageType       = "explosion",
    Damping          =          0,
    Delay            =          0,
    DrawOrder        =          0,
    EditorExpand     = false,
    EyeAngles        = false,
    Gravity          = false,
    Hide             = false,
    IsDisturbing     = false,
    LifeTime         =          5,
    Mass             = 50000,
    Maximum          =          0,
    Name             = "",
    OutfitPartUID    = "",
    ParentUID        = "",
    Physical         = true,
    Position         = Vector (         0,          0,          0),
    PositionOffset   = Vector (         0,          0,          0),
    Radius           =         50,
    RemoveOnCollide  = false,
    Speed            =       1000,
    Sphere           = true,
    Spread           =          0,
    Sticky           = false,
    TargetEntityUID  = "",
    UniqueID         = ""
}
local function project(startpos, angle)
    debugoverlay.Line(startpos, startpos+angle:Forward()*30, tbl.LifeTime, color_white, true)
    debugoverlay.Line(startpos+angle:Right()*20, startpos+angle:Forward()*30, tbl.LifeTime, color_white, true)
    debugoverlay.Line(startpos-angle:Right()*20, startpos+angle:Forward()*30, tbl.LifeTime, color_white, true)
    net.Start"pac_projectile"
        net.WriteVector(startpos)
        net.WriteAngle(angle)
        net.WriteTable(tbl)
    net.SendToServer()
end
local fastEnts = {}
local fastEntsPos = {}
local fastEntsVel = {}
local me = LocalPlayer()
local mePos = me:GetPos()
local v001 = Vector(0,0,1)
local v111 = Vector(1,1,1)
local col_black = Color(0,0,0)
hook.Add("Think", "s", function()
    mePos = me:GetPos()
    table.Empty(fastEntsPos)
    table.Empty(fastEntsVel)
    fastEnts = ents.FindInBox(mePos - v111*256, mePos + v111*256)
    for k, v in pairs(fastEnts) do
        if type(v) == "Player" then continue end
        local objVel = v:GetVelocity():DistToSqr(vector_origin)
        if objVel > 1000^2 then
            fastEntsPos[#fastEntsPos+1] = v:GetPos():ToScreen()
            fastEntsVel[#fastEntsVel+1] = tostring(v:GetVelocity():DistToSqr(vector_origin))
            if v:GetVelocity():GetNormalized():Dot( (v:GetPos()-mePos):GetNormalized() ) < -0.95 then
                project( v:GetPos()+v:GetVelocity()*(engine.TickInterval()*me:Ping()*2), angle_zero )
            end
        end
    end
end)
hook.Add("HUDPaint", "s",function()
    if fastEntsPos and !table.IsEmpty(fastEntsPos) then
        for k, v in pairs(fastEntsPos) do
            draw.SimpleTextOutlined(fastEntsVel[k], "DermaDefault", v.x, v.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, col_black)
        end
    end
end)
local coltb = {
    ["r"] = 255,
    ["b"] = 255,
    ["a"] = 255,
    ["g"] = 255,
}
local predat = {
    {
        ["mat"] = "",
        ["pos"] = Vector(),
        ["clr"] = coltb,
        ["id"] = "",
        ["ang"] = Angle(),
        ["skn"] = 0,
        ["mdl"] = "models/props_phx/torpedo.mdl",
    },
}
local epos = me:GetPos()+me:GetRight()*128
project(epos, Angle(-90,0,0))
net.Start"pac_to_contraption"
    predat[1].pos = epos
    net.WriteTable(predat)
net.SendToServer()