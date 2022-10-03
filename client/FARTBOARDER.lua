STEPS = {{}} -- fartboard griefer moment
COLDAT = {}
-- interval of frame recordings = 2^16/10
FB = IsValid(FB) and FB or nil
if not FB or not FB.Palette then
	for k, v in pairs(ents.FindByClass'lua_screen') do
		if v.Palette then
			FB = v
			print(v)
		end
	end
end
ColorsToKeys = {}
for k, v in pairs(FB.Palette) do
    ColorsToKeys[v.r*256*256 + v.g*256 + v.b] = k
end
local m = Material'fartboard001.png'
local wid = m:Width()
local hyd = m:Height()
local heightMult = FB.ImageWidth
for x = 1, wid do
    for y = 1, hyd do
        local col = m:GetColor(x, y)
        COLDAT[heightMult * y + x + 10467] = ColorsToKeys[col.r*256*256 + col.g*256 + col.b]
    end
end
 -- offset : 10467
local step = 1
local ct = 1
local maxpx = FB.MaxPixels
for k, v in pairs(COLDAT) do
    if ct > maxpx then
        ct = 1 
        step = step + 1
        STEPS[step] = {}
    end
    STEPS[step][k] = v
end
if table.IsEmpty(STEPS) then return end
for k, v in pairs(STEPS) do
    timer.Simple(k*1.5, function()
        FB:CallOnServer('addPixels', STEPS[k], false, false)
        print(k, " done out of " , #STEPS)
    end)
end
if SUSSYBALLSS then -- code below for drawing a pic over artboard to "cheat" from , scale is wrong


    local tag = "fartboarding"
    local me = LocalPlayer()
    local rectPos = me.PlayerTrace.HitPos + me.PlayerTrace.HitNormal
    local rectAng = Angle(0,90,90)
    local mat = Material'okayumogu.png'
    local scale = 500
    hook.Add("Think",tag,function()
        if input.IsKeyDown(KEY_F) then
            rectPos = me.PlayerTrace.HitPos + me.PlayerTrace.HitNormal
        end
    end)
    hook.Add("PostDrawTranslucentRenderables",tag,function()
        --print(rectPos,rectAng)
        cam.Start3D2D(rectPos, rectAng, 0.1)
            surface.SetMaterial(mat)
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(-scale,-scale,scale*2,scale*2)
        cam.End3D2D()
    end)
end