local AsyV2 = {}
--YayYa Ai to fixed
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local HS = game:GetService("HttpService")

if makefolder then
    makefolder("aui")
    makefolder("aui/fonts")
end

if not isfile or (isfile and not isfile("aui/fonts/main.ttf")) then
    if writefile then
        writefile("aui/fonts/main.ttf", game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf"))
    end
end

local font_data = {
    name = "AUIFont",
    faces = {
        {
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = getcustomasset and getcustomasset("aui/fonts/main.ttf") or ""
        }
    }
}

if writefile and not isfile("aui/fonts/main_encoded.ttf") then
    writefile("aui/fonts/main_encoded.ttf", HS:JSONEncode(font_data))
end

local AsyV2Font = Font.new(getcustomasset and getcustomasset("aui/fonts/main_encoded.ttf") or Enum.Font.Gotham, Enum.FontWeight.Regular)

local themes = {
    PinkTokyoNight = {
        Accent = Color3.fromRGB(255, 150, 203),
        WindowOutlineBackground = Color3.fromRGB(30, 25, 45),
        WindowInlineBackground = Color3.fromRGB(40, 35, 60),
        WindowHolderBackground = Color3.fromRGB(50, 45, 75),
        PageUnselected = Color3.fromRGB(60, 55, 90),
        PageSelected = Color3.fromRGB(90, 80, 130),
        SectionBackground = Color3.fromRGB(45, 40, 70),
        SectionInnerBorder = Color3.fromRGB(80, 70, 110),
        SectionOuterBorder = Color3.fromRGB(25, 20, 40),
        WindowBorder = Color3.fromRGB(100, 85, 150),
        Text = Color3.fromRGB(245, 200, 230),
        RiskyText = Color3.fromRGB(255, 100, 150),
        ObjectBackground = Color3.fromRGB(55, 50, 85)
    }
}

local themeobjects = {}
local library = {
    theme = themes.PinkTokyoNight,
    flags = {},
    open = true,
    connections = {},
    currentcolor = nil
}

local function cr(cls, props)
    local obj = Instance.new(cls)
    for p, v in pairs(props) do 
        obj[p] = v 
    end
    return obj
end

local function tw(obj, props, dur)
    local ti = TweenInfo.new(dur or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TS:Create(obj, ti, props)
    t:Play()
    return t
end

local function createOutlinedFrame(parent, size, position, themeColor, zindex)
    local outline = cr("Frame", {
        Parent = parent,
        Size = size,
        Position = position,
        BackgroundColor3 = library.theme.WindowBorder,
        BorderSizePixel = 0
    })
    
    local inline = cr("Frame", {
        Parent = outline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.WindowInlineBackground,
        BorderSizePixel = 0
    })
    
    local main = cr("Frame", {
        Parent = inline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme[themeColor],
        BorderSizePixel = 0
    })
    
    if zindex then
        outline.ZIndex = zindex
        inline.ZIndex = zindex
        main.ZIndex = zindex
    end
    
    themeobjects[outline] = "WindowBorder"
    themeobjects[inline] = "WindowInlineBackground"
    themeobjects[main] = themeColor
    
    return main, outline, inline
end

local function createSectionOutlined(parent, size, position, name)
    local section = cr("Frame", {
        Parent = parent,
        Size = size,
        Position = position,
        BackgroundColor3 = library.theme.SectionBackground,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y  -- 添加自动调整高度
    })
    
    local outerOutline = cr("Frame", {
        Parent = section,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0
    })
    
    local innerOutline = cr("Frame", {
        Parent = outerOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0
    })
    
    local bg = cr("Frame", {
        Parent = innerOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionBackground,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y  -- 添加自动调整高度
    })
    
    local titleCover = cr("Frame", {
        Parent = bg,
        Size = UDim2.new(0, 0, 0, 4),
        Position = UDim2.new(0, 10, 0, -4),
        BackgroundColor3 = library.theme.WindowHolderBackground,
        BorderSizePixel = 0
    })
    
    local title = cr("TextLabel", {
        Parent = bg,
        Size = UDim2.new(0, 0, 0, 13),
        Position = UDim2.new(0, 10, 0, -8),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = library.theme.Text,
        TextSize = 13,
        FontFace = AsyV2Font,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    titleCover.Size = UDim2.new(0, title.TextBounds.X + 2, 0, 4)
    
    local content = cr("Frame", {
        Parent = bg,
        Size = UDim2.new(1, -32, 0, 0),  -- 修改为0高度，由内容决定
        Position = UDim2.new(0, 16, 0, 15),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y  -- 添加自动调整高度
    })
    
    local layout = cr("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    themeobjects[section] = "SectionBackground"
    themeobjects[outerOutline] = "SectionOuterBorder"
    themeobjects[innerOutline] = "SectionInnerBorder"
    themeobjects[bg] = "SectionBackground"
    themeobjects[titleCover] = "WindowHolderBackground"
    themeobjects[title] = "Text"
    
    return content, section  -- 返回section和content
end

local pickers = {}

function library.createcolorpicker(default, parent, count, flag, callback, offset)
    local icon = cr("TextButton", {
        BackgroundColor3 = default,
        Size = UDim2.new(0, 17, 0, 9),
        Position = UDim2.new(1, -17 - (count * 17) - (count * 6), 0, 4 + offset),
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
        ZIndex = 50
    })
    
    local outline = cr("Frame", {
        Parent = icon,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 51
    })
    
    local inline = cr("Frame", {
        Parent = outline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0,
        ZIndex = 52
    })
    
    local bg = cr("Frame", {
        Parent = inline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        ZIndex = 53
    })
    
    local gradient = cr("UIGradient", {
        Parent = icon,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, default)
        })
    })
    
    local window = cr("Frame", {
        BackgroundColor3 = library.theme.ObjectBackground,
        Size = UDim2.new(0, 185, 0, 200),
        Visible = false,
        Position = UDim2.new(1, -185 + (count * 20) + (count * 6), 1, 6),
        Parent = icon,
        ZIndex = 100
    })
    
    table.insert(pickers, window)
    
    local windowOutline = cr("Frame", {
        Parent = window,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 101
    })
    
    local windowInline = cr("Frame", {
        Parent = windowOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    
    local windowBg = cr("Frame", {
        Parent = windowInline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.ObjectBackground,
        BorderSizePixel = 0,
        ZIndex = 103
    })
    
    local saturation = cr("Frame", {
        BackgroundColor3 = default,
        Size = UDim2.new(0, 154, 0, 150),
        Position = UDim2.new(0, 6, 0, 6),
        Parent = windowBg,
        ZIndex = 104
    })
    
    local saturationGradient = cr("UIGradient", {
        Parent = saturation,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
        })
    })
    
    local saturationOutline = cr("Frame", {
        Parent = saturation,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 105
    })
    
    local saturationPicker = cr("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(0, 4, 0, 4),
        Position = UDim2.new(0.5, -2, 0.5, -2),
        BorderSizePixel = 1,
        BorderColor3 = Color3.new(1, 1, 1),
        Parent = saturation,
        ZIndex = 106
    })
    
    local hueFrame = cr("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 20, 0, 150),
        Position = UDim2.new(0, 170, 0, 6),
        Parent = windowBg,
        ZIndex = 104
    })
    
    local hueGradient = cr("UIGradient", {
        Parent = hueFrame,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })
    })
    
    local hueOutline = cr("Frame", {
        Parent = hueFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 105
    })
    
    local huePicker = cr("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0.5, -1),
        BorderSizePixel = 1,
        BorderColor3 = Color3.new(1, 1, 1),
        Parent = hueFrame,
        ZIndex = 106
    })
    
    local rgbInput = cr("Frame", {
        BackgroundColor3 = library.theme.ObjectBackground,
        Size = UDim2.new(1, -12, 0, 14),
        Position = UDim2.new(0, 6, 0, 160),
        Parent = windowBg,
        ZIndex = 104
    })
    
    local rgbOutline = cr("Frame", {
        Parent = rgbInput,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 105
    })
    
    local rgbInline = cr("Frame", {
        Parent = rgbOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0,
        ZIndex = 106
    })
    
    local rgbBg = cr("Frame", {
        Parent = rgbInline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.ObjectBackground,
        BorderSizePixel = 0,
        ZIndex = 107
    })
    
    local text = cr("TextLabel", {
        Text = string.format("%s, %s, %s", math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.theme.Text,
        TextSize = 11,
        FontFace = AsyV2Font,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = rgbBg,
        ZIndex = 108
    })
    
    local copy = cr("TextButton", {
        BackgroundColor3 = library.theme.ObjectBackground,
        Size = UDim2.new(0.5, -20, 0, 12),
        Position = UDim2.new(0, 6, 0, 180),
        Text = "copy",
        TextColor3 = library.theme.Text,
        TextSize = 11,
        FontFace = AsyV2Font,
        AutoButtonColor = false,
        Parent = windowBg,
        ZIndex = 104
    })
    
    local copyOutline = cr("Frame", {
        Parent = copy,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 105
    })
    
    local copyInline = cr("Frame", {
        Parent = copyOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0,
        ZIndex = 106
    })
    
    local copyBg = cr("Frame", {
        Parent = copyInline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.ObjectBackground,
        BorderSizePixel = 0,
        ZIndex = 107
    })
    
    local paste = cr("TextButton", {
        BackgroundColor3 = library.theme.ObjectBackground,
        Size = UDim2.new(0.5, -20, 0, 12),
        Position = UDim2.new(0.5, 15, 0, 180),
        Text = "paste",
        TextColor3 = library.theme.Text,
        TextSize = 11,
        FontFace = AsyV2Font,
        AutoButtonColor = false,
        Parent = windowBg,
        ZIndex = 104
    })
    
    local pasteOutline = cr("Frame", {
        Parent = paste,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = library.theme.SectionInnerBorder,
        BorderSizePixel = 0,
        ZIndex = 105
    })
    
    local pasteInline = cr("Frame", {
        Parent = pasteOutline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.SectionOuterBorder,
        BorderSizePixel = 0,
        ZIndex = 106
    })
    
    local pasteBg = cr("Frame", {
        Parent = pasteInline,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.ObjectBackground,
        BorderSizePixel = 0,
        ZIndex = 107
    })
    
    local hue, sat, val = default:ToHSV()
    local hsv = Color3.fromHSV(hue, sat, val)
    local currentHue = hue
    
    local function updateGradient()
        saturationGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(currentHue, 1, 1))
        })
    end
    
    local function set(color, nopos, setcolor)
        if type(color) == "table" then
            color = Color3.fromHex(color.color)
        end

        if type(color) == "string" then
            color = Color3.fromHex(color)
        end

        local oldcolor = hsv

        hue, sat, val = color:ToHSV()
        hsv = Color3.fromHSV(hue, sat, val)
        currentHue = hue

        if hsv ~= oldcolor then
            icon.BackgroundColor3 = hsv
            bg.BackgroundColor3 = hsv
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, hsv)
            })

            if not nopos then
                saturationPicker.Position = UDim2.new(sat, -2, 1 - val, -2)
                huePicker.Position = UDim2.new(0, 0, 1 - hue, -1)
                if setcolor then
                    updateGradient()
                end
            end

            text.Text = string.format("%s, %s, %s", math.round(hsv.R * 255), math.round(hsv.G * 255), math.round(hsv.B * 255))

            if flag then
                library.flags[flag] = hsv
            end

            callback(hsv)
        end
    end

    copy.MouseButton1Click:Connect(function()
        library.currentcolor = hsv
    end)

    paste.MouseButton1Click:Connect(function()
        if library.currentcolor ~= nil then
            set(library.currentcolor, false, true)
        end
    end)

    library.flags[flag] = set

    set(default)
    updateGradient()

    local slidingsaturation = false
    local slidinghue = false

    local function updatesatval(input)
        if not slidingsaturation then return end
        local relativeX = (input.Position.X - saturation.AbsolutePosition.X) / saturation.AbsoluteSize.X
        local relativeY = (input.Position.Y - saturation.AbsolutePosition.Y) / saturation.AbsoluteSize.Y
        
        if relativeX >= 0 and relativeX <= 1 and relativeY >= 0 and relativeY <= 1 then
            local sizeX = math.clamp(relativeX, 0, 1)
            local sizeY = math.clamp(relativeY, 0, 1)
            local posX = math.clamp(sizeX * saturation.AbsoluteSize.X, 0, saturation.AbsoluteSize.X - 2)
            local posY = math.clamp(sizeY * saturation.AbsoluteSize.Y, 0, saturation.AbsoluteSize.Y - 2)

            saturationPicker.Position = UDim2.new(0, posX, 0, posY)
            set(Color3.fromHSV(currentHue, sizeX, 1 - sizeY), true, false)
        end
    end

    local function updatehue(input)
        if not slidinghue then return end
        local relativeY = (input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y
        
        if relativeY >= 0 and relativeY <= 1 then
            local sizeY = math.clamp(relativeY, 0, 1)
            local posY = math.clamp(sizeY * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 1)

            huePicker.Position = UDim2.new(0, 0, 0, posY)
            currentHue = 1 - sizeY
            updateGradient()
            set(Color3.fromHSV(currentHue, sat, val), true, true)
        end
    end

    saturation.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidingsaturation = true
            updatesatval(input)
        end
    end)

    saturation.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidingsaturation = false
        end
    end)

    hueFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidinghue = true
            updatehue(input)
        end
    end)

    hueFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            slidinghue = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if slidinghue then
                updatehue(input)
            end
            if slidingsaturation then
                updatesatval(input)
            end
        end
    end)

    icon.MouseButton1Click:Connect(function()
        for _, picker in next, pickers do
            if picker ~= window then
                picker.Visible = false
            end
        end
        window.Visible = not window.Visible
    end)

    local colorpickertypes = {}
    function colorpickertypes:set(color)
        set(color)
    end
    return colorpickertypes, window
