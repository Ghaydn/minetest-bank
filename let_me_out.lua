--Minetest bank vault: "let me out" button controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

if event.type == "on" then
  digiline_send("let me out", "let me out")
end
