local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max
local floor = math.floor
local min = math.min
local abs = math.abs
local noise = math.noise
local rad = math.rad
local random = math.random
local pow = math.pow
local sin = math.sin
local pi = math.pi
local tan = math.tan
local atan2 = math.atan2
local clamp = math.clamp

local insert = table.insert
local find = table.find
local remove = table.remove
local concat = table.concat

getgenv().VasaJas = {
    directory = "vasajas",
    folders = {
        "/fonts",
        "/configs",
    },
    flags = {},
    config_flags = {},
    connections = {},
    notifications = {},
    playerlist_data = {
        players = {},
        player = {},
    },
    colorpicker_open = false,
    gui = nil,
    is_mobile = uis.TouchEnabled
}

local themes = {
    preset = {
        accent = rgb(255, 200, 69),
        text = rgb(255, 255, 255),
        text_outline = rgb(0, 0, 0),
        a = Color3.fromRGB(0, 0, 0),
        b = Color3.fromRGB(56, 56, 56),
        c = Color3.fromRGB(46, 46, 46),
        d = Color3.fromRGB(12, 12, 12),
        e = Color3.fromRGB(21, 21, 21),
        f = Color3.fromRGB(84, 84, 84),
        g = Color3.fromRGB(54, 54, 54),
    },
    utility = {
        accent = {BackgroundColor3 = {}, Color = {}, ScrollBarImageColor3 = {}, TextColor3 = {}},
        text = {TextColor3 = {}, BackgroundColor3 = {}},
        text_outline = {Color = {}},
        a = {BackgroundColor3 = {}, Color = {}},
        b = {BackgroundColor3 = {}, Color = {}},
        c = {BackgroundColor3 = {}, Color = {}},
        d = {BackgroundColor3 = {}, Color = {}},
        e = {BackgroundColor3 = {}, Color = {}},
        f = {BackgroundColor3 = {}, Color = {}},
        g = {BackgroundColor3 = {}, Color = {}},
    }
}

local keys = {
    [Enum.KeyCode.LeftShift] = "LS",
    [Enum.KeyCode.RightShift] = "RS",
    [Enum.KeyCode.LeftControl] = "LC",
    [Enum.KeyCode.RightControl] = "RC",
    [Enum.KeyCode.Insert] = "INS",
    [Enum.KeyCode.Backspace] = "BS",
    [Enum.KeyCode.Return] = "Ent",
    [Enum.KeyCode.LeftAlt] = "LA",
    [Enum.KeyCode.RightAlt] = "RA",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.One] = "1",
    [Enum.KeyCode.Two] = "2",
    [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4",
    [Enum.KeyCode.Five] = "5",
    [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7",
    [Enum.KeyCode.Eight] = "8",
    [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.KeypadOne] = "Num1",
    [Enum.KeyCode.KeypadTwo] = "Num2",
    [Enum.KeyCode.KeypadThree] = "Num3",
    [Enum.KeyCode.KeypadFour] = "Num4",
    [Enum.KeyCode.KeypadFive] = "Num5",
    [Enum.KeyCode.KeypadSix] = "Num6",
    [Enum.KeyCode.KeypadSeven] = "Num7",
    [Enum.KeyCode.KeypadEight] = "Num8",
    [Enum.KeyCode.KeypadNine] = "Num9",
    [Enum.KeyCode.KeypadZero] = "Num0",
    [Enum.KeyCode.Minus] = "-",
    [Enum.KeyCode.Equals] = "=",
    [Enum.KeyCode.Tilde] = "~",
    [Enum.KeyCode.LeftBracket] = "[",
    [Enum.KeyCode.RightBracket] = "]",
    [Enum.KeyCode.RightParenthesis] = ")",
    [Enum.KeyCode.LeftParenthesis] = "(",
    [Enum.KeyCode.Semicolon] = ",",
    [Enum.KeyCode.Quote] = "'",
    [Enum.KeyCode.BackSlash] = "\\",
    [Enum.KeyCode.Comma] = ",",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Slash] = "/",
    [Enum.KeyCode.Asterisk] = "*",
    [Enum.KeyCode.Plus] = "+",
    [Enum.KeyCode.Period] = ".",
    [Enum.KeyCode.Backquote] = "`",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
    [Enum.KeyCode.Escape] = "ESC",
    [Enum.KeyCode.Space] = "SPC",
    [Enum.UserInputType.Touch] = "TOUCH",
}

