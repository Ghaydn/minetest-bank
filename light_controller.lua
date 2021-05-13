--Minetest bank vault: light and blink controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

local light = "b"
local blink = "d"
------------------------------------------------

if event.type == "program" then
  mem.var = false
  port[light] = true
  port[blink] = false
end

if event.type == "digiline" then
  if event.channel == "security" then
    if event.msg == "reset" then
      mem.var = false
      port[light] = true
      port[blink] = false
    elseif event.msg == "intruder" then
      mem.var = true
      port[light] = false
      port[blink] = true
      interrupt(1)
    end
  end
end

if event.type == "interrupt" then
  if mem.var then
    port[blink] = not port[blink]
    interrupt(1)
  end
end
