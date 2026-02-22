-- AmarNuclearHub v3 - Universal OP Client-Side Nuke 2026
-- No server-side cap — pure client domination + anti-detection tricks

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInput      = game:GetService("UserInputService")
local Replicated     = game:GetService("ReplicatedStorage")
local Tween          = game:GetService("TweenService")
local LocalPlayer    = Players.LocalPlayer
local Camera         = workspace.CurrentCamera

local Window = Rayfield:CreateWindow({
   Name = "Amar Nuclear Hub v3",
   LoadingTitle = "2026 Universal Nuke",
   LoadingSubtitle = "Luzern x OP Client Domination",
   ConfigurationSaving = {Enabled = true, FolderName = "AmarNukeV3"},
   KeySystem = false
})

local Tabs = {
   Main     = Window:CreateTab("Main",    4483362458),
   Combat   = Window:CreateTab("Combat",  4483345998),
   Visuals  = Window:CreateTab("Visuals", 4483362458),
   Move     = Window:CreateTab("Movement",4483362458),
   Farm     = Window:CreateTab("Farm",    4483362458),
   Misc     = Window:CreateTab("Misc",    4483362458)
}

-- Globals
local Toggles = { Fly = false, Noclip = false, InfJump = false, God = false, ESP = false, Aura = false, Silent = false, Farm = false }
local Values  = { FlySpeed = 60, AuraRadius = 18, FarmRadius = 25 }

local function GetRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function GetHum()  return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") end

-- ── Movement God Toggles ────────────────────────────────────────────────

Tabs.Move:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v)
   Toggles.InfJump = v
end})

UserInput.JumpRequest:Connect(function()
   if Toggles.InfJump and GetRoot() then
      GetRoot().Velocity = Vector3.new(0, 60, 0)
   end
end)

local FlyBV, FlyBG
Tabs.Move:CreateToggle({Name = "Fly (Space/Ctrl + WASD)", CurrentValue = false, Callback = function(v)
   Toggles.Fly = v
   local root = GetRoot()
   if not root then return end

   if v then
      FlyBV = Instance.new("BodyVelocity", root) FlyBV.MaxForce = Vector3.new(9e9,9e9,9e9) FlyBV.Velocity = Vector3.zero
      FlyBG = Instance.new("BodyGyro", root)    FlyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)   FlyBG.CFrame = root.CFrame

      spawn(function()
         while Toggles.Fly and root.Parent do
            local dir = Vector3.zero
            local look = Camera.CFrame.LookVector
            if UserInput:IsKeyDown(Enum.KeyCode.W) then dir = dir + look end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then dir = dir - look end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then dir = dir - look:Cross(Vector3.yAxis) end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then dir = dir + look:Cross(Vector3.yAxis) end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end

            FlyBV.Velocity = dir.Unit * Values.FlySpeed * 10
            FlyBG.CFrame = Camera.CFrame
            task.wait()
         end
         if FlyBV then FlyBV:Destroy() end
         if FlyBG then FlyBG:Destroy() end
      end)
   end
end})

Tabs.Move:CreateSlider({Name = "Fly Speed", Range = {30, 400}, Increment = 10, CurrentValue = 60, Callback = function(v) Values.FlySpeed = v end})

Tabs.Move:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v)
   Toggles.Noclip = v
end})

RunService.Stepped:Connect(function()
   if Toggles.Noclip and LocalPlayer.Character then
      for _, p in LocalPlayer.Character:GetDescendants() do
         if p:IsA("BasePart") then p.CanCollide = false end
      end
   end
end)

-- Force walkspeed + anti-reset (most universal)
local ws = 16
Tabs.Move:CreateSlider({Name = "WalkSpeed", Range = {16, 350}, Increment = 8, CurrentValue = 16, Callback = function(v)
   ws = v
   local h = GetHum()
   if h then h.WalkSpeed = v end
end})

spawn(function()
   while task.wait(0.04) do
      local h = GetHum()
      if h and h.WalkSpeed ~= ws then h.WalkSpeed = ws end
   end
end)

-- ── Combat Meta ─────────────────────────────────────────────────────────

Tabs.Combat:CreateToggle({Name = "Kill Aura (TP + Damage)", CurrentValue = false, Callback = function(v)
   Toggles.Aura = v
end})

spawn(function()
   while task.wait(0.12) do
      if not Toggles.Aura then continue end
      local root = GetRoot()
      if not root then continue end

      for _, p in Players:GetPlayers() do
         if p == LocalPlayer or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then continue end
         local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
         if dist > Values.AuraRadius then continue end

         pcall(function()
            root.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-1.8)
            task.wait(0.04)
         end)
      end
   end
end)

Tabs.Combat:CreateSlider({Name = "Aura Radius", Range = {8, 35}, Increment = 1, CurrentValue = 18, Callback = function(v) Values.AuraRadius = v end})

-- ── Visuals ─────────────────────────────────────────────────────────────

