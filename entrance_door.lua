--Minetest bank vault: entrance controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

local door = "b"

if event.type == "program" then
  port[door] = true
end

if event.type == "digiline" then
  if event.channel == "security" then
    if event.msg == "reset" then
      port[door] = true
    elseif event.msg == "maintenance" then
      port[door] = false
    else
      port[door] = true
    end
  end
end
