local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()

local Window = Library:CreateWindow({Title = 'vector3.axus', Center = true, AutoShow = true})

local Tabs = {Main = Window:AddTab('Main'), Combat = Window:AddTab('Combat'), Rage = Window:AddTab('Rage'), Misc = Window:AddTab('Misc')}

local Boxes = {
    MainBox = Tabs.Main:AddLeftGroupbox('Main'), AutoBox = Tabs.Main:AddRightGroupbox('Auto'),
    HitBox = Tabs.Combat:AddLeftGroupbox('Hitbox'), CombatBox = Tabs.Combat:AddRightGroupbox('Combat'),
    RageBox = Tabs.Rage:AddLeftGroupbox('Rage'), SetBox = Tabs.Rage:AddRightGroupbox('Settings'),
    MiscBox = Tabs.Misc:AddLeftGroupbox('Misc'), VisualBox = Tabs.Misc:AddRightGroupbox('Visual')
}

local function getClosest(teamCheck)
    local lp = game.Players.LocalPlayer
    local closest, dist = nil, math.huge
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local char, hum, hrp = p.Character, char:FindFirstChild("Humanoid"), char:FindFirstChild("HumanoidRootPart")
            if teamCheck and p.Team and lp.Team and p.Team == lp.Team then continue end
            if hum and hum.Health > 0 and hrp then
                local d = (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then dist = d closest = p end
            end
        end
    end
    return closest
end

local function getToolEvents(tool)
    local events = {}
    for _, c in pairs(tool:GetChildren()) do
        if c.Name == "FireEvent" or c.Name == "DamageEvent" then table.insert(events, c) end
    end
    return events
end

local function Create(Box, Type, Name, Text, Callback, Options)
    if Type == "Toggle" then Box:AddToggle(Name, {Text = Text, Default = false, Callback = Callback})
    elseif Type == "Slider" then Box:AddSlider(Name, {Text = Text, Default = Options.Default, Min = Options.Min, Max = Options.Max, Rounding = 0, Callback = Callback})
    elseif Type == "Dropdown" then Box:AddDropdown(Name, {Text = Text, Values = Options.Values, Default = Options.Default, Callback = Callback}) end
end

Create(Boxes.MainBox, "Toggle", "TouchToggle", "Instant Touch", function(s)
    _G.Touch = s
    if s then
        local function onAdd(d) if d:IsA("TouchTransmitter") then d:Destroy() end end
        workspace.DescendantAdded:Connect(onAdd)
        for _, o in pairs(workspace:GetDescendants()) do if o:IsA("TouchTransmitter") then o:Destroy() end end
    end
end)

Create(Boxes.AutoBox, "Toggle", "InfUsesToggle", "Infinite Uses", function(s)
    _G.InfUses = s
    if s then for _, v in next, getgc(true) do
        if type(v) == "table" and rawget(v, "Inventory") then
            local oi = hookmetamethod(v, "__index", function(self, k) if k == "Uses" then return 999999 end return oi(self, k) end)
        end
    end end
end)

Create(Boxes.AutoBox, "Toggle", "NoCDToggle", "No Cooldown", function(s)
    _G.NoCD = s
    if s then for _, v in next, getgc(true) do
        if type(v) == "function" and islclosure(v) then
            local c = getconstants(v)
            for i, con in ipairs(c) do if con == "Cooldown" then hookfunction(v, function() return nil end) break end end
        end
    end end
end)

Create(Boxes.AutoBox, "Toggle", "AutoToolToggle", "Auto Tool", function(s)
    _G.AutoTool = s
    if s then spawn(function()
        while _G.AutoTool do
            local p = game.Players.LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local t = c:FindFirstChildOfClass("Tool")
            if t then pcall(t.Activate, t) end
            task.wait()
        end
    end) end
end)

Create(Boxes.AutoBox, "Toggle", "InfectToggle", "Auto Infect", function(s)
    _G.Infect = s
    if s then spawn(function()
        while _G.Infect do
            local args = {"S"}
            local inf = game.Players.LocalPlayer.Character:WaitForChild("Infected")
            if inf then local ev = inf:WaitForChild("InfectEvent") if ev then pcall(function() ev:FireServer(unpack(args)) end) end end
            task.wait()
        end
    end) end
end)

Create(Boxes.CombatBox, "Toggle", "ExpandHitboxToggle", "Expand Hitbox", function(s)
    _G.ExpandHitbox = s
    if s then
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        if char then local hrp = char:FindFirstChild("HumanoidRootPart") if hrp then hrp.Size = Vector3.new(10, 10, 10) end end
        lp.CharacterAdded:Connect(function(char) if _G.ExpandHitbox then local hrp = char:WaitForChild("HumanoidRootPart") hrp.Size = Vector3.new(10, 10, 10) end end)
    else
        local lp = game.Players.LocalPlayer
        local char = lp.Character
        if char then local hrp = char:FindFirstChild("HumanoidRootPart") if hrp then hrp.Size = Vector3.new(2, 2, 1) end end
    end
end)

Create(Boxes.CombatBox, "Toggle", "VelocityWalkToggle", "Velocity Walk", function(s)
    _G.VelocityWalk = s
    if s then spawn(function()
        local lp = game.Players.LocalPlayer
        local cam = workspace.CurrentCamera
        while _G.VelocityWalk do
            if lp.Character then
                local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                local hum = lp.Character:FindFirstChild("Humanoid")
                if hrp and hum then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        local velocity = moveDir * (_G.VelocitySpeed or 100)
                        hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, hrp.AssemblyLinearVelocity.Y, velocity.Z)
                    else hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
                end
            end
            task.wait()
        end
    end) end
end)

