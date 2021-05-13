--Minetest bank vault: road light controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank


local my_cell = 1

local light = "d"
--------------------------------------------

if event.type == "program" then
  port[light] = true
end

if event.type == "digiline" then
  if event.channel == "open cell" then
    if my_cell <= event.msg then
      port[light] = true
    end
  elseif event.channel == "let me out" or event.channel == "security" and event.msg == "reset" then
    port[light] = false
  elseif event.channel == "security" and event.msg == "maintenance" then
    port[light] = true
  end
end