VasaJas.__index = VasaJas

for _, path in next, VasaJas.folders do
    if makefolder then
        makefolder(VasaJas.directory .. path)
    end
end

local flags = VasaJas.flags
local config_flags = VasaJas.config_flags

if not isfile or (isfile and not isfile(VasaJas.directory .. "/fonts/main.ttf")) then
    if writefile then
        writefile(VasaJas.directory .. "/fonts/main.ttf", game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyClean.ttf"))
    end
end

local proggy_clean = {
    name = "ProggyClean",
    faces = {
        {
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = getcustomasset and getcustomasset(VasaJas.directory .. "/fonts/main.ttf") or ""
        }
    }
}

if writefile and not isfile(VasaJas.directory .. "/fonts/main_encoded.ttf") then
    writefile(VasaJas.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(proggy_clean))
end

VasaJas.font = Font.new(getcustomasset and getcustomasset(VasaJas.directory .. "/fonts/main_encoded.ttf") or Enum.Font.SourceSans, Enum.FontWeight.Regular)

function VasaJas:is_touch_input(input)
    return input.UserInputType == Enum.UserInputType.Touch
end

function VasaJas:is_click_input(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or self:is_touch_input(input)
end

function VasaJas:tween(obj, properties)
    local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
    return tween
end

function VasaJas:close_current_element(cfg)
    local path = self.current_element_open
    if path then
        path.set_visible(false)
        path.open = false
    end
end

function VasaJas:resizify(frame)
    local Frame = Instance.new("TextButton")
    Frame.Position = dim2(1, -10, 1, -10)
    Frame.BorderColor3 = rgb(0, 0, 0)
    Frame.Size = dim2(0, 10, 0, 10)
    Frame.BorderSizePixel = 0
    Frame.BackgroundColor3 = rgb(255, 255, 255)
    Frame.Parent = frame
    Frame.BackgroundTransparency = 1
    Frame.Text = ""

    local resizing = false
    local start_size
    local start
    local og_size = frame.Size

    Frame.InputBegan:Connect(function(input)
        if self:is_click_input(input) then
            resizing = true
            start = input.Position
            start_size = frame.Size
        end
    end)

    Frame.InputEnded:Connect(function(input)
        if self:is_click_input(input) then
            resizing = false
        end
    end)

    self:connection(uis.InputChanged, function(input, game_event)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or self:is_touch_input(input)) then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y

            local current_size = dim2(
                start_size.X.Scale,
                math.clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    og_size.X.Offset,
                    viewport_x
                ),
                start_size.Y.Scale,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    og_size.Y.Offset,
                    viewport_y
                )
            )
            frame.Size = current_size
        end
    end)
end

function VasaJas:mouse_in_frame(uiobject)
    local y_cond = uiobject.AbsolutePosition.Y <= (self.is_mobile and uis:GetMouseLocation().Y or uis:GetMouseLocation().Y)
    local x_cond = uiobject.AbsolutePosition.X <= (self.is_mobile and uis:GetMouseLocation().X or uis:GetMouseLocation().X)

    return (y_cond and x_cond)
end

VasaJas.lerp = function(start, finish, t)
    t = t or 1 / 8
    return start * (1 - t) + finish * t
end

function VasaJas:draggify(frame)
    local dragging = false
    local start_size = frame.Position
    local start

    frame.InputBegan:Connect(function(input)
        if self:is_click_input(input) then
            dragging = true
            start = input.Position
            start_size = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if self:is_click_input(input) then
            dragging = false
        end
    end)

    self:connection(uis.InputChanged, function(input, game_event)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or self:is_touch_input(input)) then
            local viewport_x = camera.ViewportSize.X
            local viewport_y = camera.ViewportSize.Y

            local current_position = dim2(
                0,
                clamp(
                    start_size.X.Offset + (input.Position.X - start.X),
                    0,
                    viewport_x - frame.Size.X.Offset
                ),
                0,
                math.clamp(
                    start_size.Y.Offset + (input.Position.Y - start.Y),
                    0,
                    viewport_y - frame.Size.Y.Offset
                )
            )

            frame.Position = current_position
        end
    end)
