--Minetest bank vault: cell door controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

--this controller can open and close only one door


local my_cell = 1

if event.type == "digiline" then
  if event.channel == "open cell" then
    if event.msg == my_cell then
      port.a = true
      port.b = true
      port.c = true
      port.d = true
    end
  elseif event.channel == "security" and event.msg ~= "close the gate" then
    port.a = false
    port.b = false
    port.c = false
    port.d = false
  end
end