Create(Boxes.CombatBox, "Slider", "VelocitySpeedSlider", "Velocity Speed", function(v) _G.VelocitySpeed = v end, {Default = 100, Min = 1, Max = 500})

Create(Boxes.RageBox, "Toggle", "AimbotToggle", "Aimbot", function(s) _G.Aimbot = s end)
Create(Boxes.SetBox, "Slider", "AimbotFOVSlider", "Aimbot FOV", function(v) _G.AimbotFOV = v end, {Default = 100, Min = 1, Max = 360})
Create(Boxes.SetBox, "Toggle", "VisCheckToggle", "Visibility Check", function(s) _G.VisCheck = s end)

Create(Boxes.HitBox, "Toggle", "BigHitToggle", "Big Hitbox", function(s)
    _G.BigHit = s
    if s then
        local function onTool(t)
            if t:IsA("Tool") then
                local v3 = t:FindFirstChild("V3") if v3 and v3:IsA("MeshPart") then v3.Size = Vector3.new(6,5,6) end
                local v4 = t:FindFirstChild("V4") if v4 and v4:IsA("MeshPart") then v4.Size = Vector3.new(6,5,6) end
                t.Equipped:Connect(function() if _G.BigHit then if v3 and v3:IsA("MeshPart") then v3.Size = Vector3.new(6,5,6) end if v4 and v4:IsA("MeshPart") then v4.Size = Vector3.new(6,5,6) end end end)
            end
        end
        local p = game.Players.LocalPlayer
        local c = p.Character if c then for _, t in pairs(c:GetChildren()) do if t:IsA("Tool") then onTool(t) end end end
        p.CharacterAdded:Connect(function(char) char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then onTool(ch) end end) end)
        local bp = p:FindFirstChild("Backpack") if bp then bp.ChildAdded:Connect(onTool) for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") then onTool(t) end end end
    else
        local function reset(t)
            if t:IsA("Tool") then
                local v3 = t:FindFirstChild("V3") if v3 and v3:IsA("MeshPart") then v3.Size = Vector3.new(1,1,1) end
                local v4 = t:FindFirstChild("V4") if v4 and v4:IsA("MeshPart") then v4.Size = Vector3.new(1,1,1) end
            end
        end
        local p = game.Players.LocalPlayer
        local c = p.Character if c then for _, t in pairs(c:GetChildren()) do reset(t) end end
        local bp = p:FindFirstChild("Backpack") if bp then for _, t in pairs(bp:GetChildren()) do reset(t) end end
    end
end)

Create(Boxes.CombatBox, "Toggle", "BlinkToggle", "Blink", function(s)
    _G.Blink = s
    if s then spawn(function()
        local op, os repeat
            local pr, sr = '0', '60'
            if pr ~= op or sr ~= os then setfflag('PhysicsSenderMaxBandwidthBps', pr) setfflag('DataSenderRate', sr) op, os = pr, sr end
            task.wait(0.03)
        until not _G.Blink
    end) else if setfflag then setfflag('PhysicsSenderMaxBandwidthBps', '38760') setfflag('DataSenderRate', '60') end end
end)