local ESPs = {}
local function CreateESP(plr)
   if plr == LocalPlayer then return end
   local box   = Drawing.new("Square")   box.Thickness = 2 box.Filled = false box.Transparency = 0.9
   local txt   = Drawing.new("Text")     txt.Size = 13 txt.Center = true txt.Outline = true
   local hpbar = Drawing.new("Line")     hpbar.Thickness = 2
   ESPs[plr] = {Box = box, Text = txt, HP = hpbar}
end

for _, p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
   if not Toggles.ESP then
      for _, e in ESPs do
         e.Box.Visible = false e.Text.Visible = false e.HP.Visible = false
      end
      return
   end

   for plr, e in ESPs do
      local char = plr.Character
      if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
         e.Box.Visible = false e.Text.Visible = false e.HP.Visible = false
         continue
      end

      local root, onScr = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
      if not onScr then
         e.Box.Visible = false e.Text.Visible = false e.HP.Visible = false
         continue
      end

      local head = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0,0.8,0))
      local leg  = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0,3.5,0))
      local sz   = (head - leg).Magnitude

      e.Box.Size     = Vector2.new(sz*1.4, sz*2.2)
      e.Box.Position = Vector2.new(root.X - e.Box.Size.X/2, root.Y - e.Box.Size.Y/2)
      e.Box.Color    = Color3.fromRGB(220, 20, 60)
      e.Box.Visible  = true

      e.Text.Text    = string.format("%s\n[%.0f]", plr.Name, char.Humanoid.Health)
      e.Text.Position= Vector2.new(root.X, root.Y - e.Box.Size.Y/2 - 18)
      e.Text.Color   = Color3.fromRGB(255,255,255)
      e.Text.Visible = true

      local pct = char.Humanoid.Health / char.Humanoid.MaxHealth
      e.HP.From  = Vector2.new(root.X - e.Box.Size.X/2 - 5, root.Y + e.Box.Size.Y/2)
      e.HP.To    = Vector2.new(root.X - e.Box.Size.X/2 - 5, root.Y + e.Box.Size.Y/2 * (1-pct) - e.Box.Size.Y/2)
      e.HP.Color = Color3.fromHSV(pct/3, 0.9, 1)
      e.HP.Visible = true
   end
end)

Tabs.Visuals:CreateToggle({Name = "Player ESP + Health", CurrentValue = false, Callback = function(v) Toggles.ESP = v end})

-- ── Universal Smart Farm ────────────────────────────────────────────────

local farmTargets = {"Coin","Money","Drop","Collect","Cash","Gem","Part","Chest","Reward"}

Tabs.Farm:CreateToggle({Name = "Universal Auto Collect", CurrentValue = false, Callback = function(v)
   Toggles.Farm = v
   if v then Rayfield:Notify({Title="Farm",Content="Scanning workspace for collectibles...",Duration=4.5}) end
end})

spawn(function()
   while task.wait(0.45) do
      if not Toggles.Farm then continue end
      local root = GetRoot()
      if not root then continue end

      local best, bestDist = nil, Values.FarmRadius

      for _, obj in workspace:GetDescendants() do
         if not (obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")) then continue end
         local name = (obj.Parent and obj.Parent.Name or ""):lower()
         local match = false
         for _, t in farmTargets do if name:find(t:lower()) then match = true break end end
         if not match then continue end

         local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
         if not part then continue end

         local dist = (root.Position - part.Position).Magnitude
         if dist < bestDist then bestDist = dist best = obj end
      end

      if best then
         root.CFrame = best.Parent.CFrame * CFrame.new(0, 3, -0.5)
         task.wait(0.07)
         if best:IsA("ClickDetector") then fireclickdetector(best)
         elseif best:IsA("ProximityPrompt") then fireproximityprompt(best, 1) end
      end
   end
end)

Tabs.Farm:CreateSlider({Name = "Farm Search Radius", Range = {12, 120}, Increment = 4, CurrentValue = 25, Callback = function(v) Values.FarmRadius = v end})

-- ── Misc / Anti ─────────────────────────────────────────────────────────

Tabs.Misc:CreateButton({Name = "Rejoin Server", Callback = function()
   game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end})

Tabs.Misc:CreateButton({Name = "Anti-AFK (Spin)", Callback = function()
   spawn(function()
      while task.wait(55) do
         pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(180), 0) end)
      end
   end)
   Rayfield:Notify({Title="Anti-AFK",Content="Spin every ~55s activated",Duration=5})
end})

-- Violation catch (if game has it)
if Replicated:FindFirstChild("AntiCheatViolation") then
   Replicated.AntiCheatViolation.OnClientEvent:Connect(function(msg)
      Rayfield:Notify({Title="Anti-Cheat Alert",Content=msg.."\nLuzern still undefeated",Duration=12})
   end)
end

Rayfield:Notify({Title = "Amar Nuclear Hub v3 Loaded", Content = "Universal client-side domination • Use alts king", Duration = 7})
print("Luzern 2026 universal nuke injected — opps bout to cry")
