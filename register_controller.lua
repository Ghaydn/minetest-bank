--Minetest bank vault: registration controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank


local price = {"default:diamondblock", "crimeaion:coin5"}

if event.type == "program" then
  mem.var = false
end

if event.type == "digiline" then
  if event.channel == "security" and event.msg == "reset" then
    digiline_send("lcd_r", "Register here")
    mem.var = false
  elseif event.channel == "block registration" and event.msg == "block registration" then
    digiline_send("lcd_r", "Wait...")
    mem.var = true
  elseif event.channel == "lcd" then
    if event.msg == "Enter your cell number" then
      digiline_send("lcd_r", "Register here")
   -- else
   --   digiline_send("lcd_r", event.msg)
    end
  elseif event.channel == "account feedback" then
    if event.msg.action == "cannot create" then
      port.green = true
      interrupt(0.1, "port")
    elseif event.msg.action == "account created" then
      digiline_send("lcd_r", "Account created. Cell #" .. event.msg.account .. ", password: " .. event.msg.password)
    end
  end
end

if event.type == "item" then
  if mem.var then
    digiline_send("lcd_r", "Cannot register now. Press Reset")
    return "green"
  end
  
  for i, v in pairs(price) do
    if event.item.name == v then
      digiline_send("account", "create")
      return "red"
    end
  end
  digiline_send("lcd_r", "WRONG ITEM")
  interrupt(2, "lcd")
  return "green"
end

if event.type == "interrupt" then
  if event.iid == "port" then
    port.green = false
  end
  if event.iid == "lcd" then
    digiline_send("lcd_r", "Register here")
  end
end