Create(Boxes.RageBox, "Toggle", "GunRageToggle", "Gun Rage", function(s)
    _G.Rage = s
    if s then spawn(function()
        while _G.Rage do
            local t = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if t then
                local evs = getToolEvents(t)
                local closest = getClosest(true)
                if closest then
                    local thrp = closest.Character.HumanoidRootPart
                    local thum = closest.Character:FindFirstChild("Humanoid")
                    local tpart = closest.Character:FindFirstChild("Head")
                    for _, e in pairs(evs) do
                        if e.Name == "FireEvent" then e:FireServer(thrp.Position)
                        elseif e.Name == "DamageEvent" and thum then e:FireServer(thum, tpart, tpart.Position) end
                    end
                end
            end
            task.wait(0.1)
        end
    end) end
end)

Create(Boxes.RageBox, "Toggle", "GunTpToggle", "Gun Teleport", function(s)
    _G.GunTp = s
    if s then spawn(function()
        while _G.GunTp do
            for _, t in pairs(workspace:GetDescendants()) do
                if t:IsA("Tool") and t.Name:lower():find("gun") and not t.Parent:FindFirstChildOfClass("Humanoid") then
                    local lp = game.Players.LocalPlayer
                    if lp.Character then local hrp = lp.Character.HumanoidRootPart t.Handle.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5 end
                end
            end
            task.wait(1)
        end
    end) end
end)

Create(Boxes.SetBox, "Slider", "FOVSlider", "FOV", function(v) _G.FOV = v end, {Default = 90, Min = 1, Max = 360})
Create(Boxes.SetBox, "Dropdown", "AimPartDropdown", "Aim Part", function(p) _G.AimPart = p end, {Values = {'Head','Torso','HumanoidRootPart'}, Default = 'Head'})

Create(Boxes.MiscBox, "Toggle", "CoinToggle", "Coin Farm", function(s)
    _G.Coin = s
    if s then
        for _, o in pairs(workspace:GetDescendants()) do if o.Name:lower():find("coin") and o:IsA("Part") then o.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame task.wait(0.1) o:Destroy() end end
        workspace.DescendantAdded:Connect(function(o) if _G.Coin and o.Name:lower():find("coin") and o:IsA("Part") then o.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame task.wait(0.1) o:Destroy() end end)
    end
end)
Create(Boxes.CombatBox, "Toggle", "SpinBotToggle", "Spin Bot", function(s)
    _G.SpinBot = s
    if s then spawn(function()
        while _G.SpinBot do
            local lp = game.Players.LocalPlayer
            if lp.Character then
                local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(60), 0)
                end
            end
            task.wait()
        end
    end) end
end)
Create(Boxes.CombatBox, "Toggle", "ForceFieldChar", "Force Field Character", function(s)
    _G.ForceFieldChar = s
    if s then
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Material = Enum.Material.ForceField
                    part.Transparency = _G.ForceFieldTransparency or 0.3
                    part.Color = _G.ForceFieldColor or Color3.new(0, 0.5, 1)
                end
            end
        end
        game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
            if _G.ForceFieldChar then
                for _, part in pairs(newChar:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Material = Enum.Material.ForceField
                        part.Transparency = _G.ForceFieldTransparency or 0.3
                        part.Color = _G.ForceFieldColor or Color3.new(0, 0.5, 1)
                    end
                end
            end
        end)
    else
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Material = Enum.Material.Plastic
                    part.Transparency = 0
                end
            end
        end
    end
end)

Boxes.CombatBox:AddSlider("ForceFieldTransparency", {
    Text = "Force Field Transparency",
    Default = 30,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        _G.ForceFieldTransparency = v / 100
        if _G.ForceFieldChar then
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Transparency = _G.ForceFieldTransparency
                    end
                end
            end
        end
    end
})

