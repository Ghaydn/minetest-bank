--Minetest bank vault: sifnaling detectors controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

if event.type == "on" then
  digiline_send("detector", "someone in")
elseif event.type == "off" then
  digiline_send("detector", "everyone left")
end
