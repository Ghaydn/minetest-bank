--Minetest bank vault: core controller
--
--This is the heart of all the bank
--It must be hidden from everyone
--
--License: GNU AGPL
--Copyright Ghaydn (ghaydn@ya.ru), 2021
--
--Download full code: github.com/Ghaydn/minetest-bank

local password_size = 8       --8 is ok
local total_cells = 20        --You definitely do not want to build more cells.
local admin_pass = "53026872" --used to log in the #00. You should change it in maintenance mode after start.
local backup_rate = 0.1       --do not change this unless your server configuration don't allow to send digiline messages so fast.

--initial position
if event.type == "program" then
  mem.var = {
    accounts = {[0] = admin_pass},
    state = "maintenance",
    state2 = "normal",
    current = 0,
    password = "",
    backup_frame = 0
  }
  digiline_send("lcd", "turning on")
end


--some important functions
local reset = function()
  if mem.var.state == "intruder" or mem.var.state2 == "intruder" then
    mem.var.state = "input_password"
    mem.var.current = 0
    mem.var.password = "nil"
    digiline_send("block registration", "block registration")
    digiline_send("lcd", "Enter maintenance password")
  else
    mem.var.current = 0
    mem.var.state = "ready"
    mem.var.state2 = "normal"
    mem.var.password = ""
    digiline_send("lcd", "Enter your cell number")
    digiline_send("security", "reset")
  end
end

local intruder = function()
  mem.var.state = "intruder"
  mem.var.state2 = "intruder"
  mem.var.current = 0
  mem.var.password = ""
  digiline_send("block registration", "block registration")
  digiline_send("security", "intruder")
  digiline_send("lcd", "Unauthorized entry")
end

local get_backup = function(msg)
  mem.var.accounts[msg.account] = msg.password
end

local generate_password = function()
  local password = ""
  for i = 1, password_size do
    password = password .. tostring(math.random(10) - 1)
  end
  return password
end

local cellno = function(c)
  if type(c) == "string" then
    return c
  elseif type(c) == "number" then
    if c < 10 then return "0" .. c
    else return c end
  else
    return nil
  end
end

local create_account = function()      
  local account = 1
  while mem.var.accounts[account] ~= nil do
    account = account + 1
  end
  if account > total_cells then
    digiline_send("lcd", "Cannot create account: all cells are in use")
    digiline_send("account feedback", {action = "cannot create"})
  else 
    local password = generate_password()
    if event.msg.password ~= nil then password = event.msg.password end
    mem.var.accounts[account] = password
    digiline_send("lcd", "Account created. Cell #" .. cellno(account) .. ", password: " .. password)
    digiline_send("account feedback", {action = "account created", account = cellno(account), password = password})
  end
end


------------------------
if event.type == "interrupt" then
  if event.iid == "maintenance" then
    if mem.var.state == "maintenance" then
      mem.var.state2 = "normal"
      digiline_send("block registration", "block registration")
      digiline_send("lcd", "MAINTENANCE")
      digiline_send("security", "maintenance")
      digiline_send("open cell", total_cells + 1)
    end
  elseif event.iid == "incorrect" then
    if mem.var.state2 == "intruder" then
      intruder()
    else
      digiline_send("lcd", "Enter your cell number")
    end
  end
end

--------------------------------------------------------------------------------
--main input function
if event.type == "digiline" then
  if mem.var.state == "turning on" then
    if event.channel == "backup" then
      get_backup(event.msg)
    end
  elseif mem.var.state == "ready" then
    if event.channel == "input" then
      mem.var.current = event.msg
      mem.var.state = "input_cell"
      digiline_send("block registration", "block registration")
      if mem.var.state2 == "normal" then
        digiline_send("lcd", "Cell #" .. mem.var.current)
      elseif mem.var.state2 == "delete" then
        digiline_send("lcd", "DELETE ACCOUNT: enter cell#" .. mem.var.current)
      elseif mem.var.state2 == "update" then
        digiline_send("lcd", "UPDATE PASSWORD: enter cell#" .. mem.var.current)
      end
