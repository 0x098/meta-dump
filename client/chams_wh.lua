local mat = Material'models/debug/debugwhite'
local pr,pg,pb = 0,0,0
hook.Add("PostDrawOpaqueRenderables","a",function()
	--render.OverrideDepthEnable(true,false)
	local mfs = player.GetAll()
	--render.SetMaterial( mat )
	cam.Start3D()
		cam.IgnoreZ(true)
		pr,pg,pb = render.GetColorModulation()
		render.SetColorModulation(1,0,0)
		--render.SuppressEngineLighting( true )
		render.MaterialOverride( mat )
		render.OverrideDepthEnable(true, false)
		for k,v in ipairs( mfs ) do
			v:DrawModel()
		end
		cam.IgnoreZ(false)
		render.MaterialOverride( )
		--render.SuppressEngineLighting( false )
		render.SetColorModulation(pr,pg,pb)
		render.OverrideDepthEnable(false, false)
		for k,v in ipairs( mfs ) do
			v:DrawModel()
		end
	cam.End3D()
end)