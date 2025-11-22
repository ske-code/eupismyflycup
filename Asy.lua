local AsyV2 = {}
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local HS = game:GetService("HttpService")

local clr = {
    outline = Color3.fromRGB(15,15,25),
    inline = Color3.fromRGB(35,35,45),
    accent = Color3.fromRGB(255,182,193),
    text = Color3.fromRGB(255,255,255),
    bg = Color3.fromRGB(25,25,35),
    section_bg = Color3.fromRGB(30,30,40),
    tab_inactive = Color3.fromRGB(50,50,65)
}

local function cr(cls,props)
    local obj=Instance.new(cls)
    for p,v in pairs(props) do obj[p]=v end
    return obj
end

local function tw(obj,props,dur)
    local ti=TweenInfo.new(dur or 0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    local t=TS:Create(obj,ti,props)
    t:Play()
    return t
end

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

AsyV2.font = Font.new(getcustomasset and getcustomasset("aui/fonts/main_encoded.ttf") or Enum.Font.Gotham, Enum.FontWeight.Regular)

function AsyV2:CreateWindow(opt)
    local win = {
        name = opt.name or "AsyV2",
        size = opt.size or UDim2.new(0,560,0,400)
    }
    
    local sg = cr("ScreenGui", {Name = "AsyV2", Parent = CG})
    local mf = cr("Frame", {
        Parent = sg, Size = win.size, Position = UDim2.new(0.5, -win.size.X.Offset/2, 0.5, -win.size.Y.Offset/2),
        BackgroundColor3 = clr.outline, BorderSizePixel = 0
    })
    local inf = cr("Frame", {
        Parent = mf, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = clr.inline, BorderSizePixel = 0
    })
    local bgf = cr("Frame", {
        Parent = inf, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = clr.bg, BorderSizePixel = 0
    })
    local tbc = cr("Frame", {
        Parent = bgf, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    })
    local tbl = cr("UIListLayout", {
        Parent = tbc, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10)
    })
    local pgc = cr("Frame", {
        Parent = bgf, Size = UDim2.new(1, -20, 1, -50), Position = UDim2.new(0, 10, 0, 50),
        BackgroundTransparency = 1
    })
    
    win.sg = sg; win.mf = mf; win.tbc = tbc; win.pgc = pgc; win.curTab = nil; win.tabs = {}
    
    local drag = false; local dragIn, dragSt, stPos
    
    local function handleInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragSt = input.Position; stPos = mf.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end
    
    bgf.InputBegan:Connect(handleInput)
    bgf.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragIn = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragIn and drag then
            local delta = input.Position - dragSt
            mf.Position = UDim2.new(stPos.X.Scale, stPos.X.Offset + delta.X, stPos.Y.Scale, stPos.Y.Offset + delta.Y)
        end
    end)
    
    function win:CreateTab(n)
        local tab = {name = n, win = self}
        
        local tbtn = cr("TextButton", {
            Parent = self.tbc, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = n,
            TextColor3 = clr.tab_inactive, TextSize = 12, FontFace = AsyV2.font, AutoButtonColor = false
        })
        tbtn.Size = UDim2.new(0, tbtn.TextBounds.X + 20, 1, 0)
        
        local underline = cr("Frame", {
            Parent = tbtn, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = clr.tab_inactive, BorderSizePixel = 0
        })
        
        local tpg = cr("Frame", {
            Parent = self.pgc, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false
        })
        
        local leftSide = cr("ScrollingFrame", {
            Parent = tpg, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
            ScrollBarImageColor3 = clr.accent, CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local rightSide = cr("ScrollingFrame", {
            Parent = tpg, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
            ScrollBarImageColor3 = clr.accent, CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local leftLayout = cr("UIListLayout", {Parent = leftSide, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        local rightLayout = cr("UIListLayout", {Parent = rightSide, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
        
        tab.tbtn = tbtn; tab.underline = underline; tab.tpg = tpg; tab.leftSide = leftSide; tab.rightSide = rightSide
        
        local function selectTab() self:SelectTab(tab) end
        tbtn.MouseButton1Click:Connect(selectTab)
        if UIS.TouchEnabled then tbtn.TouchTap:Connect(selectTab) end
        
        function tab:CreateSection(opt)
            local sec = {name = opt.name or "Section", tab = self, side = opt.side or "Left"}
            local container = sec.side == "Left" and self.leftSide or self.rightSide
            
            local sf = cr("Frame", {
                Parent = container, Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = clr.section_bg,
                BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y
            })
            local outline = cr("Frame", {Parent = sf, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
            local inline = cr("Frame", {
                Parent = outline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = clr.inline, BorderSizePixel = 0
            })
            local bg = cr("Frame", {
                Parent = inline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = clr.section_bg, BorderSizePixel = 0
            })
            local st = cr("TextLabel", {
                Parent = bg, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1, Text = sec.name, TextColor3 = clr.text, TextSize = 12,
                FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
            })
            local line = cr("Frame", {
                Parent = bg, Size = UDim2.new(1, -20, 0, 1), Position = UDim2.new(0, 10, 0, 25),
                BackgroundColor3 = clr.inline, BorderSizePixel = 0
            })
            local ec = cr("Frame", {
                Parent = bg, Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 35),
                BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y
            })
            local el = cr("UIListLayout", {Parent = ec, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})
            
            sec.sf = sf; sec.ec = ec
            
            function sec:CreateToggle(opt)
                local tog = {name = opt.name or "Toggle", def = opt.default or false, cb = opt.callback or function() end}
                local tf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1})
                local checkbox = cr("TextButton", {
                    Parent = tf, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 0, 0, 3),
                    BackgroundColor3 = tog.def and clr.accent or clr.bg, BorderSizePixel = 0, Text = "", AutoButtonColor = false
                })
                local outline = cr("Frame", {Parent = checkbox, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
                local inline = cr("Frame", {
                    Parent = outline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.inline, BorderSizePixel = 0
                })
                local bg = cr("Frame", {
                    Parent = inline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = tog.def and clr.accent or clr.bg, BorderSizePixel = 0
                })
                local tl = cr("TextLabel", {
                    Parent = tf, Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 20, 0, 0),
                    BackgroundTransparency = 1, Text = tog.name, TextColor3 = clr.text, TextSize = 12,
                    FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                function tog:Set(st)
                    tog.cb(st)
                    tw(checkbox, {BackgroundColor3 = st and clr.accent or clr.bg}, 0.2)
                    tw(bg, {BackgroundColor3 = st and clr.accent or clr.bg}, 0.2)
                end
                
                tog:Set(tog.def)
                
                local function toggleFunc()
                    tog:Set(not (checkbox.BackgroundColor3 == clr.accent))
                end
                
                checkbox.MouseButton1Click:Connect(toggleFunc)
                if UIS.TouchEnabled then checkbox.TouchTap:Connect(toggleFunc) end
                return setmetatable(tog, {__index = self})
            end
            
            function sec:CreateLabel(opt)
                local lbl = {text = opt.text or "Label"}
                local lf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1})
                local lt = cr("TextLabel", {
                    Parent = lf, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = lbl.text,
                    TextColor3 = clr.text, TextSize = 11, FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
                })
                return setmetatable(lbl, {__index = self})
            end
            
            function sec:CreateButton(opt)
                local btn = {name = opt.name or "Button", cb = opt.callback or function() end}
                local bf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1})
                local btnOutline = cr("Frame", {Parent = bf, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
                local btnInline = cr("Frame", {
                    Parent = btnOutline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.inline, BorderSizePixel = 0
                })
                local btnBg = cr("Frame", {
                    Parent = btnInline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.bg, BorderSizePixel = 0
                })
                local btnText = cr("TextButton", {
                    Parent = btnBg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = btn.name,
                    TextColor3 = clr.text, TextSize = 12, FontFace = AsyV2.font, BorderSizePixel = 0
                })
                local function buttonClick() btn.cb() end
                btnText.MouseButton1Click:Connect(buttonClick)
                if UIS.TouchEnabled then btnText.TouchTap:Connect(buttonClick) end
                btnText.MouseEnter:Connect(function() tw(btnBg, {BackgroundColor3 = clr.accent}, 0.2) end)
                btnText.MouseLeave:Connect(function() tw(btnBg, {BackgroundColor3 = clr.bg}, 0.2) end)
                return setmetatable(btn, {__index = self})
            end
            
            function sec:CreateSlider(opt)
                local sld = {name = opt.name or "Slider", min = opt.min or 0, max = opt.max or 100, def = opt.default or 50, cb = opt.callback or function() end}
                local sf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, 35), BackgroundTransparency = 1})
                local sl = cr("TextLabel", {
                    Parent = sf, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = sld.name,
                    TextColor3 = clr.text, TextSize = 12, FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
                })
                local trackOutline = cr("Frame", {
                    Parent = sf, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = clr.outline, BorderSizePixel = 0
                })
                local trackInline = cr("Frame", {
                    Parent = trackOutline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.inline, BorderSizePixel = 0
                })
                local trackBg = cr("Frame", {
                    Parent = trackInline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.bg, BorderSizePixel = 0
                })
                local fill = cr("Frame", {Parent = trackBg, Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = clr.accent, BorderSizePixel = 0})
                local val = cr("TextLabel", {
                    Parent = sf, Size = UDim2.new(0, 40, 0, 15), Position = UDim2.new(1, -40, 0, 0),
                    BackgroundTransparency = 1, Text = tostring(sld.def), TextColor3 = clr.text, TextSize = 11,
                    FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Right
                })
                local drag = false
                function sld:Set(v)
                    sld.cur = math.clamp(v, sld.min, sld.max)
                    local pct = (sld.cur - sld.min) / (sld.max - sld.min)
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    val.Text = tostring(sld.cur)
                    sld.cb(sld.cur)
                end
                sld:Set(sld.def)
                local function startDrag(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        drag = true
                    end
                end
                local function endDrag(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        drag = false
                    end
                end
                trackOutline.InputBegan:Connect(startDrag)
                trackOutline.InputEnded:Connect(endDrag)
                UIS.InputChanged:Connect(function(input)
                    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local x = (input.Position.X - trackOutline.AbsolutePosition.X) / trackOutline.AbsoluteSize.X
                        sld:Set(sld.min + (sld.max - sld.min) * x)
                    end
                end)
                return setmetatable(sld, {__index = self})
            end

            function sec:CreateList(opt)
                local lst = {
                    name = opt.name or "List", 
                    options = opt.options or {}, 
                    def = opt.default or "",
                    multiselect = opt.multiselect or false,
                    cb = opt.callback or function() end
                }
                local selectedOptions = {}
                if lst.def ~= "" then
                    if lst.multiselect and type(lst.def) == "table" then
                        selectedOptions = lst.def
                    else
                        selectedOptions = {lst.def}
                    end
                end
                
                local lf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, math.min(#lst.options * 25 + 25, 150)), BackgroundTransparency = 1})
                local lt = cr("TextLabel", {
                    Parent = lf, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = lst.name,
                    TextColor3 = clr.text, TextSize = 12, FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local listFrame = cr("Frame", {
                    Parent = lf, Size = UDim2.new(1, 0, 1, -20), Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = clr.bg, BorderSizePixel = 0
                })
                local outline = cr("Frame", {Parent = listFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
                local inline = cr("Frame", {
                    Parent = outline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.inline, BorderSizePixel = 0
                })
                local bg = cr("Frame", {
                    Parent = inline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.bg, BorderSizePixel = 0
                })
                
                local scrollFrame = cr("ScrollingFrame", {
                    Parent = bg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                    ScrollBarThickness = 4, ScrollBarImageColor3 = clr.accent,
                    CanvasSize = UDim2.new(0, 0, 0, #lst.options * 25)
                })
                local listLayout = cr("UIListLayout", {Parent = scrollFrame, SortOrder = Enum.SortOrder.LayoutOrder})
                
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
                                tw(btn, {BackgroundColor3 = clr.bg}, 0.2)
                            end
                        end
                    end
                    
                    local isSelected = table.find(selectedOptions, option) ~= nil
                    if isSelected then
                        tw(optionButtons[option], {BackgroundColor3 = clr.accent}, 0.2)
                    else
                        tw(optionButtons[option], {BackgroundColor3 = clr.bg}, 0.2)
                    end
                    
                    if lst.multiselect then
                        lst.cb(selectedOptions)
                    else
                        lst.cb(option)
                    end
                end
                
                for i, option in ipairs(lst.options) do
                    local optionBtn = cr("TextButton", {
                        Parent = scrollFrame, Size = UDim2.new(1, 0, 0, 20), 
                        BackgroundColor3 = table.find(selectedOptions, option) and clr.accent or clr.bg,
                        TextColor3 = clr.text, TextSize = 11, FontFace = AsyV2.font, Text = option,
                        AutoButtonColor = false
                    })
                    optionButtons[option] = optionBtn
                    
                    local function selectOption()
                        updateSelection(option)
                    end
                    
                    optionBtn.MouseButton1Click:Connect(selectOption)
                    if UIS.TouchEnabled then
                        optionBtn.TouchTap:Connect(selectOption)
                    end
                end
                
                return setmetatable(lst, {__index = self})
            end

            function sec:CreateTextbox(opt)
                local txt = {name = opt.name or "Textbox", def = opt.default or "", cb = opt.callback or function() end}
                local tf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
                local tl = cr("TextLabel", {
                    Parent = tf, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = txt.name,
                    TextColor3 = clr.text, TextSize = 12, FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
                })
                local textbox = cr("TextBox", {
                    Parent = tf, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = clr.bg, TextColor3 = clr.text, TextSize = 11, FontFace = AsyV2.font,
                    Text = txt.def, PlaceholderText = opt.placeholder or "Enter text..."
                })
                local outline = cr("Frame", {Parent = textbox, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
                local inline = cr("Frame", {
                    Parent = outline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.inline, BorderSizePixel = 0
                })
                local bg = cr("Frame", {
                    Parent = inline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.bg, BorderSizePixel = 0
                })
                
                textbox.FocusLost:Connect(function()
                    txt.cb(textbox.Text)
                end)
                
                return setmetatable(txt, {__index = self})
            end

            function sec:CreateColorpicker(opt)
                local clrp = {name = opt.name or "Colorpicker", def = opt.default or Color3.fromRGB(255,255,255), cb = opt.callback or function() end}
                local cf = cr("Frame", {Parent = self.ec, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
                local cl = cr("TextLabel", {
                    Parent = cf, Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = clrp.name,
                    TextColor3 = clr.text, TextSize = 12, FontFace = AsyV2.font, TextXAlignment = Enum.TextXAlignment.Left
                })
                local colorBtn = cr("TextButton", {
                    Parent = cf, Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = clrp.def, Text = "", AutoButtonColor = false
                })
                local outline = cr("Frame", {Parent = colorBtn, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
                local inline = cr("Frame", {
                    Parent = outline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clr.inline, BorderSizePixel = 0
                })
                local bg = cr("Frame", {
                    Parent = inline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3 = clrp.def, BorderSizePixel = 0
                })
                
                local colorPickerOpen = false
                local colorPickerFrame
                
                local function updateColor()
                    clrp.cb(clrp.def)
                    colorBtn.BackgroundColor3 = clrp.def
                    bg.BackgroundColor3 = clrp.def
                end
                
                local function createColorPicker()
                    if colorPickerOpen then return end
                    colorPickerOpen = true
                    
                    colorPickerFrame = cr("Frame", {
                        Parent = cf, Size = UDim2.new(0, 200, 0, 150), Position = UDim2.new(0, 0, 0, 45),
                        BackgroundColor3 = clr.bg, BorderSizePixel = 0
                    })
                    local colorOutline = cr("Frame", {Parent = colorPickerFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = clr.outline, BorderSizePixel = 0})
                    local colorInline = cr("Frame", {
                        Parent = colorOutline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                        BackgroundColor3 = clr.inline, BorderSizePixel = 0
                    })
                    local colorBg = cr("Frame", {
                        Parent = colorInline, Size = UDim2.new(1, -2, 1, -2), Position = UDim2.new(0, 1, 0, 1),
                        BackgroundColor3 = clr.bg, BorderSizePixel = 0
                    })
                    
                    local colorArea = cr("Frame", {
                        Parent = colorBg, Size = UDim2.new(0, 150, 0, 100), Position = UDim2.new(0, 10, 0, 10),
                        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0
                    })
                    local colorGradient = cr("UIGradient", {
                        Parent = colorArea,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                            ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
                        }
                    })
                    local colorPickerDot = cr("Frame", {
                        Parent = colorArea, Size = UDim2.new(0, 4, 0, 4), 
                        BackgroundColor3 = Color3.new(0,0,0), BorderSizePixel = 1, BorderColor3 = Color3.new(1,1,1)
                    })
                    
                    local hueSlider = cr("Frame", {
                        Parent = colorBg, Size = UDim2.new(0, 20, 0, 100), Position = UDim2.new(0, 170, 0, 10),
                        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0
                    })
                    local hueGradient = cr("UIGradient", {
                        Parent = hueSlider,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                        },
                        Rotation = 90
                    })
                    local huePickerDot = cr("Frame", {
                        Parent = hueSlider, Size = UDim2.new(1, 0, 0, 2),
                        BackgroundColor3 = Color3.new(0,0,0), BorderSizePixel = 1, BorderColor3 = Color3.new(1,1,1)
                    })
                    
                    local closeBtn = cr("TextButton", {
                        Parent = colorBg, Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(0, 70, 0, 120),
                        BackgroundColor3 = clr.accent, TextColor3 = clr.text, TextSize = 11, FontFace = AsyV2.font,
                        Text = "Close", AutoButtonColor = false
                    })
                    
                    local currentHue = 0
                    local currentSat = 0.5
                    local currentVal = 0.5
                    
                    local function HSVToRGB(h, s, v)
                        local r, g, b
                        local i = math.floor(h * 6)
                        local f = h * 6 - i
                        local p = v * (1 - s)
                        local q = v * (1 - f * s)
                        local t = v * (1 - (1 - f) * s)
                        
                        i = i % 6
                        
                        if i == 0 then r, g, b = v, t, p
                        elseif i == 1 then r, g, b = q, v, p
                        elseif i == 2 then r, g, b = p, v, t
                        elseif i == 3 then r, g, b = p, q, v
                        elseif i == 4 then r, g, b = t, p, v
                        elseif i == 5 then r, g, b = v, p, q
                        end
                        
                        return Color3.new(r, g, b)
                    end
                    
                    local function updateGradient()
                        colorGradient.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                            ColorSequenceKeypoint.new(1, HSVToRGB(currentHue, 1, 1))
                        }
                    end
                    
                    local function setColorFromArea(x, y)
                        currentSat = math.clamp(x, 0, 1)
                        currentVal = 1 - math.clamp(y, 0, 1)
                        clrp.def = HSVToRGB(currentHue, currentSat, currentVal)
                        colorPickerDot.Position = UDim2.new(currentSat, -2, 1 - currentVal, -2)
                        updateColor()
                    end
                    
                    local function setHue(y)
                        currentHue = 1 - math.clamp(y, 0, 1)
                        updateGradient()
                        huePickerDot.Position = UDim2.new(0, 0, 1 - currentHue, -1)
                        clrp.def = HSVToRGB(currentHue, currentSat, currentVal)
                        updateColor()
                    end
                    
                    local function handleColorInput(input, isTouch)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or (isTouch and input.UserInputType == Enum.UserInputType.Touch) then
                            local x = (input.Position.X - colorArea.AbsolutePosition.X) / colorArea.AbsoluteSize.X
                            local y = (input.Position.Y - colorArea.AbsolutePosition.Y) / colorArea.AbsoluteSize.Y
                            setColorFromArea(x, y)
                            return true
                        end
                        return false
                    end
                    
                    local function handleHueInput(input, isTouch)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or (isTouch and input.UserInputType == Enum.UserInputType.Touch) then
                            local y = (input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y
                            setHue(y)
                            return true
                        end
                        return false
                    end
                    
                    colorArea.InputBegan:Connect(function(input)
                        handleColorInput(input, false)
                    end)
                    
                    hueSlider.InputBegan:Connect(function(input)
                        handleHueInput(input, false)
                    end)
                    
                    if UIS.TouchEnabled then
                        colorArea.TouchTap:Connect(function(input)
                            handleColorInput(input, true)
                        end)
                        
                        hueSlider.TouchTap:Connect(function(input)
                            handleHueInput(input, true)
                        end)
                    end
                    
                    UIS.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if colorArea:IsMouseOver() then
                                local x = (input.Position.X - colorArea.AbsolutePosition.X) / colorArea.AbsoluteSize.X
                                local y = (input.Position.Y - colorArea.AbsolutePosition.Y) / colorArea.AbsoluteSize.Y
                                setColorFromArea(x, y)
                            elseif hueSlider:IsMouseOver() then
                                local y = (input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y
                                setHue(y)
                            end
                        end
                    end)
                    
                    closeBtn.MouseButton1Click:Connect(function()
                        colorPickerFrame:Destroy()
                        colorPickerOpen = false
                    end)
                    
                    if UIS.TouchEnabled then
                        closeBtn.TouchTap:Connect(function()
                            colorPickerFrame:Destroy()
                            colorPickerOpen = false
                        end)
                    end
                    
                    updateGradient()
                    updateColor()
                    setHue(0.5)
                    setColorFromArea(0.5, 0.5)
                end
                
                colorBtn.MouseButton1Click:Connect(createColorPicker)
                if UIS.TouchEnabled then
                    colorBtn.TouchTap:Connect(createColorPicker)
                end
                
                return setmetatable(clrp, {__index = self})
            end
            
            return setmetatable(sec, {__index = self})
        end
        
        function win:SelectTab(t)
            if self.curTab then
                self.curTab.tpg.Visible = false
                tw(self.curTab.tbtn, {TextColor3 = clr.tab_inactive}, 0.2)
                tw(self.curTab.underline, {BackgroundColor3 = clr.tab_inactive}, 0.2)
            end
            self.curTab = t
            t.tpg.Visible = true
            tw(t.tbtn, {TextColor3 = clr.accent}, 0.2)
            tw(t.underline, {BackgroundColor3 = clr.accent}, 0.2)
        end
        
        if not self.curTab then self:SelectTab(tab) end
        table.insert(self.tabs, tab)
        return setmetatable(tab, {__index = self})
    end
    return setmetatable(win, {__index = self})
end

return AsyV2
         
