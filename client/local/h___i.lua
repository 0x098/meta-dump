local T = {moveAmount = 0, moves = {}}
local p = print
function cvt2gmMovmnt(table)
  local cmdTable = {}

  local curPos = 0 -- STARTER STUFF CHECK UR TOWER FIRST --
  local left = "moveright" 
  local right = "moveleft"
  local first = 0
  local buffer = 1
  local last = 2

  local function sCP(to)
    local offset = to-curPos
    if offset > 0 then
      for _=0,offset-1 do
        cmdTable[#cmdTable+1] = right
        --cmdTable[#cmdTable+1] = "+" .. right
        --cmdTable[#cmdTable+1] = "-" .. right
      end
    elseif offset < 0 then
      offset = math.abs(offset)
      for _=0,offset-1 do
        cmdTable[#cmdTable+1] = left
        --cmdTable[#cmdTable+1] = "+" .. left
        --cmdTable[#cmdTable+1] = "-" .. left
      end
    end
    curPos = to
  end
  local function UP()
    cmdTable[#cmdTable+1] = "pickup"
    --cmdTable[#cmdTable+1] = "-forward"
  end
  local function DN()
    cmdTable[#cmdTable+1] = "drop"
    --cmdTable[#cmdTable+1] = "-back"
  end  
  local function f2b()
    sCP(first)
    UP()
    sCP(buffer)
    DN()
  end
  local function f2l()
    sCP(first)
    UP()
    sCP(last)
    DN()
  end

  local function b2f()
    sCP(buffer)
    UP()
    sCP(first)
    DN()
  end
  local function b2l()
    sCP(buffer)
    UP()
    sCP(last)
    DN()
  end
  local function l2f()
    sCP(last)
    UP()
    sCP(first)
    DN()
  end
  local function l2b()
    sCP(last)
    UP()
    sCP(buffer)
    DN()
  end
  for k,v in pairs(table) do
    if     v=="f2l" then
      f2l()
    elseif v=="f2b" then
      f2b()
    elseif v=="b2f" then
      b2f()
    elseif v=="b2l" then
      b2l()
    elseif v=="l2f" then
      l2f()
    elseif v=="l2b" then
      l2b()
    else
      p("func not found")
    end
  end
  return cmdTable
end
function move(n, src, dst, via)
  if n > 0 then
      move(n - 1, src, via, dst)
      T.moveAmount = T.moveAmount + 1
      T.moves[T.moveAmount] = tostring(src) .. "2" .. tostring(dst)
      move(n - 1, via, dst, src)
  end
end
local n = 9
move(n, "f", "l", "b")
p("Movement Table: ")
hanoiMoves = cvt2gmMovmnt(T.moves)

function hanoiMove(hanoiMoves)
  if(hanoiMoves[1] ~= nil) then
    local r = hanoiMoves[1]
    table.remove(hanoiMoves,1)
    return r
  end
end
PrintTable(hanoiMoves)