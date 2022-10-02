local function h(txt)
    RunConsoleCommand("hostname", txt)
end

local fn = "playerquotes.dat"

local function quotesFileOpenToTable()
    if file.Exists(fn, "DATA") then
        local ret = {}
        for k, quot in pairs(util.Decompress(file.Read(fn, "DATA")):Split("\n")) do
            ret[quot] = true
        end
        return ret
    end
    return false
end
local function quotesTableSaveToFile()
    local writ = ""
    for quot, v in pairs(Hostnames.Quotes) do
        if writ == "" then
            writ = quot
        else
            writ = writ .. "\n" .. quot
        end
    end
    file.Write(fn, util.Compress(writ))
    writ = nil
    print'Quotes saved'
end
Hostnames = Hostnames or {
    Quotes = quotesFileOpenToTable() or {
        ["wtf is sex?"]=true,
        ["example"]=true,
        ["WTF IS SERVR"]=true,
        ["bye worold"]=true,
        [";aaa"]=true,
        ["eror"]=true,
        ["WATH"]=true,
    },
    Timer = 15,
    Current = "",
    Prefix = "[sex] - ",
    Add = function(quote)
        Hostnames.Quotes[quote] = true,
        quotesTableSaveToFile()
    end,
}
local function selectNewHostname()
    --if Hostnames and Hostnames.Quotes and Hostnames.Current and Hostnames.Prefix and not table.IsEmpty(Hostnames.Quotes) then
        if Hostnames.Quotes[Hostnames.Current] then
            Hostnames.Current = next(Hostnames.Quotes, Hostnames.Current)
        else
            Hostnames.Current = next(Hostnames.Quotes)
        end
        h(Hostnames.Prefix .. ts(Hostnames.Current)) -- apply hostname
        game.GetWorld():SetNWString("ServerName",Hostnames.Prefix .. ts(Hostnames.Current))
    --end
end
timer.Create("hostnamer.lua", Hostnames and math.max(Hostnames.Timer, 60) or 60, 0, selectNewHostname)
hook.Add("Initialize","hostnamer.lua",function()
    selectNewHostname()
    hook.Remove("Initialize","hostnamer.lua")
end)