end

function AsyV2:CreateWindow(opt)
    local win = {
        name = opt.name or "AsyV2",
        size = opt.size or UDim2.new(0, 600, 0, 400),
        pages = {},
        pageButtons = {},
        pageAccents = {}
    }
    
    local sg = cr("ScreenGui", {Name = "AsyV2", Parent = CG})
    
    local windowOutline = cr("Frame", {
        Parent = sg,
        Size = win.size,
        Position = UDim2.new(0.5, -win.size.X.Offset/2, 0.5, -win.size.Y.Offset/2),
        BackgroundColor3 = library.theme.WindowOutlineBackground,
        BorderSizePixel = 0
    })
    
    local windowInline = cr("Frame", {
        Parent = windowOutline,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = library.theme.WindowInlineBackground,
        BorderSizePixel = 0
    })

    local windowInlineTopLine = cr("Frame", {
        Parent = windowInline,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })

    local windowHolder = cr("Frame", {
        Parent = windowInline,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = library.theme.WindowHolderBackground,
        BorderSizePixel = 0
    })

    themeobjects[windowInlineTopLine] = "Accent"
    
    
    local windowTopLine = cr("Frame", {
        Parent = windowHolder,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })
    
    local accent = cr("Frame", {
        Parent = windowHolder,
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = library.theme.Accent,
        BorderSizePixel = 0
    })
    
    local pagesHolder = cr("Frame", {
        Parent = windowHolder,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    })
    
    
    local contentHolder = cr("ScrollingFrame", {
        Parent = windowHolder,
        Size = UDim2.new(1, -40, 1, -45),
        Position = UDim2.new(0, 20, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = library.theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local dragButton = cr("TextButton", {
        Parent = windowHolder,
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    
    themeobjects[windowOutline] = "WindowOutlineBackground"
    themeobjects[windowInline] = "WindowInlineBackground"
    themeobjects[windowHolder] = "WindowHolderBackground"
    themeobjects[windowTopLine] = "Accent"
    themeobjects[accent] = "Accent"
    
    local drag = false
    local dragInput, dragStart, startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        windowOutline.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    local function handleInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = input.Position
            startPos = windowOutline.Position
        end
    end
    
    local function handleInputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end
    
    dragButton.InputBegan:Connect(handleInputBegan)
    dragButton.InputChanged:Connect(handleInputChanged)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and drag then
            updateInput(input)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    
    function win:CreateTab(name)
        local tab = {name = name, sections = {}}
        
        local tabButton = cr("TextButton", {
            Parent = pagesHolder,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = library.theme.PageUnselected,
            Text = name,
            TextColor3 = library.theme.Text,
            TextSize = 13,
            FontFace = AsyV2Font,
            AutoButtonColor = false
        })
        
        local tabAccent = cr("Frame", {
            Parent = tabButton,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = library.theme.Accent,
            BorderSizePixel = 0,
            Visible = false
        })
        
        local tabContent = cr("Frame", {
            Parent = contentHolder,
            Size = UDim2.new(1, 0, 0, 0),  -- 高度设为0，由内容决定
            BackgroundTransparency = 1,
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y  -- 自动调整高度
        })
        
        local leftContent = cr("Frame", {
            Parent = tabContent,
            Size = UDim2.new(0.5, -14, 0, 0),  -- 高度设为0，由内容决定
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y  -- 自动调整高度
        })
        
        local rightContent = cr("Frame", {
            Parent = tabContent,
            Size = UDim2.new(0.5, -14, 0, 0),  -- 高度设为0，由内容决定
            Position = UDim2.new(0.5, 14, 0, 0),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y  -- 自动调整高度
        })
        
        local leftLayout = cr("UIListLayout", {
            Parent = leftContent,
            Padding = UDim.new(0, 15),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        local rightLayout = cr("UIListLayout", {
            Parent = rightContent,
            Padding = UDim.new(0, 15),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        table.insert(win.pages, tabContent)
        table.insert(win.pageButtons, tabButton)
        table.insert(win.pageAccents, tabAccent)
        
        for i, btn in ipairs(win.pageButtons) do
            btn.Size = UDim2.new(1/#win.pageButtons, i == 1 and 1 or i == #win.pageButtons and -2 or -1, 1, 0)
            btn.Position = UDim2.new(1/(#win.pageButtons/(i-1)), i == 1 and 0 or 2, 0, 0)
        end
        
        local function selectTab()
            for i, page in ipairs(win.pages) do
                page.Visible = false
            end
            for i, btn in ipairs(win.pageButtons) do
                btn.BackgroundColor3 = library.theme.PageUnselected
            end
            for i, accent in ipairs(win.pageAccents) do
                accent.Visible = false
            end
            
            tabContent.Visible = true
            tabButton.BackgroundColor3 = library.theme.PageSelected
            tabAccent.Visible = true
        end
        
        tabButton.MouseButton1Click:Connect(selectTab)
        
        if #win.pages == 1 then
            selectTab()
        end
        
        function tab:CreateSection(opt)
            local section = {name = opt.name or "Section", side = opt.side or "Left"}
            local container = section.side == "Left" and leftContent or rightContent
            
            -- 修改createSectionOutlined返回值和参数
            local content, sectionFrame = createSectionOutlined(container, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, 0, 0), section.name)
            
            -- 监听布局变化，更新section高度
            local contentLayout = content:FindFirstChildOfClass("UIListLayout")
            if contentLayout then
                contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    local totalHeight = contentLayout.AbsoluteContentSize.Y + 35  -- 加上标题和间距的高度
                    if sectionFrame then
                        sectionFrame.Size = UDim2.new(1, 0, 0, totalHeight)
                    end
                end)
            end
            
            function section:CreateToggle(opt)
                local toggle = {
                    name = opt.name or "Toggle",
                    default = opt.default or false,
                    callback = opt.callback or function() end,
                    flag = opt.flag or ""
                }
                
                local holder = cr("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 8),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local toggleFrame = cr("Frame", {
                    Parent = holder,
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundColor3 = toggle.default and library.theme.Accent or library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local outline = cr("Frame", {
                    Parent = toggleFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = library.theme.SectionInnerBorder,
                    BorderSizePixel = 0
                })
                
                local inline = cr("Frame", {
                    Parent = outline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.SectionOuterBorder,
                    BorderSizePixel = 0
                })
                
                local bg = cr("Frame", {
                    Parent = inline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = toggle.default and library.theme.Accent or library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local title = cr("TextLabel", {
                    Parent = holder,
                    Size = UDim2.new(1, -25, 1, 0),
                    Position = UDim2.new(0, 13, 0, -3),
                    BackgroundTransparency = 1,
                    Text = toggle.name,
                    TextColor3 = library.theme.Text,
                    TextSize = 13,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                themeobjects[toggleFrame] = "ObjectBackground"
                themeobjects[outline] = "SectionInnerBorder"
                themeobjects[inline] = "SectionOuterBorder"
                themeobjects[bg] = "ObjectBackground"
                themeobjects[title] = "Text"
                
                local state = toggle.default
                
                local function setState(value)
                    state = value
                    toggle.callback(state)
                    if toggle.flag ~= "" then
                        library.flags[toggle.flag] = state
                    end
                    tw(toggleFrame, {BackgroundColor3 = state and library.theme.Accent or library.theme.ObjectBackground}, 0.2)
                    tw(bg, {BackgroundColor3 = state and library.theme.Accent or library.theme.ObjectBackground}, 0.2)
                end
                
                holder.MouseButton1Click:Connect(function()
                    setState(not state)
                end)
                
                if toggle.flag ~= "" then
                    library.flags[toggle.flag] = state
                end
                
                local toggleObj = {}
                function toggleObj:Set(value)
                    setState(value)
                end
                
                function toggleObj:CreateColorpicker(cfg)
                    local default = cfg.default or Color3.fromRGB(255, 150, 203)
                    local flag = cfg.flag or ""
                    local callback = cfg.callback or function() end
                    local colorpicker_tbl = {}
                    
                    local cp = library.createcolorpicker(default, holder, 0, flag, callback, -4)
                    function colorpicker_tbl:set(color)
                        cp:set(color, false, true)
                    end
                    return colorpicker_tbl
                end
                
                return toggleObj
            end
            
            function section:CreateButton(opt)
                local button = {
                    name = opt.name or "Button",
                    callback = opt.callback or function() end
                }
                
                local holder = cr("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local buttonFrame = cr("Frame", {
                    Parent = holder,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local outline = cr("Frame", {
                    Parent = buttonFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = library.theme.SectionInnerBorder,
                    BorderSizePixel = 0
                })
                
                local inline = cr("Frame", {
                    Parent = outline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.SectionOuterBorder,
                    BorderSizePixel = 0
                })
                
                local bg = cr("Frame", {
                    Parent = inline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local buttonText = cr("TextLabel", {
                    Parent = bg,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = button.name,
                    TextColor3 = library.theme.Text,
                    TextSize = 13,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Center
                })
                
                themeobjects[buttonFrame] = "ObjectBackground"
                themeobjects[outline] = "SectionInnerBorder"
                themeobjects[inline] = "SectionOuterBorder"
                themeobjects[bg] = "ObjectBackground"
                themeobjects[buttonText] = "Text"
                
                holder.MouseButton1Click:Connect(button.callback)
                holder.MouseEnter:Connect(function()
                    tw(bg, {BackgroundColor3 = library.theme.Accent}, 0.2)
                end)
                holder.MouseLeave:Connect(function()
                    tw(bg, {BackgroundColor3 = library.theme.ObjectBackground}, 0.2)
                end)
                
                local buttonObj = {}
                return buttonObj
            end
            
            function section:CreateLabel(opt)
                local label = {text = opt.text or "Label"}
                
                local holder = cr("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local labelText = cr("TextLabel", {
                    Parent = holder,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = label.text,
                    TextColor3 = library.theme.Text,
                    TextSize = 13,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                themeobjects[labelText] = "Text"
                
                local labelObj = {}
                function labelObj:CreateColorpicker(cfg)
                    local default = cfg.default or Color3.fromRGB(255, 150, 203)
                    local flag = cfg.flag or ""
                    local callback = cfg.callback or function() end
                    local colorpicker_tbl = {}
                    
                    local cp = library.createcolorpicker(default, holder, 0, flag, callback, -4)
                    function colorpicker_tbl:set(color)
                        cp:set(color, false, true)
                    end
                    return colorpicker_tbl
                end
                
                return labelObj
            end
            
            function section:CreateSlider(opt)
                local slider = {
                    name = opt.name or "Slider",
                    min = opt.min or 0,
                    max = opt.max or 100,
                    default = opt.default or 50,
                    callback = opt.callback or function() end,
                    flag = opt.flag or ""
                }
                
                local holder = cr("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local title = cr("TextLabel", {
                    Parent = holder,
                    Size = UDim2.new(1, -40, 0, 15),
                    Position = UDim2.new(0, 0, 0, -2),
                    BackgroundTransparency = 1,
                    Text = slider.name,
                    TextColor3 = library.theme.Text,
                    TextSize = 13,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local valueText = cr("TextLabel", {
                    Parent = holder,
                    Size = UDim2.new(0, 40, 0, 15),
                    Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(slider.default),
                    TextColor3 = library.theme.Text,
                    TextSize = 11,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local track = cr("Frame", {
                    Parent = holder,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 15),
                    BackgroundColor3 = library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local trackOutline = cr("Frame", {
                    Parent = track,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = library.theme.SectionInnerBorder,
                    BorderSizePixel = 0
                })
                
                local trackInline = cr("Frame", {
                    Parent = trackOutline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.SectionOuterBorder,
                    BorderSizePixel = 0
                })
                
                local trackBg = cr("Frame", {
                    Parent = trackInline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local fill = cr("Frame", {
                    Parent = trackBg,
                    Size = UDim2.new((slider.default - slider.min) / (slider.max - slider.min), 0, 1, 0),
                    BackgroundColor3 = library.theme.Accent,
                    BorderSizePixel = 0
                })
                
                local dragging = false
                
                local function set(value)
                    value = math.clamp(value, slider.min, slider.max)
                    local percent = (value - slider.min) / (slider.max - slider.min)
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    valueText.Text = tostring(math.floor(value))
                    slider.callback(value)
                    if slider.flag ~= "" then
                        library.flags[slider.flag] = value
                    end
                end
                
                set(slider.default)
                
                local function updateSlider(input)
                    local x = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    x = math.clamp(x, 0, 1)
                    set(slider.min + (slider.max - slider.min) * x)
                end
                
                holder.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                holder.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                holder.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)
                
                local sliderObj = {}
                function sliderObj:Set(value)
                    set(value)
                end
                
                return sliderObj
            end
            
            function section:CreateList(opt)
                local lst = {
                    name = opt.name or "List", 
                    options = opt.options or {}, 
                    def = opt.default or "",
                    multiselect = opt.multiselect or false,
                    callback = opt.callback or function() end,
                    flag = opt.flag or ""
                }
                
                local selectedOptions = {}
                if lst.def ~= "" then
                    if lst.multiselect and type(lst.def) == "table" then
                        selectedOptions = lst.def
                    else
                        selectedOptions = {lst.def}
                    end
                end
                
                local holder = cr("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, math.min(#lst.options * 20 + 35, 175)),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local title = cr("TextLabel", {
                    Parent = holder,
                    Size = UDim2.new(1, 0, 0, 15),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = lst.name,
                    TextColor3 = library.theme.Text,
                    TextSize = 13,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local listFrame, listOutline, listInline = createOutlinedFrame(holder, UDim2.new(1, 0, 1, -20), UDim2.new(0, 0, 0, 20), "ObjectBackground")
                
                local scrollFrame = cr("ScrollingFrame", {
                    Parent = listFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = library.theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #lst.options * 20),
                    BorderSizePixel = 0
                })
                
                local listLayout = cr("UIListLayout", {
                    Parent = scrollFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local optionButtons = {}
                
                local function updateSelection(option)
                    if lst.multiselect then
                        local index = table.find(selectedOptions, option)
                        if index then
                            table.remove(selectedOptions, index)
                        else
                            table.insert(selectedOptions, option)
                        end
                    else
                        selectedOptions = {option}
                        for btnOption, btn in pairs(optionButtons) do
                            if btnOption ~= option then
                                tw(btn, {BackgroundColor3 = library.theme.ObjectBackground}, 0.2)
                            end
                        end
                    end
                    
                    local isSelected = table.find(selectedOptions, option) ~= nil
                    if isSelected then
                        tw(optionButtons[option], {BackgroundColor3 = library.theme.Accent}, 0.2)
                    else
                        tw(optionButtons[option], {BackgroundColor3 = library.theme.ObjectBackground}, 0.2)
                    end
                    
                    if lst.flag ~= "" then
                        library.flags[lst.flag] = lst.multiselect and selectedOptions or option
                    end
                    
                    if lst.multiselect then
                        lst.callback(selectedOptions)
                    else
                        lst.callback(option)
                    end
                end
                
                for i, option in ipairs(lst.options) do
                    local optionBtn = cr("TextButton", {
                        Parent = scrollFrame,
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundColor3 = table.find(selectedOptions, option) and library.theme.Accent or library.theme.ObjectBackground,
                        TextColor3 = library.theme.Text,
                        TextSize = 11,
                        FontFace = AsyV2Font,
                        Text = option,
                        AutoButtonColor = false,
                        BorderSizePixel = 0
                    })
                    
                    optionButtons[option] = optionBtn
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        updateSelection(option)
                    end)
                end
                
                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
                end)
                
                local listObj = {}
                function listObj:Set(options)
                    if lst.multiselect and type(options) == "table" then
                        selectedOptions = {}
                        for option, btn in pairs(optionButtons) do
                            tw(btn, {BackgroundColor3 = library.theme.ObjectBackground}, 0.2)
                        end
                        for _, option in ipairs(options) do
                            if optionButtons[option] then
                                table.insert(selectedOptions, option)
                                tw(optionButtons[option], {BackgroundColor3 = library.theme.Accent}, 0.2)
                            end
                        end
                    else
                        selectedOptions = {options}
                        for option, btn in pairs(optionButtons) do
                            if option == options then
                                tw(btn, {BackgroundColor3 = library.theme.Accent}, 0.2)
                            else
                                tw(btn, {BackgroundColor3 = library.theme.ObjectBackground}, 0.2)
                            end
                        end
                    end
                    
                    if lst.flag ~= "" then
                        library.flags[lst.flag] = lst.multiselect and selectedOptions or options
                    end
                    
                    if lst.multiselect then
                        lst.callback(selectedOptions)
                    else
                        lst.callback(options)
                    end
                end
                
                function listObj:Update(newOptions)
                    lst.options = newOptions or lst.options
                    selectedOptions = {}
                    
                    for option, btn in pairs(optionButtons) do
                        btn:Destroy()
                    end
                    optionButtons = {}
                    
                    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #lst.options * 20)
                    holder.Size = UDim2.new(1, 0, 0, math.min(#lst.options * 20 + 35, 175))
                    
                    for i, option in ipairs(lst.options) do
                        local optionBtn = cr("TextButton", {
                            Parent = scrollFrame,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundColor3 = library.theme.ObjectBackground,
                            TextColor3 = library.theme.Text,
                            TextSize = 11,
                            FontFace = AsyV2Font,
                            Text = option,
                            AutoButtonColor = false,
                            BorderSizePixel = 0
                        })
                        
                        optionButtons[option] = optionBtn
                        
                        optionBtn.MouseButton1Click:Connect(function()
                            updateSelection(option)
                        end)
                    end
                end
                
                return listObj
            end
            
            function section:CreateTextbox(opt)
                local textbox = {
                    name = opt.name or "Textbox",
                    default = opt.default or "",
                    callback = opt.callback or function() end,
                    flag = opt.flag or ""
                }
                
                local holder = cr("TextButton", {
                    Parent = content,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false
                })
                
                local title = cr("TextLabel", {
                    Parent = holder,
                    Size = UDim2.new(1, 0, 0, 15),
                    Position = UDim2.new(0, 0, 0, -2),
                    BackgroundTransparency = 1,
                    Text = textbox.name,
                    TextColor3 = library.theme.Text,
                    TextSize = 13,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local textboxFrame = cr("Frame", {
                    Parent = holder,
                    Size = UDim2.new(1, 0, 0, 15),
                    Position = UDim2.new(0, 0, 0, 15),
                    BackgroundColor3 = library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local outline = cr("Frame", {
                    Parent = textboxFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = library.theme.SectionInnerBorder,
                    BorderSizePixel = 0
                })
                
                local inline = cr("Frame", {
                    Parent = outline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.SectionOuterBorder,
                    BorderSizePixel = 0
                })
                
                local bg = cr("Frame", {
                    Parent = inline,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = library.theme.ObjectBackground,
                    BorderSizePixel = 0
                })
                
                local textBox = cr("TextBox", {
                    Parent = bg,
                    Size = UDim2.new(1, -8, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = textbox.default,
                    TextColor3 = library.theme.Text,
                    TextSize = 11,
                    FontFace = AsyV2Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                
                themeobjects[textboxFrame] = "ObjectBackground"
                themeobjects[outline] = "SectionInnerBorder"
                themeobjects[inline] = "SectionOuterBorder"
                themeobjects[bg] = "ObjectBackground"
                themeobjects[textBox] = "Text"
                
                textBox.FocusLost:Connect(function()
                    textbox.callback(textBox.Text)
                    if textbox.flag ~= "" then
                        library.flags[textbox.flag] = textBox.Text
                    end
                end)
                
                local textboxObj = {}
                function textboxObj:Set(value)
                    textBox.Text = value
                    textbox.callback(value)
                    if textbox.flag ~= "" then
                        library.flags[textbox.flag] = value
                    end
                end
                
                return textboxObj
            end
            
            table.insert(tab.sections, section)
            return section
        end
        
        win.currentTab = tab
        return tab
    end
    
    return win
end

function library:ChangeThemeOption(option, color)
    self.theme[option] = color
    for obj, theme in pairs(themeobjects) do
        if obj:IsA("GuiObject") and theme == option then
            obj.BackgroundColor3 = color
        elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.TextColor3 = color
        end
    end
end

function library:SetTheme(themeName)
    if themes[themeName] then
        self.theme = themes[themeName]
        for obj, theme in pairs(themeobjects) do
            if obj:IsA("GuiObject") then
                obj.BackgroundColor3 = self.theme[theme]
            elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
                obj.TextColor3 = self.theme[theme]
            end
        end
    end
end
return AsyV2
