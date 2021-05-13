--Minetest bank vault: input controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank


--local constants: connecting buttons with pins
--which pins will we use
local pin1 = "B"
local pin2 = "A"
local pin3 = "D"

--Which keys will be sent
local keys = {
[pin1] = {channel = "input", msg = "1"},
[pin2] = {channel = "input", msg = "2"},
[pin3] = {channel = "input", msg = "3"}
}


if event.type == "on" then
  local ev = keys[event.pin.name]
  if ev ~= nil then
    digiline_send(ev.channel, ev.msg)
  end
end
