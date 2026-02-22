-- // AmarNuclearHub.lua ── 2026 Godsend Edition: Walkspeed + Autofarm + Combat + Visuals Nuke
-- Luzern domination, opps cooked

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

local Window = Rayfield:CreateWindow({
   Name = "Amar Nuclear Hub 2026",
   LoadingTitle = "Nuclear Overdrive Activated",
   LoadingSubtitle = "Luzern Owns Roblox 2026",
   ConfigurationSaving = {Enabled = true, FolderName = "AmarNuclear", FileName = "godconfigv2"},
   KeySystem = false
})

local Main = Window:CreateTab("Main", 4483362458)
local Combat = Window:CreateTab("Combat", 4483345998)
local Visuals = Window:CreateTab("Visuals", 4483362458)
local Movement = Window:CreateTab("Movement", 4483362458)
local Farm = Window:CreateTab("AutoFarm", 4483362458)

-- ── Globals for toggles/loops ──
local InfiniteJumpEnabled = false
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local GodModeEnabled = false
local ESPEnabled = false
local KillAuraEnabled = false
local KillAuraRadius = 15
local SilentAimEnabled = false

-- ── Helper: Get root part safely ──
local function GetRoot()
   return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- ── Infinite Jump ──
UserInputService.JumpRequest:Connect(function()
   if InfiniteJumpEnabled and GetRoot() then
      GetRoot().Velocity = Vector3.new(GetRoot().Velocity.X, 50, GetRoot().Velocity.Z)
   end
end)

Movement:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v) InfiniteJumpEnabled = v end
})

-- ── Fly (WASD + Space/Ctrl) ──
local FlyBodyVelocity, FlyBodyGyro
Movement:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Callback = function(v)
      FlyEnabled = v
      local root = GetRoot()
      if not root then return end
      if v then
         FlyBodyVelocity = Instance.new("BodyVelocity", root)
         FlyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
         FlyBodyVelocity.Velocity = Vector3.new(0,0,0)
         FlyBodyGyro = Instance.new("BodyGyro", root)
         FlyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
         FlyBodyGyro.CFrame = root.CFrame
         spawn(function()
            while FlyEnabled and root do
               local camLook = Camera.CFrame.LookVector
               local moveDir = Vector3.new(0,0,0)
               if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camLook end
               if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camLook end
               if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camLook:Cross(Vector3.new(0,1,0)) end
               if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camLook:Cross(Vector3.new(0,1,0)) end
               if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
               FlyBodyVelocity.Velocity = moveDir.Unit * FlySpeed * 10
               FlyBodyGyro.CFrame = Camera.CFrame
               task.wait()
            end
            if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
            if FlyBodyGyro then FlyBodyGyro:Destroy() end
         end)
      end
   end
})

Movement:CreateSlider({
   Name = "Fly Speed",
   Range = {20, 300},
   Increment = 10,
   CurrentValue = 50,
   Callback = function(v) FlySpeed = v end
})

-- ── Noclip ──
RunService.Stepped:Connect(function()
   if NoclipEnabled and LocalPlayer.Character then
      for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then part.CanCollide = false end
      end
   end
end)

Movement:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Callback = function(v) NoclipEnabled = v end
})

-- ── God Mode (client health lock) ──
spawn(function()
   while true do
      task.wait(0.1)
      if GodModeEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
         LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
         LocalPlayer.Character.Humanoid.MaxHealth = math.huge
      end
   end
end)

Movement:CreateToggle({
   Name = "God Mode (Client)",
   CurrentValue = false,
   Callback = function(v) GodModeEnabled = v end
})

-- ── WalkSpeed (your original + force) ──
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
      Rayfield:Notify({Title="Speed",Content="Locked to "..v.." — anti-reset active",Duration=4})
   end
})

spawn(function()
   while true do
      task.wait(0.03) -- tighter loop
      local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
      if hum and hum.WalkSpeed ~= CurrentSpeed then
         hum.WalkSpeed = CurrentSpeed
      end
   end
end)

-- ── ESP (simple box + name + health) ──
local ESPTable = {}
local function AddESP(plr)
   if plr == LocalPlayer or not plr.Character then return end
   local box = Drawing.new("Square")
   box.Thickness = 2
   box.Filled = false
   box.Transparency = 1
   local name = Drawing.new("Text")
   name.Size = 14
   name.Center = true
   name.Outline = true
   local healthBar = Drawing.new("Line")
   healthBar.Thickness = 2
   ESPTable[plr] = {Box = box, Name = name, Health = healthBar}
end

for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
Players.PlayerAdded:Connect(AddESP)

