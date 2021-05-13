--Maintenance door controller

local door = "b"
-----------------------------------------------

if event.type == "program" then
  port[door] = false
end

if event.type == "digiline" then
  if event.channel == "security" then
    if event.msg == "reset" then
      port[door] = false
    elseif event.msg == "maintenance" then
      port[door] = true
    else
      port[door] = false
    end
  end
end
