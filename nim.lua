#!/usr/bin/lua

function tobin(x)
  local outlist, i = {}, 0
  while 2^i <= x do
    table.insert(outlist, false)
    i = i + 1
  end
  while i >= 0 do
    if (x - 2^i) >= 0 then
      x = x - 2^i
      outlist[i + 1] = true
    end
    i = i - 1
  end
  return outlist
end

function todec(x)
  local y = 0
  for i=1,#x do
    if x[i] then
      y = y + 2^(i-1)
    end
  end
  return y
end

function xorop(x, y)
  local z
  if x == true then
    if y == true then z = false
    else z = true end
  else
    if y == true then z = true
    else z = false end
  end
  return z
end

function listxor(x, y)
  if #x >= #y then
    for i=0,#y do
      x[i] = xorop(x[i], y[i])
    end
  else
    for i=0,#x do
      y[i] = xorop(x[i], y[i])
    end
    x = y
  end
  return x
end

function nimsum(piles) 
  local sumlist = {}
  for i=1,#piles do
    sumlist = listxor(sumlist, tobin(piles[i]))
  end
  return todec(sumlist)
end

function nimAI(piles)
  local sum, move, amt = nimsum(piles)
  if sum == 0 then
    move = math.random(#piles)
    amt = math.random(piles[move])
  else
    for i=1,#piles do
      if todec(listxor(tobin(sum), tobin(piles[i]))) < piles[i] then
        move, amt = i, piles[i] - todec(listxor(tobin(sum), tobin(piles[i])))
      end
      --for j=1,piles[i] do
      --  local pilesdup = piles
      --  pilesdup[i] = pilesdup[i] - j
      --  print(i, j, nimsum(pilesdup))
      --  if nimsum(pilesdup) == 0 then
      --    amt, move = j, i
      --  end
      --end
    end
  end
  return amt, move
end

function ordinal(x)
  local outstr = x
  if (x > 19) or (x < 10) then
    if x % 10 == 1 then outstr = outstr .. 'st'
    else if x % 10 == 2 then outstr = outstr .. 'nd'
    else if x % 10 == 3 then outstr = outstr .. 'rd'
    else outstr = outstr .. 'th' end end end
  else
    outstr = outstr .. 'th'
  end
  return outstr
end

function drawpiles(piles)
  local x = 0
  for i=1,#piles do
    if piles[i] > x then x = piles[i] end
  end
  local y = x
  print('')
  for i=x,1,-1 do
    for j=1,#piles do
      if piles[j] >= y then io.write(' (O) ')
      else io.write('     ') end
    end
    io.write('\n')
    y = y - 1
  end
  print('')
end

function newpiles()
  local outlist = {}
  math.randomseed(os.time())
  for i=1,math.random(5)+1 do
    outlist[i] = math.random(7)
  end
  return outlist
end

function domove(piles, amt, move)
  piles[move] = piles[move] - amt
  if piles[move] == 0 then
    table.remove(piles, move)
  end
  return piles
end

print("\nNIM.LUA -- The Game of Nim")
print("==========================\n")
print("Welcome to the game of Nim. The goal")
print("of the game is to be the player to take")
print("the last beads from the piles. You can")
print("only take beads from one pile at a time.")
print("I will try my hardest to beat you, but")
print("that doesn't mean I can't be beaten!\n")
io.write('Do you want to go first? (y/n) ')
local a = io.read()
print("\n==========================\n")

local piles = newpiles()
drawpiles(piles)
local amt, move

if a == 'n' then
  amt, move = nimAI(piles)
  print("I'll take " .. amt .. " beads from the " .. ordinal(move) .. " pile.\n")
  piles = domove(piles, amt, move)
  print("========================\n")
  drawpiles(piles)
end

local won = false
if #piles == 0 then won = true end
local turn = 1

while not won do
  if turn == 1 then
    amt, move = 0, 0
    while (move > #piles) or (move < 1) do
      io.write("Which pile do you want to take beads from? ")
      move = tonumber(io.read())
      if (move > #piles) or (move < 1) then
        print("\nSorry, what?")
      end
    end
    print('')
    while (amt > piles[move]) or (amt < 1) do
      io.write("How many beads do you want to take? ")
      amt = tonumber(io.read())
      if (amt > piles[move]) or (amt < 1) then
        print("\nSorry, what?")
      end
    end
    piles = domove(piles, amt, move)
    if #piles == 0 then won = true
    else turn = 0 end
  else if turn == 0 then
    amt, move = nimAI(piles)
    print("\n========================")
    print("\nI'll take " .. amt .. " beads from the " .. ordinal(move) .. " pile.")
    piles = domove(piles, amt, move)
    print("\n========================")
    if #piles == 0 then won = true
    else turn = 1
    drawpiles(piles) end
  end end
end

if turn == 1 then
  print("\n========================\n")
  print("         YOU WON!!!")
  print("\n========================\n")
else
  print("\n          I won.")
  print("\n========================\n")
end
