--Minetest bank vault: vault door controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

local door = "b"
------------------------------------------

if event.type == "program" then
  port[door] = false
end

if event.type == "digiline" then
  if event.channel == "security" then
    if event.msg == "reset" then
      port[door] = false
    elseif event.msg == "open the gate" or event.msg == "maintenance" then
      port[door] = true
    else
      port[door] = false
    end
  end
end
