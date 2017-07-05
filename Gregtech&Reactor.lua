component = require("component")
rs = component.redstone
gpu = component.gpu
sides = require("sides")
event = require("event")
b = component.gt_batterybuffer
i = 1
totalbatteries = 0
nilcheck = b.getBatteryCharge(0)
gpu.setResolution(40, 12)
local w, h = gpu.getResolution()
local energy = 0
local menergy = 0
local percent = 0
local run = false
local energyUsage = 0
local plus = false

function touchHandler(_, _, x, y)
  if x >= w/2 - 7 then
    if x <= w/2 + 7 then
      if y >= 9 then
        if y <= 11 then
          if run then
            run = false
          else
            run = true
          end
          updateScreen()
        end
      end
    end
  end
end

event.listen("touch", touchHandler)

local function updateScreen()
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, w, h, " ")
  gpu.setForeground(0xFFFF00)
  gpu.set(w/2 - 15, 1, "==Reactor&Battery Controller==")
  str = energy .. "EU / " .. menergy .. "EU"
  gpu.setForeground(0x00FF00)
  gpu.set(w/2 - string.len(str) / 2, 3, str)
  if plus then
    str = "+ " .. energyUsage
    gpu.setForeground(0x0000FF)
  else
    str = "- " .. energyUsage
    gpu.setForeground(0xFF00FF)
  end
  gpu.set(w/2 - string.len(str) / 2, 4, str)
  gpu.setForeground(0xFF0000)
  gpu.set(w/2 - 15, 5, "¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦")
  numQuad = math.floor(((percent / 100) * 30) + 0.5)
  gpu.fill(w/2 - 15, 5, numQuad, 1, "¦")
  gpu.setForeground(0x00FF00)
  gpu.set(w/2 - 2, 6, percent .. "%")
  gpu.set(w/2 - 7, 8, "Reactor Status")
  
  if run then
    gpu.setForeground(0x00FF00)
    gpu.fill(w/2 - 7, 9, 14, 3, "¦")
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x00FF00)
    gpu.set(w/2 - 2, 10, "ON")
  else
    gpu.setForeground(0xFF0000)
    gpu.fill(w/2 - 7, 9, 14, 3, "¦")
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0xFF0000)
    gpu.set(w/2 - 2, 10, "OFF")
  end
  gpu.setForeground(0x000000)
end

while nilcheck ~= b.getBatteryCharge(i) do
  totalbatteries = totalbatteries + 1
  i = i + 1
end

savedenergy = 0

while true do
  i = 1
  energy = 0
  menergy = 0
  while i <= totalbatteries do
    energy = energy + b.getBatteryCharge(i)
    menergy = menergy + b.getMaxBatteryCharge(i)
    i = i + 1
  end
  energy = energy + b.getEUStored()

  if savedenergy == 0 then
    savedenergy = energy
  end

  menergy = menergy + b.getEUMaxStored()
  
  percent = math.floor(((energy / menergy) * 100) + 0.5)
  
  if savedenergy > energy then
    energyUsage = savedenergy - energy
    energyUsage = energyUsage / 20
    plus = false
  elseif savedenergy < energy then
    energyUsage = energy - savedenergy
    energyUsage = energyUsage / 20
    plus = true
  elseif savedenergy == energy then
    energyUsage = 0
    plus = true
  end
  if percent < 10 then
    run = true
  end
  if percent > 80 then
    run = false
  end
  savedenergy = energy
  if run then
    rs.setOutput(sides.right, 15)
  else
    rs.setOutput(sides.right, 0)
  end
  updateScreen()
  os.sleep(1)
end