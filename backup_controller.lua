--Minetest bank vault: backup controller
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

local restore_pin = "C"
local backup_pin = "A"
local shift_pin = "B"
local MAX_BACKUPS = 5

if event.type == "program" then
  mem.var = {
    backups = {
      {
        --{account = 1, password = 2}, --example
        --{account = 3, password = 4}, --example
      }
    },
    cycles = 0
  }
end

--BACKUP
if event.type == "on" and event.pin.name == backup_pin then
  digiline_send("queue backup", "queue backup")
  digiline_send("lcd_b", "queue backup")
end

if event.type == "digiline" then
  if event.channel == "start backup" then
    for i = MAX_BACKUPS, 1, -1 do
      mem.var.backups[i] = mem.var.backups[i-1]
    end
    mem.var.backups[1] = {}
    digiline_send("lcd_b", "Backup started")
  elseif event.channel == "backup" then
    table.insert(mem.var.backups[1], {account = event.msg.account, password = event.msg.password})
      digiline_send("lcd_b", "Backup in process: " .. event.msg.account)
  elseif event.channel == "end backup" then
    digiline_send("lcd_b", "Backup finished")
  end
end

--RESTORE
if event.type == "digiline" and event.channel == "call restore" 
or event.type == "on" and event.pin.name == restore_pin then
  --start restore
  digiline_send("start restore", "start restore")
  interrupt(0.1, "restore")
  mem.var.cycles = 0
  digiline_send("lcd_b", "Starting restore")
end

if event.type == "interrupt" then
  if event.iid == "restore" then
    mem.var.cycles = mem.var.cycles + 1
    if mem.var.cycles <= #mem.var.backups[1] then
      digiline_send("restore", {account = mem.var.backups[1][mem.var.cycles].account,
                               password = mem.var.backups[1][mem.var.cycles].password})
      digiline_send("lcd_b", "Restore in process: " .. mem.var.backups[1][mem.var.cycles].account .. " - " .. mem.var.backups[1][mem.var.cycles].password)
      interrupt(0.1, "restore")
    else
      digiline_send("end restore", "end restore")
      digiline_send("lcd_b", "Restore finished")
    end
  end
end

--SHIFT
if event.type == "digiline" and event.channel == "shift backups"
or event.type == "on" and event.pin.name == shift_pin then
  mem.var.backups[MAX_BACKUPS + 1] = mem.var.backups[1]
  for i = 1, MAX_BACKUPS do
    mem.var.backups[i] = mem.var.backups[i+1]
  end
end
