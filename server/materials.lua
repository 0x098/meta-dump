
local subpath = ""
local function parseMaterials(files, folders, paf)
	paf = paf or ""
    subpath = paf:sub(11,#paf)
	if not table.IsEmpty(files) then
		for _, fil in pairs(files) do
            if fil:find('.vtf', 0, true) then
    			--print("   file: " .. subpath .. "/" .. fil:StripExtension())
                list.Add( "OverrideMaterials", subpath .. "/" .. fil:StripExtension() )
            end
			
            --list.Add( "OverrideMaterials", "models/wireframe" )
		end
	end
	if type(folders) == "table" and not table.IsEmpty(folders) then
		for _, fol_ in pairs(folders) do
			--print("fold: " .. paf .. "/" .. fol_ .. "/*")
			--local fil, fol__ = 
            local x, y = file.Find(paf .. fol_ .. "/*","GAME")
			parseMaterials(x, y, paf .. fol_)
		end
	end
end

local fil, fol = file.Find("materials/*","GAME")
parseMaterials(fil, fol, "materials/")