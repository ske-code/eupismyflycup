-- deadcell_fixed_all.lua
-- Deadcell-style UI library — full single-file release
-- Includes: vc() font loader, drawing shim (GUI fallback), tween wrapper, and UI components
-- Save as a LocalScript and run in a LocalPlayer context (Roblox Studio Play or supported executor).

-- =========================
-- vc() : font loader (best-effort)
-- =========================
local function vc()
    local v2 = "Font_" .. tostring(math.random(10000, 99999))
    local v24 = "Folder_" .. tostring(math.random(10000, 99999))
    pcall(function() if makefolder then makefolder(v24) end end)
    local ttfpath = v24 .. "/" .. v2 .. ".ttf"
    pcall(function()
        if (not (isfile and isfile(ttfpath))) and (request or http_request) then
            local ok, res = pcall(function()
                return (request or http_request)({Url = "https://raw.githubusercontent.com/bluescan/proggyfonts/refs/heads/master/ProggyOriginal/ProggyClean.ttf", Method = "GET"})
            end)
            if ok and res and res.Success and writefile then
                pcall(function() writefile(ttfpath, res.Body) end)
            end
        end
    end)
    pcall(function()
        if readfile and isfile and isfile(ttfpath) then
            local contents = readfile(ttfpath)
            local ts = game:GetService("TextService")
            if ts and ts.RegisterFontFaceAsync and contents then
                pcall(function() ts:RegisterFontFaceAsync(contents, v2) end)
            end
        end
    end)
    return v2
end

local __CUSTOM_FONT = vc()

-- =========================
-- drawing shim
-- =========================
local drawing = {}
if typeof(Drawing) == "table" and Drawing.new then
    drawing = Drawing -- use native Drawing if present
else
    -- GUI fallback shim using ScreenGui objects
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = nil
    if LocalPlayer then
        PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    end
    if not PlayerGui then
        PlayerGui = Instance.new("ScreenGui")
        PlayerGui.Name = "Deadcell_ShimGui"
        PlayerGui.ResetOnSpawn = false
        PlayerGui.IgnoreGuiInset = true
        pcall(function() PlayerGui.Parent = game:GetService("CoreGui") end)
    end

    drawing = {}
    drawing.Fonts = { Plex = Enum.Font.SourceSans }
    -- generic creator
    drawing.new = function(class)
        class = tostring(class)
        local obj = { exists = true }
        if class == "Square" then
            local f = Instance.new("Frame")
            f.BackgroundColor3 = Color3.fromRGB(40,40,45)
            f.BorderSizePixel = 0
            f.Size = UDim2.new(0,100,0,20)
            f.Position = UDim2.new(0,0,0,0)
            f.Parent = PlayerGui
            obj._instance = f
            function obj:Remove() pcall(function() f:Destroy() end) obj.exists = false end
        elseif class == "Text" then
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Text = ""
            l.TextColor3 = Color3.new(1,1,1)
            l.TextSize = 13
            l.Font = drawing.Fonts.Plex
            l.Size = UDim2.new(0,100,0,20)
            l.Position = UDim2.new(0,0,0,0)
            l.Parent = PlayerGui
            obj._instance = l
            function obj:Remove() pcall(function() l:Destroy() end) obj.exists = false end
        elseif class == "Image" then
            local i = Instance.new("ImageLabel")
            i.BackgroundTransparency = 1
            i.Image = ""
            i.Size = UDim2.new(0,100,0,20)
            i.Position = UDim2.new(0,0,0,0)
            i.Parent = PlayerGui
            obj._instance = i
            function obj:Remove() pcall(function() i:Destroy() end) obj.exists = false end
        else
            local f = Instance.new("Frame")
            f.Size = UDim2.new(0,100,0,20)
            f.Parent = PlayerGui
            obj._instance = f
            function obj:Remove() pcall(function() f:Destroy() end) obj.exists = false end
        end

        setmetatable(obj, {
            __index = function(t,k)
                local inst = rawget(t,"_instance")
                if not inst then return rawget(t,k) end
                if k == "Position" and inst.Position then return inst.Position end
                if k == "Size" and inst.Size then return inst.Size end
                if k == "Color" then if inst:IsA("TextLabel") then return inst.TextColor3 end; if inst.BackgroundColor3 then return inst.BackgroundColor3 end end
                if k == "Text" and inst:IsA("TextLabel") then return inst.Text end
                if k == "ZIndex" and inst.ZIndex then return inst.ZIndex end
                return rawget(t,k)
            end,
            __newindex = function(t,k,v)
                local inst = rawget(t,"_instance")
                if inst then
                    if k == "Position" and inst.Position then inst.Position = v; return end
                    if k == "Size" and inst.Size then inst.Size = v; return end
                    if k == "Color" then
                        if inst:IsA("TextLabel") then inst.TextColor3 = v
                        elseif inst.BackgroundColor3 then inst.BackgroundColor3 = v end
                        return
                    end
                    if k == "Text" and inst:IsA("TextLabel") then inst.Text = v; return end
                    if k == "Font" and inst:IsA("TextLabel") then inst.Font = v; return end
                    if k == "Transparency" then
                        if inst.BackgroundTransparency ~= nil then inst.BackgroundTransparency = v end
                        if inst.TextTransparency ~= nil then inst.TextTransparency = v end
                        if inst.ImageTransparency ~= nil then inst.ImageTransparency = v end
                        return
                    end
                    if k == "ZIndex" and inst.ZIndex ~= nil then inst.ZIndex = v; return end
                end
                rawset(t,k,v)
            end
        })

        function obj:AddListLayout(padding)
            local inst = rawget(obj,"_instance")
            if inst and inst:IsA("Frame") then
                local layout = Instance.new("UIListLayout")
                layout.Padding = UDim.new(0, padding or 0)
                layout.Parent = inst
                return layout
            end
        end

        function obj:RemoveChildren()
            local inst = rawget(obj,"_instance")
            if inst then
                for _,c in pairs(inst:GetChildren()) do
                    pcall(function() c:Destroy() end)
                end
            end
        end

        return obj
    end
