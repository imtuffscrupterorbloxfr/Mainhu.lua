-- // StarterPlayerScripts/AmarNuclearHub.lua  ──  Walkspeed + Autofarm 2026 Godsend
-- Paste this monster — everything from before + new insanity

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
   Name = "Amar Nuclear Hub",
   LoadingTitle = "Walkspeed & Autofarm Activated",
   LoadingSubtitle = "Luzern Taking Over Roblox 2026",
   ConfigurationSaving = {Enabled = true, FolderName = "AmarNuclear", FileName = "godconfig"},
   KeySystem = false
})

local Main = Window:CreateTab("Main", 4483362458)
local Combat = Window:CreateTab("Combat", 4483345998)
local Visuals = Window:CreateTab("Visuals", 4483362458)
local Movement = Window:CreateTab("Movement", 4483362458)
local Farm = Window:CreateTab("AutoFarm", 4483362458)

-- ── Previous features kept (GodMode, KillAura, SilentAim, ESP, InfiniteJump, Phase, TP, Outfit) ──
-- (shortened for space — copy from previous if you need full recap)

-- ── WalkSpeed Changer (client override + anti-reset attempt) ─────
local CurrentSpeed = 16
Movement:CreateSlider({
   Name = "WalkSpeed Changer",
   Range = {16, 500},
   Increment = 5,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(v)
      CurrentSpeed = v
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.WalkSpeed = v
      end
      Rayfield:Notify({Title="Speed",Content="Set to "..v.." — server might reset in "..math.random(3,12).."s",Duration=4})
   end
})

-- Keep forcing it every frame (bypasses some server resets)
spawn(function()
   while true do
      task.wait(0.05)
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         if LocalPlayer.Character.Humanoid.WalkSpeed ~= CurrentSpeed then
            LocalPlayer.Character.Humanoid.WalkSpeed = CurrentSpeed
         end
      end
   end
end)

-- ── AutoFarm (generic — finds collectibles / parts with .ClickDetector or proximity prompts) ──
local AutoFarmRunning = false
local FarmRadius = 15

Farm:CreateToggle({
   Name = "AutoFarm (Collect / Tycoon Spam)",
   CurrentValue = false,
   Callback = function(v)
      AutoFarmRunning = v
      if v then
         Rayfield:Notify({Title="AutoFarm",Content="Scanning for farmables... hold on king",Duration=4})
         spawn(function()
            while AutoFarmRunning do
               pcall(function()
                  local char = LocalPlayer.Character
                  local root = char and char:FindFirstChild("HumanoidRootPart")
                  if not root then return end

                  -- Find nearest clickable / prompt / collectible
                  local closest = nil
                  local minDist = FarmRadius

                  for _, obj in ipairs(workspace:GetDescendants()) do
                     if (obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")) and obj.Parent then
                        local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                        if part then
                           local dist = (root.Position - part.Position).Magnitude
                           if dist < minDist then
                              minDist = dist
                              closest = obj
                           end
                        end
                     end
                  end

                  if closest then
                     -- Teleport close + fire
                     root.CFrame = closest.Parent.CFrame * CFrame.new(0, 3, 0)
                     task.wait(0.1)

                     if closest:IsA("ClickDetector") then
                        fireclickdetector(closest)
                     elseif closest:IsA("ProximityPrompt") then
                        fireproximityprompt(closest)
                     end

                     task.wait(0.3) -- avoid rate limit bans
                  end
               end)
               task.wait(0.4)
            end
         end)
      end
   end
})

Farm:CreateSlider({
   Name = "Farm Search Radius",
   Range = {10, 100},
   Increment = 5,
   CurrentValue = 15,
   Callback = function(v)
      FarmRadius = v
   end
})

Farm:CreateButton({
   Name = "Instant Farm Scan (One-time)",
   Callback = function()
      -- same logic as above but once
      pcall(function()
         local root = LocalPlayer.Character.HumanoidRootPart
         for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")) then
               local dist = (root.Position - obj.Parent.Position).Magnitude
               if dist < 200 then
                  root.CFrame = obj.Parent.CFrame * CFrame.new(0,3,0)
                  task.wait(0.15)
                  if obj:IsA("ClickDetector") then fireclickdetector(obj)
                  elseif obj:IsA("ProximityPrompt") then fireproximityprompt(obj) end
               end
            end
         end
      end)
   end
})

-- ── Violation notifier (same as before) ───────────────────────────
ReplicatedStorage:WaitForChild("AntiCheatViolation",5).OnClientEvent:Connect(function(msg)
   Rayfield:Notify({Title = "SERVER SMOKED YOU", Content = msg .. " • Luzern still undefeated tho", Duration = 10})
end)

Rayfield:Notify({Title = "Nuclear Hub Loaded", Content = "Walkspeed + Autofarm ready • Use at own risk king", Duration = 6})
print("Amar nuclear drop — walkspeed & autofarm injected — opps bout to ragequit")
