--Minetest bank vault: input controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

--local constants: connecting buttons with pins
--which pins will we use
local pin1 = "A"
local pin2 = "B"
local pin3 = "C"
local pin4 = "D"

--Which keys will be sent
local keys = {
[pin1] = {channel = "account", msg = "delete"},
[pin2] = {channel = "account", msg = "update password"},
[pin3] = {channel = "let me out", msg = "let me out"},
[pin4] = {channel = "button", msg = "reset"}
}


if event.type == "on" then
  local ev = keys[event.pin.name]
  if ev ~= nil then
    digiline_send(ev.channel, ev.msg)
  end
end