--account
    elseif event.channel == "account" then
      if event.msg == "create" then
    --CREATE ACCOUNT  
        create_account()

      elseif event.msg == "delete" then
    --DELETE ACCOUNT
        digiline_send("block registration", "block registration")
        mem.var.state = "ready"
        mem.var.state2 = "delete"
        digiline_send("lcd", "DELETE ACCOUNT: enter cell#")
        
      elseif event.msg == "update password" then
    --UPDATE PASSWORD
        digiline_send("block registration", "block registration")
        mem.var.state = "ready"
        mem.var.state2 = "update"
        digiline_send("lcd", "UPDATE PASSWORD: enter cell#")

      end
    elseif event.channel == "button" and event.msg == "reset" then
      reset()
    elseif event.channel == "detector" and event.msg == "someone in" then
       intruder()
    end

--input cell number
  elseif mem.var.state == "input_cell" then
    if event.channel == "input" then
      local account = tonumber(mem.var.current .. event.msg)
      mem.var.current = account
      if account ~= 0 and mem.var.accounts[account] == nil then
        if mem.var.state2 == "maintenance update" or mem.var.state2 == "maintenance delete" then
          reset()
          mem.var.state = "maintenance"
          interrupt(3, "maintenance")
          digiline_send("lcd", "No such account")
        else
          reset()
          interrupt(3, "incorrect")
          digiline_send("lcd", "No such account")
        end
      else
        mem.var.state = "input_password"
        mem.var.password = "nil"
        if mem.var.state2 == "normal" then
          digiline_send("lcd", "Cell #" .. cellno(account) .. ", password: ")
        elseif mem.var.state2 == "delete" then
          digiline_send("lcd", "DELETE ACCOUNT. Cell #" .. cellno(account) .. ", password: ")
        elseif mem.var.state2 == "update" then
          digiline_send("lcd", "UPDATE PASSWORD. Cell #" .. cellno(account) .. ", old password: ")
        elseif mem.var.state2 == "maintenance delete" then
          if account == 0 then
            reset()
            digiline_send("lcd", "Cannot delete maintenance account")
          else
            mem.var.accounts[account] = nil
            reset()
            digiline_send("lcd", "Account deleted: ".. cellno(account))
          end
          mem.var.state = "maintenance"
          interrupt(3, "maintenance")
        elseif mem.var.state2 == "maintenance update" then
          local password = generate_password()
          mem.var.accounts[account] = password
          mem.var.state = "maintenance"
          digiline_send("lcd", "MAINTENANCE. Cell# ".. cellno(account) .. " new password: " .. password)
        end
      end
    elseif event.channel == "button" and event.msg == "reset" then
      reset()
    elseif event.channel == "detector" and event.msg == "someone in" then
       intruder()
    end

--input password
  elseif mem.var.state == "input_password" then
    if event.channel == "input" then
      --digiline_send("block registration", "block registration")
      if mem.var.password == "nil" then mem.var.password = event.msg
      else mem.var.password = mem.var.password .. event.msg end
      local account = mem.var.current
      local passw_size = mem.var.password:len()
      local passw = string.sub("**********", 1, passw_size)

      if passw_size < password_size then
        if mem.var.state2 == "normal" then
          digiline_send("lcd", "Cell #" .. cellno(account) .. ", password: " .. passw)
        elseif mem.var.state2 == "delete" then
          digiline_send("lcd", "DELETE ACCOUNT. Cell #" .. cellno(account) .. ", password: " .. passw)
        elseif mem.var.state2 == "update" then
          digiline_send("lcd", "UPDATE PASSWORD. Cell #" .. cellno(account) .. ", old password: " .. passw)
        elseif mem.var.state2 == "intruder" then
          digiline_send("lcd", "Enter maintenance password: " .. passw)
        end
    --check password
      elseif passw_size == password_size then
        if mem.var.accounts[account] == mem.var.password then
          if account == 0 then
            if mem.var.state2 == "intruder" then
              mem.var.state2 = "normal"
              reset()
              digiline_send("lcd", "Vault unlocked")
              interrupt(3, "unlocked")
            else
              mem.var.state = "maintenance"
              mem.var.state2 = "normal"
              digiline_send("lcd", "MAINTENANCE")
              digiline_send("security", "maintenance")
              --digiline_send("block registration", "block registration")
            end
          else
            if mem.var.state2 == "normal" then
              mem.var.state = "password correct"
              digiline_send("security", "open the gate")
              digiline_send("lcd", "Cell #" .. cellno(account) .. ", ACCESS GRANTED, come in")
            elseif mem.var.state2 == "delete" then
              if account == 0 then
                reset()
                digiline_send("lcd", "Cannot delete maintenance account")
              else
                mem.var.accounts[account] = nil
                reset()
                digiline_send("lcd", "Account #" .. cellno(account) .. " SUCCESSFULLY DELETED")
              end
              interrupt(3, "incorrect")
            elseif mem.var.state2 == "update" then
              local passwrd = generate_password()
              mem.var.accounts[account] = passwrd
              reset()
              digiline_send("lcd", "Cell #" .. cellno(account) .. ", NEW PASSWORD: " .. passwrd)
            end
          end
        else
          mem.var.state = "ready"
          --mem.var.state2 = "normal"
          mem.var.current = 0
          mem.var.password = ""
          digiline_send("lcd", "ACCESS DENIED")
          digiline_send("security", "reset")
          interrupt(0.5, "incorrect")
        end
      end
    elseif event.channel == "button" and event.msg == "reset" then
      reset()
    elseif event.channel == "detector" and event.msg == "someone in" then
      intruder()
    end

