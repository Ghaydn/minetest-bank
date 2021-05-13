--Minetest bank vault: reset button controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

if event.type == "on" then
  digiline_send("button", "reset")
end