Boxes.CombatBox:AddLabel("Force Field Color"):AddColorPicker("ForceFieldColorPicker", {
    Default = Color3.new(0, 0.5, 1),
    Callback = function(Value)
        _G.ForceFieldColor = Value
        if _G.ForceFieldChar then
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Color = _G.ForceFieldColor
                    end
                end
            end
        end
    end
})
Create(Boxes.VisualBox, "Toggle", "ESP", "ESP", function(s)
    _G.ESP = s
    if s then
        _G.ESPBoxes = {}
        local function createESP(player)
            if player == game.Players.LocalPlayer then return end
            local char = player.Character
            if not char then return end
            
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_" .. player.Name
            highlight.Adornee = char
            highlight.Parent = char
            highlight.FillColor = _G.ESPColor or (player.Team == game.Players.LocalPlayer.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
            highlight.FillTransparency = 0.7
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPInfo_" .. player.Name
            billboard.Adornee = char:WaitForChild("Head")
            billboard.Size = UDim2.new(0, 300, 0, 30)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = char
            
            local nametag = Instance.new("TextLabel")
            nametag.Name = "NameTag"
            nametag.Size = UDim2.new(1, 0, 1, 0)
            nametag.BackgroundTransparency = 1
            nametag.TextColor3 = _G.ESPTextColor or Color3.new(1, 1, 1)
            nametag.TextStrokeTransparency = 0
            nametag.Font = Enum.Font.Code
            nametag.TextSize = _G.ESPTextSize or 14
            nametag.Parent = billboard
            
            _G.ESPBoxes[player] = {highlight = highlight, billboard = billboard, nametag = nametag}
            
            spawn(function()
                while _G.ESP and char and char.Parent do
                    local distance = (game.Players.LocalPlayer.Character.Head.Position - char.Head.Position).Magnitude
                    local tool = char:FindFirstChildOfClass("Tool")
                    local health = char:FindFirstChild("Humanoid") and math.floor(char.Humanoid.Health) or 0
                    
                    nametag.Text = player.DisplayName .. " (@" .. player.Name .. ") | Distance: " .. math.floor(distance) .. " | Tool: " .. (tool and tool.Name or "None") .. " | Health: " .. health
                    
                    task.wait(0.1)
                end
            end)
        end
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                createESP(player)
            end
            player.CharacterAdded:Connect(function(char)
                if _G.ESP then
                    createESP(player)
                end
            end)
        end
        
        game.Players.PlayerAdded:Connect(function(player)
            if _G.ESP then
                player.CharacterAdded:Connect(function(char)
                    createESP(player)
                end)
            end
        end)
    else
        for player, espData in pairs(_G.ESPBoxes or {}) do
            if espData.highlight then espData.highlight:Destroy() end
            if espData.billboard then espData.billboard:Destroy() end
        end
        _G.ESPBoxes = {}
    end
end)

Boxes.VisualBox:AddLabel("ESP Color"):AddColorPicker("ESPColorPicker", {
    Default = Color3.new(1, 0, 0),
    Callback = function(Value)
        _G.ESPColor = Value
        if _G.ESP and _G.ESPBoxes then
            for player, espData in pairs(_G.ESPBoxes) do
                if espData.highlight then
                    espData.highlight.FillColor = _G.ESPColor
                end
            end
        end
    end
})

Boxes.VisualBox:AddLabel("Text Color"):AddColorPicker("ESPTextColorPicker", {
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        _G.ESPTextColor = Value
        if _G.ESP and _G.ESPBoxes then
            for player, espData in pairs(_G.ESPBoxes) do
                if espData.nametag then
                    espData.nametag.TextColor3 = _G.ESPTextColor
                end
            end
        end
    end
})

Boxes.VisualBox:AddSlider("ESPTextSize", {
    Text = "Text Size",
    Default = 14,
    Min = 8,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        _G.ESPTextSize = v
        if _G.ESP and _G.ESPBoxes then
            for player, espData in pairs(_G.ESPBoxes) do
                if espData.nametag then
                    espData.nametag.TextSize = _G.ESPTextSize
                end
            end
        end
    end
})
Create(Boxes.RageBox, "Toggle", "AutoSwing", "Auto Swing Hatchet", function(s)
    _G.AutoSwing = s
    if s then spawn(function()
        while _G.AutoSwing do
            local hatchet = game:GetService("Players").LocalPlayer:WaitForChild("Backpack"):FindFirstChild("Hatchet")
            if not hatchet then
                hatchet = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Hatchet")
            end
            
            if hatchet and hatchet:FindFirstChild("SwingEvent") then
                local closest = getClosest(true)
                if closest and closest.Character then
                    local targetPos = closest.Character:FindFirstChild("HumanoidRootPart").Position
                    local args = {
                        CFrame.new(targetPos.X, targetPos.Y, targetPos.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1)
                    }
                    hatchet.SwingEvent:FireServer(unpack(args))
                end
            end
            task.wait(0.1)
        end
    end) end
end)
Library:Notify("Loaded On vector3.axus successfully!!")
