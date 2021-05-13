--Minetest bank vault: maintenance controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank


local light = "b"
-------------------------------------------

if event.type == "program" then
  port[light] = true
end

if event.type == "digiline" then
  if event.channel == "security" then
    if event.msg == "reset" then
      port[light] = false
    elseif event.msg == "maintenance" then
      port[light] = true
    else
      port[light] = false
    end
  end
end