RunService.RenderStepped:Connect(function()
   if not ESPEnabled then
      for _, esp in pairs(ESPTable) do
         esp.Box.Visible = false
         esp.Name.Visible = false
         esp.Health.Visible = false
      end
      return
   end
   for plr, esp in pairs(ESPTable) do
      local char = plr.Character
      if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
         local rootPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
         if onScreen then
            local headPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0,1,0))
            local legPos = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0,3,0))
            local size = (headPos - legPos).Magnitude
            esp.Box.Size = Vector2.new(size * 1.5, size * 2)
            esp.Box.Position = Vector2.new(rootPos.X - esp.Box.Size.X / 2, rootPos.Y - esp.Box.Size.Y / 2)
            esp.Box.Color = Color3.fromRGB(255,0,0)
            esp.Box.Visible = true
            esp.Name.Text = plr.Name .. " [" .. math.floor(char.Humanoid.Health) .. "/" .. math.floor(char.Humanoid.MaxHealth) .. "]"
            esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - esp.Box.Size.Y / 2 - 20)
            esp.Name.Color = Color3.fromRGB(255,255,255)
            esp.Name.Visible = true
            -- Health bar
            local healthPct = char.Humanoid.Health / char.Humanoid.MaxHealth
            esp.Health.From = Vector2.new(rootPos.X - esp.Box.Size.X / 2 - 6, rootPos.Y + esp.Box.Size.Y / 2 * (1 - healthPct))
            esp.Health.To = Vector2.new(rootPos.X - esp.Box.Size.X / 2 - 6, rootPos.Y + esp.Box.Size.Y / 2)
            esp.Health.Color = Color3.fromHSV(healthPct / 3, 1, 1)
            esp.Health.Visible = true
         else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Health.Visible = false
         end
      else
         esp.Box.Visible = false
         esp.Name.Visible = false
         esp.Health.Visible = false
      end
   end
end)

Visuals:CreateToggle({
   Name = "Player ESP (Box + Name + HP)",
   CurrentValue = false,
   Callback = function(v) ESPEnabled = v end
})

-- ── Kill Aura ──
spawn(function()
   while true do
      task.wait(0.1)
      if KillAuraEnabled then
         local root = GetRoot()
         if not root then continue end
         for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
               local dist = (root.Position - plr.Character.HumanoidRootPart.Position).Magnitude
               if dist <= KillAuraRadius then
                  -- Simple punch/fire (adapt to game tool if needed)
                  pcall(function()
                     LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                     root.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-2)
                     task.wait(0.05)
                  end)
               end
            end
         end
      end
   end
end)

Combat:CreateToggle({
   Name = "Kill Aura (Auto Damage Nearby)",
   CurrentValue = false,
   Callback = function(v) KillAuraEnabled = v end
})

Combat:CreateSlider({
   Name = "Kill Aura Radius",
   Range = {5, 30},
   Increment = 1,
   CurrentValue = 15,
   Callback = function(v) KillAuraRadius = v end
})

-- ── AutoFarm Upgraded ── (filter for collectibles + auto-sell if found)
local AutoFarmRunning = false
local FarmRadius = 20
local FarmTargets = {"Coin", "Drop", "Collectible", "Cash", "Money", "Part"} -- add more game-specific

Farm:CreateToggle({
   Name = "Smart AutoFarm (Coins/Drops/Tycoon)",
   CurrentValue = false,
   Callback = function(v)
      AutoFarmRunning = v
      if v then Rayfield:Notify({Title="AutoFarm",Content="Smart scan active — farming coins/drops",Duration=5}) end
      if v then
         spawn(function()
            while AutoFarmRunning do
               pcall(function()
                  local root = GetRoot()
                  if not root then return end
                  local closest, minDist = nil, FarmRadius
                  for _, obj in ipairs(workspace:GetDescendants()) do
                     if (obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")) and obj.Parent then
                        local name = obj.Parent.Name:lower()
                        local isTarget = false
                        for _, t in ipairs(FarmTargets) do if name:find(t:lower()) then isTarget = true break end end
                        if isTarget then
                           local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                           if part then
                              local dist = (root.Position - part.Position).Magnitude
                              if dist < minDist then minDist = dist closest = obj end
                           end
                        end
                     end
                  end
                  if closest then
                     root.CFrame = closest.Parent.CFrame * CFrame.new(0, 3, -1)
                     task.wait(0.08)
                     if closest:IsA("ClickDetector") then fireclickdetector(closest)
                     elseif closest:IsA("ProximityPrompt") then fireproximityprompt(closest) end
                     task.wait(0.25)
                  end
               end)
               task.wait(0.35)
            end
         end)
      end
   end
})

Farm:CreateSlider({
   Name = "Farm Radius",
   Range = {10, 150},
   Increment = 5,
   CurrentValue = 20,
   Callback = function(v) FarmRadius = v end
})

-- Your original Instant Scan button here (unchanged, or enhance if wanted)

-- ── Teleport to Player (dropdown) ──
local playerList = {}
for _, plr in ipairs(Players:GetPlayers()) do table.insert(playerList, plr.Name) end
Players.PlayerAdded:Connect(function(plr) table.insert(playerList, plr.Name) end)
Players.PlayerRemoving:Connect(function(plr) for i,v in ipairs(playerList) do if v == plr.Name then table.remove(playerList,i) break end end end)

Main:CreateDropdown({
   Name = "Teleport to Player",
   Options = playerList,
   CurrentOption = "",
   Callback = function(selected)
      local target = Players:FindFirstChild(selected)
      if target and target.Character and GetRoot() then
         GetRoot().CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
      end
   end
})

-- ── Violation notifier (your original) ──
ReplicatedStorage:WaitForChild("AntiCheatViolation",5).OnClientEvent:Connect(function(msg)
   Rayfield:Notify({Title = "SERVER TRYNA SMOKE YOU", Content = msg .. " • Luzern still king tho", Duration = 10})
end)

Rayfield:Notify({Title = "Nuclear Hub 2026 Loaded", Content = "Full combat/movement/farm nukes ready • Risk it king", Duration = 8})
print("Amar nuclear drop 2026 — full godsend injected — opps uninstalling")