--coming in
  elseif mem.var.state == "password correct" then
    if event.channel == "detector" and event.msg == "someone in" then
      mem.var.state = "someone in"
      digiline_send("security", "close the gate")
      digiline_send("lcd", "Wait, someone is inside the vault")
      digiline_send("open cell", mem.var.current)
      --digiline_send("block registration", "block registration")
    elseif event.channel == "button" and event.msg == "reset" then
      reset()
    end

--someone in
  elseif mem.var.state == "someone in" then
    if event.channel == "detector" and event.msg == "everyone left" then
      reset()
    elseif event.channel == "let me out" then
      digiline_send("security", "open the gate")
      --digiline_send("block registration", "block registration")
    end

--mainteinance
  elseif mem.var.state == "maintenance" then
    if event.channel == "account" then
      if event.msg == "delete" then
        mem.var.state = "ready"
        mem.var.state2 = "maintenance delete"
        digiline_send("lcd", "MAINTENANCE DELETE ACCOUNT: enter cell#")
        digiline_send("block registration", "block registration")
      elseif event.msg == "update password" then
        mem.var.state = "ready"
        mem.var.state2 = "maintenance update"
        digiline_send("lcd", "MAINTENANCE RESET PASSWORD: enter cell#")
        digiline_send("block registration", "block registration")
      elseif event.msg == "create" then
        create_account()
      end
    elseif event.channel == "button" and event.msg == "reset" then
      reset()
    end

--intruder
  elseif mem.var.state == "intruder" then
    if event.channel == "button" and event.msg == "reset" then
      reset()
    end
  end

end


-----------------BACKUPS-----------------------------------------

--backup
if event.type == "digiline" and event.channel == "queue backup" then
  digiline_send("start backup", "start backup")
  mem.var.backup_frame = 0
  digiline_send("backup", {account = mem.var.backup_frame, password = passwrd})
  interrupt(0.1, "backup")
end

if event.type == "interrupt" and event.iid == "backup" then
  mem.var.backup_frame = mem.var.backup_frame + 1
  if mem.var.backup_frame <= total_cells then
    local passwrd = mem.var.accounts[mem.var.backup_frame]
    if passwrd ~= nil then
      digiline_send("backup", {account = mem.var.backup_frame, password = passwrd})
    end
    interrupt(0.1, "backup")
  else
    digiline_send("end backup", "end backup")
        digiline_send("lcd", "Backup finished")
  end
end

--restore
if event.type == "digiline" then
  if event.channel == "start restore" then
    mem.var.accounts = {}--[0] = admin_pass}
  elseif event.channel == "restore" then
    mem.var.accounts[event.msg.account] = event.msg.password
  elseif event.channel == "end restore" then
    digiline_send("lcd", "Accounts restored from backups")
  end
end