end

-- =========================
-- tween wrapper (simple)
-- =========================
local tween = {}
do
    local TweenService = game:GetService("TweenService")
    tween.new = function(target, tweeninfo, props)
        local realTarget = (type(target) == "table" and target._instance) or target
        local tw = TweenService:Create(realTarget, tweeninfo, props)
        local wrapper = { _tween = tw }
        function wrapper:Play() pcall(function() self._tween:Play() end) end
        function wrapper:Cancel() pcall(function() self._tween:Cancel() end) end
        return wrapper
    end
end

-- =========================
-- Utility functions
-- =========================
local utility = {}
function utility.getrgb(color)
    return math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
end
function utility.rgba(r,g,b,a) return Color3.fromRGB(r,g,b), a end
function utility.clamp(n, a, b) return math.max(a, math.min(b, n)) end
function utility.table_clone(t) local o = {} for k,v in pairs(t) do o[k]=v end return o end

-- =========================
-- Theme & images
-- =========================
local default_accent = Color3.fromRGB(61,100,227)
local themes = { Default = {
    Accent = default_accent,
    ["Window Outline Background"] = Color3.fromRGB(39,39,47),
    ["Window Inline Background"] = Color3.fromRGB(23,23,30),
    ["Window Holder Background"] = Color3.fromRGB(32,32,38),
    ["Section Background"] = Color3.fromRGB(27,27,34),
    ["Section Inner Border"] = Color3.fromRGB(50,50,58),
    ["Section Outer Border"] = Color3.fromRGB(19,19,27),
    ["Window Border"] = Color3.fromRGB(58,58,67),
    ["Text"] = Color3.fromRGB(245,245,245),
    ["Risky Text"] = Color3.fromRGB(245,239,120),
    ["Object Background"] = Color3.fromRGB(41,41,50)
}}

-- =========================
-- Library core
-- =========================
local Library = {}
Library.__index = Library
function Library.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Library)
    self.folder = opts.folder or "zephyrus"
    self.theme = utility.table_clone(themes.Default)
    self.notifications = {}
    self.connections = {}
    self.open = true
    return self