end

function VasaJas:convert(str)
    local values = {}
    for value in string.gmatch(str, "[^,]+") do
        insert(values, tonumber(value))
    end
    
    if #values == 4 then              
        return unpack(values)
    else 
        return
    end
end

function VasaJas:convert_enum(enum)
    local enum_parts = {}
    for part in string.gmatch(enum, "[%w_]+") do
        insert(enum_parts, part)
    end

    local enum_table = Enum
    for i = 2, #enum_parts do
        local enum_item = enum_table[enum_parts[i]]
        enum_table = enum_item
    end

    return enum_table
end

local config_holder;
function VasaJas:update_config_list()
    if not config_holder then
        return
    end

    local list = {}
    if listfiles then
        for idx, file in next, listfiles(self.directory .. "/configs") do
            local name = file:gsub(self.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(self.directory .. "\\configs\\", "")
            list[#list + 1] = name
        end
    end
    
    config_holder.refresh_options(list)
end

function VasaJas:get_config()
    local Config = {}
    for _, v in flags do
        if type(v) == "table" and v.key then
            Config[_] = {active = v.active, mode = v.mode, key = tostring(v.key)}
        elseif type(v) == "table" and v["Transparency"] and v["Color"] then
            Config[_] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
        else
            Config[_] = v
        end
    end 
    
    return http_service:JSONEncode(Config)
end

function VasaJas:load_config(config_json)
    local config = http_service:JSONDecode(config_json)
    
    for _, v in next, config do
        local function_set = self.config_flags[_]
        
        if _ == "config_name_list" then
            continue
        end

        if function_set then
            if type(v) == "table" and v["Transparency"] and v["Color"] then
                function_set(hex(v["Color"]), v["Transparency"])
            elseif type(v) == "table" and v["active"] then
                function_set(v)
            else
                function_set(v)
            end
        end
    end
end

function VasaJas:round(number, float)
    local multiplier = 1 / (float or 1)
    return floor(number * multiplier + 0.5) / multiplier
end

function VasaJas:apply_theme(instance, theme, property)
    insert(themes.utility[theme][property], instance)
end

function VasaJas:update_theme(theme, color)
    for _, property in themes.utility[theme] do
        for m, object in property do
            if object[_] == themes.preset[theme] then
                object[_] = color
            end
        end
    end

    themes.preset[theme] = color
end

function VasaJas:connection(signal, callback)
    local connection = signal:Connect(callback)
    insert(self.connections, connection)
    return connection
end

function VasaJas:apply_stroke(parent)
end

function VasaJas:create(instance, options)
    local ins = Instance.new(instance)
    
    for prop, value in next, options do
        ins[prop] = value
    end
    
    if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then
        self:apply_theme(ins, "text", "TextColor3")
        self:apply_stroke(ins)
    end
    
    return ins
end

function VasaJas:unload_menu()
    if self.gui then
        self.gui:Destroy()
    end
    
    for index, connection in next, self.connections do
        connection:Disconnect()
        connection = nil
    end
    
    VasaJas = nil
end

function VasaJas:window(properties)
    local cfg = {
        name = properties.name or properties.Name or "vasajas",
        size = properties.size or properties.Size or dim2(0, 560, 0, 740),
        selected_tab = nil
    }

    self.gui = self:create("ScreenGui", {
        Parent = coregui,
        Name = "\0",
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    local a = self:create("Frame", {
        Parent = self.gui;
        BackgroundTransparency = 1;
        Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2);
        BorderColor3 = rgb(0, 0, 0);
        Size = cfg.size;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); self:resizify(a); self:draggify(a); a.Position = dim2(0, a.AbsolutePosition.Y, 0, a.AbsolutePosition.Y)

    self:create("UIStroke", {
        Parent = a;
        LineJoinMode = Enum.LineJoinMode.Miter
    }); self:apply_theme(UIStroke, "a", "Color")
    
    local b = self:create("Frame", {
        Parent = a;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(56, 56, 56)
    }); self:apply_theme(b, "b", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(56, 56, 56);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = b;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "b", "Color")
    
    local c = self:create("Frame", {
        Parent = b;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(c, "c", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(46, 46, 46);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = c;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "c", "Color")
    
    local c = self:create("Frame", {
        Parent = c;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(c, "c", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(46, 46, 46);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = c;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "c", "Color")
    
    local b = self:create("Frame", {
        Parent = c;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(b, "c", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(56, 56, 56);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = b;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "b", "Color")
    
    local a = self:create("Frame", {
        Parent = b;
        BackgroundTransparency = 0.3499999940395355;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    }); self:apply_theme(a, "a", "BackgroundColor3")
    
    local tab_holder = self:create("Frame", {
        Parent = a;
        BackgroundTransparency = 1;
        Position = dim2(0, 17, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -34, 0, 28);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.tab_holder = tab_holder
    
    self:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = tab_holder;
        Padding = dim(0, 4);
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    
    local a = self:create("Frame", {
        Parent = a;
        Position = dim2(0, 17, 0, 31);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -34, 1, -46);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    }); self:apply_theme(a, "a", "BackgroundColor3")
    
    local b = self:create("Frame", {
        Parent = a;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(b, "c", "BackgroundColor3"); cfg.inline = b

    local keybindlist = self:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        Parent = self.gui;
        BackgroundTransparency = 1;
        Position = dim2(0, 100, 0, 600);
        Size = dim2(0, 202, 0, 66);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(255, 255, 255)
    }); self:resizify(keybindlist); self:draggify(keybindlist);
    
    self:create("UIStroke", {
        Parent = keybindlist;
        LineJoinMode = Enum.LineJoinMode.Miter
    }); self:apply_theme(UIStroke, "a", "Color")
    
    local inline1 = self:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        Parent = keybindlist;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(56, 56, 56)
    }); self:apply_theme(inline1, "b", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(56, 56, 56);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = inline1;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "b", "Color")
    
    local inline2 = self:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        Parent = inline1;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(inline2, "c", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(46, 46, 46);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = inline2;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "c", "Color")
    
    local inline3 = self:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        Parent = inline2;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(inline3, "c", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(46, 46, 46);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = inline3;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "c", "Color")
    
    local inline4 = self:create("Frame", {
        BorderColor3 = rgb(0, 0, 0);
        Parent = inline3;
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(inline4, "b", "BackgroundColor3")
    
    self:create("UIStroke", {
        Color = rgb(56, 56, 56);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Parent = inline4;
        Transparency = 0.25
    }); self:apply_theme(UIStroke, "b", "Color")
    
    local inline5 = self:create("Frame", {
        Parent = inline4;
        BackgroundTransparency = 0.3499999940395355;
        Size = dim2(1, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(0, 0, 0)
    }); self:apply_theme(inline5, "a", "BackgroundColor3")
    
    local tab_holder = self:create("Frame", {
        Parent = inline5;
        BackgroundTransparency = 1;
        Position = dim2(0, 17, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 28);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    self:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = tab_holder;
        Padding = dim(0, 4);
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    
    local button = self:create("TextButton", {
        FontFace = self.font;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = "keybinds";
        Parent = tab_holder;
        BackgroundTransparency = 1;
        Size = dim2(0, 200, 0, 50);
        BorderSizePixel = 0;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local accent = self:create("Frame", {
        AnchorPoint = vec2(0, 1);
        Parent = button;
        Position = dim2(0, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 4);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent
    }); self:apply_theme(accent, "accent", "BackgroundColor3")
    
    local split = self:create("Frame", {
        AnchorPoint = vec2(0, 1);
        Parent = accent;
        Position = dim2(0, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent
    });
    
    self:create("UIGradient", {
        Color = rgbseq{rgbkey(0, rgb(167, 167, 167)), rgbkey(1, rgb(167, 167, 167))};
        Parent = split
    });
    
    local inline6 = self:create("Frame", {
        Parent = inline5;
        Size = dim2(1, -34, 0, 0);
        Position = dim2(0, 17, 0, 31);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(0, 0, 0)
    }); self:apply_theme(inline6, "a", "BackgroundColor3")
    
    local inline7 = self:create("Frame", {
        Parent = inline6;
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(inline7, "b", "BackgroundColor3")
    
    local inline8 = self:create("Frame", {
        Parent = inline7;
        Size = dim2(1, -2, 1, -2);
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundColor3 = rgb(21, 21, 21)
    }); self:apply_theme(inline8, "e", "BackgroundColor3"); self.keybind_list = inline8;
    
    self:create("UIListLayout", {
        Parent = inline8;
        Padding = dim(0, 10);
        SortOrder = Enum.SortOrder.LayoutOrder
    });
    
    self:create("UIPadding", {
        PaddingTop = dim(0, 8);
        PaddingBottom = dim(0, 8);
        Parent = inline8;
        PaddingRight = dim(0, 2);
        PaddingLeft = dim(0, 8)
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 2);
        PaddingRight = dim(0, 2);
        Parent = inline7
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 2);
        PaddingRight = dim(0, 2);
        Parent = inline6
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 10);
        PaddingRight = dim(0, 34);
        Parent = inline5
    });
    
    self:create("UIPadding", {
        Parent = inline4
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 2);
        PaddingRight = dim(0, 2);
        Parent = inline3
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 2);
        PaddingRight = dim(0, 2);
        Parent = inline2
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 2);
        PaddingRight = dim(0, 2);
        Parent = inline1
    });
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 2);
        PaddingRight = dim(0, 2);
        Parent = keybindlist
    });

    return setmetatable(cfg, self)
end

function VasaJas:tab(properties)
    local cfg = {
        name = properties.name or "visuals",
    }

    local button = self:create("TextButton", {
        FontFace = self.font;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Parent = self.tab_holder;
        BackgroundTransparency = 1;
        Size = dim2(0, 200, 0, 50);
        BorderSizePixel = 0;
        TextSize = 12;
        Text = cfg.name;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local accent = self:create("Frame", {
        AnchorPoint = vec2(0, 1);
        Parent = button;
        Position = dim2(0, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 4);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(84, 84, 84)
    }); self:apply_theme(accent, "accent", "BackgroundColor3"); self:apply_theme(accent, "f", "BackgroundColor3")
    
    local split = self:create("Frame", {
        AnchorPoint = vec2(0, 1);
        Parent = accent;
        Position = dim2(0, 0, 1, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(84, 84, 84)
    }); self:apply_theme(split, "accent", "BackgroundColor3"); self:apply_theme(split, "f", "BackgroundColor3")
    
    self:create("UIGradient", {
        Color = rgbseq{rgbkey(0, rgb(167, 167, 167)), rgbkey(1, rgb(167, 167, 167))};
        Parent = split
    });

    local e = self:create("Frame", {
        Parent = self.inline;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        Visible = false;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(21, 21, 21)
    }); self:apply_theme(e, "e", "BackgroundColor3"); cfg.page_holder = e;
    
    self:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = e;
        Padding = dim(0, 12);
        SortOrder = Enum.SortOrder.LayoutOrder;
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    
    self:create("UIPadding", {
        PaddingTop = dim(0, 22);
        PaddingBottom = dim(0, 22);
        Parent = e;
        PaddingRight = dim(0, 22);
        PaddingLeft = dim(0, 22)
    });

    local frame = self:create("Frame", {
        BackgroundTransparency = 1;
        Position = dim2(0, 22, 0, 22);
        BorderColor3 = rgb(0, 0, 0);
        Parent = e;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.left = frame
    
    self:create("UIListLayout", {
        Parent = frame;
        Padding = dim(0, 12);
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        VerticalFlex = Enum.UIFlexAlignment.Fill;
    });

    local frame = self:create("Frame", {
        BackgroundTransparency = 1;
        Position = dim2(0, 22, 0, 22);
        BorderColor3 = rgb(0, 0, 0);
        Parent = e;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.right = frame
    
    self:create("UIListLayout", {
        Parent = frame;
        Padding = dim(0, 12);
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        VerticalFlex = Enum.UIFlexAlignment.Fill;
    });

    function cfg.open_tab()
        local selected_tab = self.selected_tab
        
        if selected_tab then
            selected_tab[1].Visible = false
            selected_tab[2].BackgroundColor3 = themes.preset.f
            selected_tab[3].BackgroundColor3 = themes.preset.f

            selected_tab = nil
        end

        e.Visible = true
        accent.BackgroundColor3 = themes.preset.accent
        split.BackgroundColor3 = themes.preset.accent

        self.selected_tab = {e, accent, split}
    end

    button.MouseButton1Down:Connect(function()
        cfg.open_tab()
    end)

    if not self.selected_tab then
        cfg.open_tab(true)
    end

    return setmetatable(cfg, self)
end

function VasaJas:section(properties)
    local cfg = {
        name = properties.name or properties.Name or "section",
        side = properties.side or "left",
        fill = properties.fill or 0.01,
    }

    local parent = self[cfg.side]

    local section = self:create("Frame", {
        Parent = parent;
        BackgroundTransparency = 1;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, cfg.fill, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    self:create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalFlex = Enum.UIFlexAlignment.Fill;
        Parent = section;
        Padding = dim(0, 12);
        VerticalFlex = Enum.UIFlexAlignment.Fill
    });
    
    local a = self:create("Frame", {
        Position = dim2(0, 22, 0, 22);
        BorderColor3 = rgb(0, 0, 0);
        Parent = section;
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0)
    });
    
    local c = self:create("Frame", {
        Parent = a;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(c, "c", "BackgroundColor3")
    
    local e = self:create("Frame", {
        Parent = c;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(21, 21, 21)
    }); self:apply_theme(e, "e", "BackgroundColor3")
    
    local section_title = self:create("TextLabel", {
        FontFace = self.font;
        Parent = e;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        AutomaticSize = Enum.AutomaticSize.Y;
        Size = dim2(1, -10, 0, 0);
        Position = dim2(0, 10, 0, -7);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        ZIndex = 2;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local scrolling_frame = self:create("ScrollingFrame", {
        ScrollBarImageColor3 = themes.preset.accent;
        MidImage = "rbxassetid://72824869889812";
        Parent = e;
        Active = true;
        AutomaticCanvasSize = Enum.AutomaticSize.Y;
        ScrollBarThickness = 2;
        ZIndex = 2;
        Size = dim2(1, 0, 1, 0);
        BackgroundColor3 = rgb(255, 255, 255);
        TopImage = "rbxassetid://85156243582367";
        BorderColor3 = rgb(0, 0, 0);
        BackgroundTransparency = 1;
        BottomImage = "rbxassetid://139338441481766";
        BorderSizePixel = 0;
        CanvasSize = dim2(0, 0, 0, 0)
    }); self:apply_theme(scrolling_frame, "accent", "ScrollBarImageColor3")
    
    local elements = self:create("Frame", {
        Parent = scrolling_frame;
        BackgroundTransparency = 1;
        Position = dim2(0, 8, 0, 10);
        AutomaticSize = Enum.AutomaticSize.Y;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -12, 0, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.elements = elements;
    
    self:create("UIListLayout", {
        Parent = elements;
        Padding = dim(0, 5);
        SortOrder = Enum.SortOrder.LayoutOrder
    });
    
    local scrollbar_fill = self:create("Frame", {
        Visible = true;
        BorderColor3 = rgb(0, 0, 0);
        AnchorPoint = vec2(1, 0);
        Position = dim2(1, 0, 0, 0);
        Parent = e;
        Size = dim2(0, 3, 1, 0);
        BorderSizePixel = 0;
        ZIndex = -1;
        BackgroundColor3 = rgb(46, 46, 46)
    }); self:apply_theme(scrollbar_fill, "c", "BackgroundColor3")
    
    self:create("UIPadding", {
        PaddingBottom = dim(0, 15);
        Parent = scrolling_frame
    });

    scrolling_frame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
        local is_scrollbar_visible = scrolling_frame.AbsoluteCanvasSize.Y < elements.AbsoluteSize.Y + 26
        scrollbar_fill.Visible = is_scrollbar_visible and true or false
    end)

    return setmetatable(cfg, self)
end

function VasaJas:label(options)
    local cfg = {name = options.name or "This is a textlabel"}

    local label = self:create("TextButton", {
        FontFace = self.font;
        TextColor3 = rgb(0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = self.elements;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 0, 10);
        BorderSizePixel = 0;
        TextSize = 14;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local toggle_text = self:create("TextLabel", {
        FontFace = self.font;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = label;
        AutomaticSize = Enum.AutomaticSize.XY;
        Position = dim2(0, 9, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        ZIndex = 2;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local right_components = self:create("Frame", {
        Parent = label;
        Position = dim2(1, -7, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.right_components = right_components
    
    self:create("UIListLayout", {
        Parent = right_components;
        Padding = dim(0, 4);
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        SortOrder = Enum.SortOrder.LayoutOrder
    });

    return setmetatable(cfg, self)
end

function VasaJas:toggle(options)
    local cfg = {
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        flag = options.flag or tostring(random(1,9999999)),
        default = options.value or options.default or false,
        folding = options.folding or false,
        callback = options.callback or function() end,
    }

    local toggle = self:create("TextButton", {
        FontFace = self.font;
        TextColor3 = rgb(0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = self.elements;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 0, 10);
        BorderSizePixel = 0;
        TextSize = 14;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local d = self:create("Frame", {
        Parent = toggle;
        Position = dim2(0, -1, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 10, 0, 10);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(12, 12, 12)
    }); self:apply_theme(d, "d", "BackgroundColor3")
    
    local f = self:create("Frame", {
        Parent = d;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(84, 84, 84)
    }); self:apply_theme(f, "f", "BackgroundColor3")
    
    local toggle_text = self:create("TextLabel", {
        FontFace = self.font;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = toggle;
        AutomaticSize = Enum.AutomaticSize.XY;
        Position = dim2(0, 15, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        ZIndex = 2;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local right_components = self:create("Frame", {
        Parent = toggle;
        Position = dim2(1, -7, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); cfg.right_components = right_components
    
    self:create("UIListLayout", {
        Parent = right_components;
        Padding = dim(0, 4);
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        SortOrder = Enum.SortOrder.LayoutOrder
    });

    local elements;
    if cfg.folding then
        elements = self:create("Frame", {
            Parent = self.elements;
            BackgroundTransparency = 1;
            Position = dim2(0, 4, 0, 21);
            Size = dim2(1, 0, 0, 0);
            BorderSizePixel = 0;
            AutomaticSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = rgb(255, 255, 255)
        }); cfg.elements = elements
        
        self:create("UIListLayout", {
            Parent = elements;
            Padding = dim(0, 7);
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder
        });
    end

    function cfg.set(bool)
        f.BackgroundColor3 = bool and themes.preset.accent or themes.preset.f
        cfg.callback(bool)
        if cfg.folding then
            elements.Visible = bool
        end
    end

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    toggle.MouseButton1Down:Connect(function()
        cfg.enabled = not cfg.enabled
        cfg.set(cfg.enabled)
    end)

    if self.is_mobile then
        toggle.TouchTap:Connect(function()
            cfg.enabled = not cfg.enabled
            cfg.set(cfg.enabled)
        end)
    end

    return setmetatable(cfg, self)
end

function VasaJas:slider(options)
    local cfg = {
        name = options.name or nil,
        suffix = options.suffix or "",
        flag = options.flag or tostring(2^789),
        callback = options.callback or function() end,
        min = options.min or options.minimum or 0,
        max = options.max or options.maximum or 100,
        intervals = options.interval or options.decimal or 1,
        default = options.value or options.default or 10,
        ignore = options.ignore or false,
        dragging = false,
    }

    local object = self:create("TextButton", {
        FontFace = self.font;
        TextColor3 = rgb(0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Text = "";
        Parent = self.elements;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 0, 32);
        BorderSizePixel = 0;
        TextSize = 14;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local toggle_text = self:create("TextLabel", {
        FontFace = self.font;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = object;
        AutomaticSize = Enum.AutomaticSize.XY;
        Position = dim2(0, 8, 0, 0);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        ZIndex = 2;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local slider_frame = self:create("TextButton", {
        Parent = object;
        Position = dim2(0, 8, 0, 16);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -14, 0, 8);
        AutoButtonColor = false;
        Text = "";
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(12, 12, 12)
    }); self:apply_theme(slider_frame, "d", "BackgroundColor3")
    
    local background = self:create("Frame", {
        Parent = slider_frame;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(56, 56, 56)
    }); self:apply_theme(background, "b", "BackgroundColor3")
    
    local fill = self:create("Frame", {
        Parent = background;
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0.5, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.accent
    }); self:apply_theme(fill, "accent", "BackgroundColor3")
    
    local output = self:create("TextLabel", {
        FontFace = self.font;
        Parent = fill;
        TextColor3 = rgb(255, 255, 255);
        BorderColor3 = rgb(0, 0, 0);
        Text = "50";
        AutomaticSize = Enum.AutomaticSize.XY;
        AnchorPoint = vec2(0.5, 0);
        Position = dim2(1, 0, 1, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        ZIndex = 2;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });
    
    local plus = self:create("ImageButton", {
        BorderColor3 = rgb(0, 0, 0);
        Parent = slider_frame;
        Image = "rbxassetid://126987373762224";
        BackgroundTransparency = 1;
        Position = dim2(1, -3, 0, 2);
        Size = dim2(0, 5, 0, 5);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); self:apply_theme(plus, "text", "BackgroundColor3")
    
    local minus = self:create("ImageButton", {
        AnchorPoint = vec2(1, 0);
        Parent = slider_frame;
        Position = dim2(0, -3, 0, 4);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 5, 0, 1);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255)
    }); self:apply_theme(minus, "text", "BackgroundColor3")

    function cfg.set(value)
        local valuee = tonumber(value)
        if valuee == nil then
            return
        end

        cfg.value = clamp(self:round(value, cfg.intervals), cfg.min, cfg.max)
        fill.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
        output.Text = tostring(cfg.value) .. cfg.suffix
        flags[cfg.flag] = cfg.value
        cfg.callback(flags[cfg.flag])
    end

    cfg.set(cfg.default)

    slider_frame.MouseButton1Down:Connect(function()
        cfg.dragging = true
    end)

    if self.is_mobile then
        slider_frame.TouchTap:Connect(function()
            cfg.dragging = true
        end)
    end

    minus.MouseButton1Down:Connect(function()
        cfg.value -= cfg.intervals
        cfg.set(cfg.value)
    end)

    plus.MouseButton1Down:Connect(function()
        cfg.value += cfg.intervals
        cfg.set(cfg.value)
    end)

    if self.is_mobile then
        minus.TouchTap:Connect(function()
            cfg.value -= cfg.intervals
            cfg.set(cfg.value)
        end)

        plus.TouchTap:Connect(function()
            cfg.value += cfg.intervals
            cfg.set(cfg.value)
        end)
    end

    self:connection(uis.InputChanged, function(input)
        if cfg.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or self:is_touch_input(input)) then
            local size_x = (input.Position.X - slider_frame.AbsolutePosition.X) / slider_frame.AbsoluteSize.X
            local value = ((cfg.max - cfg.min) * size_x) + cfg.min
            cfg.set(value)
        end
    end)

    self:connection(uis.InputEnded, function(input)
        if self:is_click_input(input) then
            cfg.dragging = false
        end
    end)

    cfg.set(cfg.default)
    config_flags[cfg.flag] = cfg.set

    return setmetatable(cfg, self)
end

function VasaJas:button(options)
    local cfg = {
        name = options.name or "Button",
        callback = options.callback or function() end,
    }

    local button = self:create("TextButton", {
        Parent = self.elements;
        Text = "";
        Position = dim2(0, 0, 0, 16);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, 0, 0, 20);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(12, 12, 12)
    }); self:apply_theme(button, "outline", "BackgroundColor3")
    
    local inline = self:create("Frame", {
        Parent = button;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.inline
    }); self:apply_theme(inline, "inline", "BackgroundColor3")
    
    local background = self:create("Frame", {
        Parent = inline;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = themes.preset.background
    }); self:apply_theme(background, "background", "BackgroundColor3")
    
    local text = self:create("TextButton", {
        FontFace = self.font;
        TextColor3 = rgb(170, 170, 170);
        BorderColor3 = rgb(0, 0, 0);
        Text = cfg.name;
        Parent = background;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        TextSize = 12;
        BackgroundColor3 = rgb(255, 255, 255)
    });

    text.MouseButton1Click:Connect(function()
        cfg.callback()
    end)

    if self.is_mobile then
        text.TouchTap:Connect(function()
            cfg.callback()
        end)
    end

    return setmetatable(cfg, self)
end

return VasaJas