end

-- basic notify system
function Library:Notify(message, time, color)
    time = time or 5
    local notif = {}
    notif.holder = drawing.new("Square")
    notif.holder.Size = UDim2.new(0, (string.len(message)*6)+60, 0, 20)
    notif.holder.Position = UDim2.new(0, 10, 0, 70 + (#self.notifications * 30))
    notif.holder.Color = self.theme["Object Background"]
    notif.holder.Filled = true

    notif.text = drawing.new("Text")
    notif.text.Text = message
    notif.text.Position = UDim2.new(0, 12, 0, 72)
    notif.text.Size = 14
    notif.text.Font = drawing.Fonts.Plex
    notif.text.Color = self.theme["Text"]

    table.insert(self.notifications, notif)
    task.spawn(function()
        task.wait(time)
        pcall(function() notif.holder:Remove(); notif.text:Remove() end)
        for i,v in ipairs(self.notifications) do if v==notif then table.remove(self.notifications,i); break end end
    end)
    return notif
end

-- =========================
-- Window / Page / Section API
-- =========================
local Window = {}
Window.__index = Window

function Library:CreateWindow(title)
    local win = setmetatable({}, Window)
    win.title = title or "Zephyrus"
    win.pages = {}
    win.root = drawing.new("Square")
    win.root.Size = UDim2.new(0, 640, 0, 420)
    win.root.Position = UDim2.new(0.5, -320, 0.5, -210)
    win.root.Color = self.theme["Window Holder Background"]
    win.root.Filled = true

    win.outline = drawing.new("Square")
    win.outline.Size = UDim2.new(1,2,1,2)
    win.outline.Position = UDim2.new(0,-1,0,-1)
    win.outline.Color = self.theme["Window Border"]
    win.outline.Filled = true
    win.outline.Parent = win.root._instance and win.root or nil

    -- title text
    win.titletext = drawing.new("Text")
    win.titletext.Text = win.title
    win.titletext.Position = UDim2.new(0, 20, 0, 12)
    win.titletext.Size = 18
    win.titletext.Font = drawing.Fonts.Plex
    win.titletext.Color = self.theme["Text"]

    -- page holder (simple list down left)
    win.pageList = drawing.new("Square")
    win.pageList.Size = UDim2.new(0, 140, 0, 360)
    win.pageList.Position = UDim2.new(0, 20, 0, 60)
    win.pageList.Color = self.theme["Window Inline Background"]
    win.pageList.Filled = true

    win.pageContent = drawing.new("Square")
    win.pageContent.Size = UDim2.new(0, 460, 0, 360)
    win.pageContent.Position = UDim2.new(0, 170, 0, 60)
    win.pageContent.Color = self.theme["Page Unselected"] or self.theme["Window Inline Background"]
    win.pageContent.Filled = true

    function win:CreatePage(name)
        local page = { name = name, sections = {}, elements = {} }

        -- button in page list
        local btn = drawing.new("Square")
        btn.Size = UDim2.new(0, 120, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, 10 + (#self.pages * 36))
        btn.Color = self.theme["Page Unselected"]
        btn.Filled = true

        local btnt = drawing.new("Text")
        btnt.Text = name
        btnt.Position = UDim2.new(0, 20, 0, 14 + (#self.pages * 36))
        btnt.Size = 14
        btnt.Font = drawing.Fonts.Plex
        btnt.Color = self.theme["Text"]

        function page:Show()
            -- clear content
            if win.pageContent._instance and win.pageContent._instance:IsA("Frame") then
                for _,c in pairs(win.pageContent._instance:GetChildren()) do pcall(function() c:Destroy() end) end
            end
            -- create sections vertically
            local y = 10
            for _,sec in ipairs(page.sections) do
                sec._frame = Instance.new("Frame")
                sec._frame.Size = UDim2.new(0, 420, 0, sec.height or 100)
                sec._frame.Position = UDim2.new(0, 10, 0, y)
                sec._frame.BackgroundColor3 = Library.theme["Section Background"]
                sec._frame.BorderSizePixel = 0
                sec._frame.Parent = win.pageContent._instance or PlayerGui

                local secTitle = Instance.new("TextLabel")
                secTitle.Text = sec.name
                secTitle.TextColor3 = Library.theme["Text"]
                secTitle.BackgroundTransparency = 1
                secTitle.Font = drawing.Fonts.Plex
                secTitle.TextSize = 14
                secTitle.Position = UDim2.new(0,8,0,8)
                secTitle.Size = UDim2.new(1,-16,0,18)
                secTitle.Parent = sec._frame

                -- add elements
                local ex = 36
                for _,el in ipairs(sec.elements) do
                    if el.type == "button" then
                        local b = Instance.new("TextButton")
                        b.Text = el.text
                        b.Font = drawing.Fonts.Plex
                        b.TextSize = 14
                        b.TextColor3 = Library.theme["Text"]
                        b.BackgroundColor3 = Library.theme["Accent"]
                        b.Size = UDim2.new(0, 120, 0, 28)
                        b.Position = UDim2.new(0, 8 + (ex-36), 0, 36)
                        b.Parent = sec._frame
                        b.MouseButton1Click:Connect(function() pcall(el.callback) end)
                        ex = ex + 36
                    elseif el.type == "toggle" then
                        local lbl = Instance.new("TextLabel")
                        lbl.Text = el.text
                        lbl.Font = drawing.Fonts.Plex
                        lbl.TextSize = 14
                        lbl.TextColor3 = Library.theme["Text"]
                        lbl.BackgroundTransparency = 1
                        lbl.Position = UDim2.new(0,8,0,36+(ex-36))
                        lbl.Size = UDim2.new(0,200,0,28)
                        lbl.Parent = sec._frame

                        local tb = Instance.new("TextButton")
                        tb.Text = el.state and "On" or "Off"
                        tb.Font = drawing.Fonts.Plex
                        tb.TextSize = 14
                        tb.TextColor3 = Library.theme["Text"]
                        tb.BackgroundColor3 = el.state and Color3.fromRGB(100,200,100) or Color3.fromRGB(100,100,100)
                        tb.Size = UDim2.new(0,60,0,24)
                        tb.Position = UDim2.new(0, 320, 0, 36+(ex-36))
                        tb.Parent = sec._frame
                        tb.MouseButton1Click:Connect(function()
                            el.state = not el.state
                            tb.Text = el.state and "On" or "Off"
                            tb.BackgroundColor3 = el.state and Color3.fromRGB(100,200,100) or Color3.fromRGB(100,100,100)
                            pcall(function() el.callback(el.state) end)
                        end)
                        ex = ex + 36
                    elseif el.type == "slider" then
                        local lbl = Instance.new("TextLabel")
                        lbl.Text = el.text.." : "..tostring(el.value)
                        lbl.Font = drawing.Fonts.Plex
                        lbl.TextSize = 14
                        lbl.TextColor3 = Library.theme["Text"]
                        lbl.BackgroundTransparency = 1
                        lbl.Position = UDim2.new(0,8,0,36+(ex-36))
                        lbl.Size = UDim2.new(0,260,0,24)
                        lbl.Parent = sec._frame

                        local slider = Instance.new("Frame")
                        slider.Size = UDim2.new(0,200,0,8)
                        slider.Position = UDim2.new(0, 8, 0, 36+(ex-36)+26)
                        slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
                        slider.BorderSizePixel = 0
                        slider.Parent = sec._frame

                        local fill = Instance.new("Frame")
                        fill.Size = UDim2.new((el.value - (el.min or 0)) / ((el.max or 100) - (el.min or 0)),0,0,8)
                        fill.BackgroundColor3 = Library.theme["Accent"]
                        fill.BorderSizePixel = 0
                        fill.Parent = slider

                        local uis = game:GetService("UserInputService")
                        local dragging = false
                        slider.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = true
                            end
                        end)
                        slider.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                            end
                        end)
                        uis.InputChanged:Connect(function(input)
                            if dragging and input.UserInputState == Enum.UserInputState.Change then
                                local mouse = uis:GetMouseLocation()
                                local abs = mouse.X - slider.AbsolutePosition.X
                                local percent = utility.clamp(abs / slider.AbsoluteSize.X, 0, 1)
                                el.value = (el.min or 0) + percent * ((el.max or 100) - (el.min or 0))
                                fill.Size = UDim2.new(percent,0,0,8)
                                lbl.Text = el.text.." : "..string.format("%.2f", el.value)
                                pcall(function() el.callback(el.value) end)
                            end
                        end)
                        ex = ex + 48
                    elseif el.type == "colorpicker" then
                        local lbl = Instance.new("TextLabel")
                        lbl.Text = el.text
                        lbl.Font = drawing.Fonts.Plex
                        lbl.TextSize = 14
                        lbl.TextColor3 = Library.theme["Text"]
                        lbl.BackgroundTransparency = 1
                        lbl.Position = UDim2.new(0,8,0,36+(ex-36))
                        lbl.Size = UDim2.new(0,200,0,28)
                        lbl.Parent = sec._frame

                        local sample = Instance.new("Frame")
                        sample.Size = UDim2.new(0,24,0,24)
                        sample.Position = UDim2.new(0, 320, 0, 36+(ex-36))
                        sample.BackgroundColor3 = el.color or Color3.fromRGB(255,255,255)
                        sample.BorderSizePixel = 0
                        sample.Parent = sec._frame

                        local picker = Instance.new("Frame")
                        picker.Visible = false
                        picker.Size = UDim2.new(0,200,0,150)
                        picker.Position = UDim2.new(0, 8, 0, 36+(ex-36)+30)
                        picker.BackgroundColor3 = Library.theme["Window Inline Background"]
                        picker.Parent = sec._frame

                        -- simple color buttons
                        local colors = {
                            Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
                            Color3.fromRGB(255,255,0), Color3.fromRGB(255,128,0), Color3.fromRGB(128,0,255),
                            Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0)
                        }
                        local cx = 8
                        local cy = 8
                        for i,c in ipairs(colors) do
                            local cb = Instance.new("TextButton")
                            cb.Size = UDim2.new(0,32,0,32)
                            cb.Position = UDim2.new(0, cx, 0, cy)
                            cb.BackgroundColor3 = c
                            cb.Text = ""
                            cb.Parent = picker
                            cb.MouseButton1Click:Connect(function()
                                el.color = c
                                sample.BackgroundColor3 = c
                                picker.Visible = false
                                pcall(function() el.callback(c) end)
                            end)
                            cx = cx + 40
                            if cx > 160 then cx = 8; cy = cy + 40 end
                        end

                        sample.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                picker.Visible = not picker.Visible
                            end
                        end)
                        ex = ex + 60
                    end
                end
                y = y + (sec.height or 100) + 8
            end
        end

        function page:AddSection(name, height)
            local sec = { name = name, elements = {}, height = height or 120 }
            function sec:AddButton(text, callback)
                table.insert(sec.elements, { type = "button", text = text, callback = callback })
            end
            function sec:AddToggle(text, default, callback)
                table.insert(sec.elements, { type = "toggle", text = text, state = default or false, callback = callback })
            end
            function sec:AddSlider(text, minv, maxv, default, callback)
                table.insert(sec.elements, { type = "slider", text = text, min = minv or 0, max = maxv or 100, value = default or minv or 0, callback = callback })
            end
            function sec:AddColorPicker(text, defaultColor, callback)
                table.insert(sec.elements, { type = "colorpicker", text = text, color = defaultColor or Color3.fromRGB(255,255,255), callback = callback })
            end
            table.insert(page.sections, sec)
            return sec
        end

        table.insert(self.pages, page)
        return page
    end

    function win:ShowPage(indexOrName)
        for i,p in ipairs(self.pages) do
            if i == indexOrName or p.name == indexOrName then
                p:Show()
            end
        end
    end

    return win
end

-- =========================
-- Expose library creation
-- =========================
local __lib = Library.new()
return __lib
