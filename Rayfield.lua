--[[
    RobloxUI Library
    A comprehensive UI library for Roblox with advanced features
    Inspired by Rayfield
]]

local RobloxUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration
RobloxUI.Config = {
    WindowName = "RobloxUI Library",
    Color = Color3.fromRGB(64, 157, 255),
    Keybind = Enum.KeyCode.RightShift,
    KeySystem = true,
    KeySettings = {
        Title = "Key System",
        Subtitle = "Key Required",
        Note = "Get your key from our Discord server",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"DEMO1234", "TEST5678"}, -- Multiple keys supported
        FileName = "RobloxUIKey", -- For saved keys
    }
}

-- Utility Functions
local function Create(instance, properties)
    local obj = Instance.new(instance)
    for i, v in pairs(properties or {}) do
        obj[i] = v
    end
    return obj
end

local function Tween(instance, properties, duration, ...)
    local tween = TweenService:Create(instance, TweenInfo.new(duration, ...), properties)
    tween:Play()
    return tween
end

local function DarkenColor(color, percent)
    return Color3.new(
        math.clamp(color.R - percent, 0, 1),
        math.clamp(color.G - percent, 0, 1),
        math.clamp(color.B - percent, 0, 1)
    )
end

local function LightenColor(color, percent)
    return Color3.new(
        math.clamp(color.R + percent, 0, 1),
        math.clamp(color.G + percent, 0, 1),
        math.clamp(color.B + percent, 0, 1)
    )
end

-- Key System
function RobloxUI:ValidateKey(key)
    if not self.Config.KeySystem then
        return true
    end
    
    -- Check if key is in the list of valid keys
    for _, validKey in ipairs(self.Config.KeySettings.Key) do
        if key == validKey then
            return true
        end
    end
    
    -- Check if key is saved and valid
    if self.Config.KeySettings.SaveKey then
        local savedKey = self:GetSavedKey()
        if savedKey and self:ValidateKey(savedKey) then
            return true
        end
    end
    
    return false
end

function RobloxUI:SaveKey(key)
    if self.Config.KeySettings.SaveKey then
        local json = HttpService:JSONEncode({key = key})
        writefile(self.Config.KeySettings.FileName .. ".txt", json)
    end
end

function RobloxUI:GetSavedKey()
    if self.Config.KeySettings.SaveKey and isfile(self.Config.KeySettings.FileName .. ".txt") then
        local json = readfile(self.Config.KeySettings.FileName .. ".txt")
        local data = HttpService:JSONDecode(json)
        return data.key
    end
    return nil
end

function RobloxUI:CreateKeySystem()
    if not self.Config.KeySystem then
        return true
    end
    
    -- Check for saved key first
    if self.Config.KeySettings.SaveKey then
        local savedKey = self:GetSavedKey()
        if savedKey and self:ValidateKey(savedKey) then
            return true
        end
    end
    
    -- Create key system UI
    local KeySystemUI = Create("ScreenGui", {
        Name = "KeySystem",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local Main = Create("Frame", {
        Name = "Main",
        Parent = KeySystemUI,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -150, 0.5, -100),
        Size = UDim2.new(0, 300, 0, 200),
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    
    local UICorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = Main
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = self.Config.KeySettings.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22
    })
    
    local Subtitle = Create("TextLabel", {
        Name = "Subtitle",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = self.Config.KeySettings.Subtitle,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 16
    })
    
    local Note = Create("TextLabel", {
        Name = "Note",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = self.Config.KeySettings.Note,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 14
    })
    
    local KeyInput = Create("TextBox", {
        Name = "KeyInput",
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Position = UDim2.new(0.5, -125, 0, 90),
        Size = UDim2.new(0, 250, 0, 35),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter Key...",
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        ClearTextOnFocus = false
    })
    
    local UICornerInput = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = KeyInput
    })
    
    local SubmitButton = Create("TextButton", {
        Name = "SubmitButton",
        Parent = Main,
        BackgroundColor3 = self.Config.Color,
        Position = UDim2.new(0.5, -75, 0, 140),
        Size = UDim2.new(0, 150, 0, 35),
        Font = Enum.Font.GothamBold,
        Text = "Submit",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        AutoButtonColor = false
    })
    
    local UICornerButton = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = SubmitButton
    })
    
    -- Button hover effect
    SubmitButton.MouseEnter:Connect(function()
        Tween(SubmitButton, {BackgroundColor3 = DarkenColor(self.Config.Color, 0.1)}, 0.3)
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        Tween(SubmitButton, {BackgroundColor3 = self.Config.Color}, 0.3)
    end)
    
    -- Key validation
    local keyValidated = false
    
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        
        if self:ValidateKey(key) then
            keyValidated = true
            self:SaveKey(key)
            Tween(Main, {Position = UDim2.new(0.5, -150, 1.5, 0)}, 0.5, Enum.EasingStyle.Quint)
            wait(0.5)
            KeySystemUI:Destroy()
        else
            Tween(KeyInput, {BackgroundColor3 = Color3.fromRGB(255, 75, 75)}, 0.3)
            wait(0.3)
            Tween(KeyInput, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.3)
        end
    end)
    
    -- Wait for key validation
    repeat wait() until keyValidated
    return true
end

-- UI Components
function RobloxUI:CreateWindow()
    if self.Config.KeySystem and not self:CreateKeySystem() then
        return
    end
    
    local RobloxUILibrary = {}
    
    -- Main GUI
    local MainGUI = Create("ScreenGui", {
        Name = "RobloxUI",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local Main = Create("Frame", {
        Name = "Main",
        Parent = MainGUI,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -175),
        Size = UDim2.new(0, 600, 0, 350),
        ClipsDescendants = true
    })
    
    local UICorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = Main
    })
    
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local UICornerTopBar = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = TopBar
    })
    
    local TopBarFix = Create("Frame", {
        Name = "TopBarFix",
        Parent = TopBar,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0.5, 0)
    })
    
    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Config.WindowName,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    
    local MinimizeButton = Create("TextButton", {
        Name = "MinimizeButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20
    })
    
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 150, 1, -30)
    })
    
    local UICornerTabContainer = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = TabContainer
    })
    
    local TabContainerFix = Create("Frame", {
        Name = "TabContainerFix",
        Parent = TabContainer,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -5, 0, 0),
        Size = UDim2.new(0, 5, 1, 0)
    })
    
    local TabScroll = Create("ScrollingFrame", {
        Name = "TabScroll",
        Parent = TabContainer,
        Active = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0
    })
    
    local TabList = Create("UIListLayout", {
        Parent = TabScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })
    
    local TabPadding = Create("UIPadding", {
        Parent = TabScroll,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 30),
        Size = UDim2.new(1, -150, 1, -30),
        ClipsDescendants = true
    })
    
    -- Make UI draggable
    local dragging, dragInput, dragStart, startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Close and minimize functionality
    local minimized = false
    
    CloseButton.MouseButton1Click:Connect(function()
        MainGUI:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, {Size = UDim2.new(0, 600, 0, 30)}, 0.5, Enum.EasingStyle.Quint)
        else
            Tween(Main, {Size = UDim2.new(0, 600, 0, 350)}, 0.5, Enum.EasingStyle.Quint)
        end
    end)
    
    -- Keybind to toggle UI
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Config.Keybind then
            MainGUI.Enabled = not MainGUI.Enabled
        end
    end)
    
    -- Tab system
    local Tabs = {}
    local firstTab = true
    
    function RobloxUILibrary:CreateTab(name, icon)
        local Tab = {}
        
        -- Tab button
        local TabButton = Create("TextButton", {
            Name = name .. "Tab",
            Parent = TabScroll,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            AutoButtonColor = false
        })
        
        local UICornerTabButton = Create("UICorner", {
            CornerRadius = UDim.new(0, 5),
            Parent = TabButton
        })
        
        if icon then
            local IconImage = Create("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = icon
            })
            
            TabButton.Text = "   " .. name
            TabButton.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        -- Tab content
        local TabContent = Create("ScrollingFrame", {
            Name = name .. "Content",
            Parent = ContentContainer,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self.Config.Color,
            Visible = firstTab
        })

        local ContentList = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- Update canvas size when elements are added
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab button functionality
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.TabContent.Visible = false
                Tween(tab.TabButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.3)
            end
            TabContent.Visible = true
            Tween(TabButton, {BackgroundColor3 = self.Config.Color}, 0.3)
        end)
        
        -- Hover effect
        TabButton.MouseEnter:Connect(function()
            if not TabContent.Visible then
                Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.3)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not TabContent.Visible then
                Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.3)
            end
        end)
        
        -- Set first tab as active
        if firstTab then
            Tween(TabButton, {BackgroundColor3 = self.Config.Color}, 0.3)
            firstTab = false
        end
        
        -- Store tab data
        table.insert(Tabs, {
            TabButton = TabButton,
            TabContent = TabContent
        })
        
        -- Section system
        function Tab:CreateSection(title)
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Name = title .. "Section",
                Parent = TabContent,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Size = UDim2.new(1, 0, 0, 40), -- Will be resized based on content
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local UICornerSection = Create("UICorner", {
                CornerRadius = UDim.new(0, 5),
                Parent = SectionFrame
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SectionContent = Create("Frame", {
                Name = "Content",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local SectionList = Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            local SectionPadding = Create("UIPadding", {
                Parent = SectionContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })
            
            -- Button component
            function Section:CreateButton(options)
                options = options or {}
                options.Name = options.Name or "Button"
                options.Callback = options.Callback or function() end
                
                local ButtonFrame = Create("Frame", {
                    Name = options.Name .. "Button",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local Button = Create("TextButton", {
                    Name = "Button",
                    Parent = ButtonFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    AutoButtonColor = false
                })
                
                local UICornerButton = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = Button
                })
                
                -- Button functionality
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = self.Config.Color}, 0.2)
                    options.Callback()
                    wait(0.2)
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.2)
                end)
                
                -- Hover effect
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.3)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.3)
                end)
                
                return Button
            end
            
            -- Toggle component
            function Section:CreateToggle(options)
                options = options or {}
                options.Name = options.Name or "Toggle"
                options.Default = options.Default or false
                options.Callback = options.Callback or function() end
                
                local ToggleFrame = Create("Frame", {
                    Name = options.Name .. "Toggle",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                    BorderSizePixel = 0
                })
                
                local UICornerToggle = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0
                })
                
                local UICornerCircle = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })
                
                -- Toggle state
                local Toggled = options.Default
                
                local function UpdateToggle()
                    if Toggled then
                        Tween(ToggleButton, {BackgroundColor3 = self.Config.Color}, 0.3)
                        Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.3)
                    else
                        Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.3)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.3)
                    end
                    options.Callback(Toggled)
                end
                
                -- Set default state
                UpdateToggle()
                
                -- Toggle functionality
                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggled = not Toggled
                        UpdateToggle()
                    end
                end)
                
                ToggleCircle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Toggled = not Toggled
                        UpdateToggle()
                    end
                end)
                
                -- API
                local ToggleAPI = {}
                
                function ToggleAPI:Set(value)
                    Toggled = value
                    UpdateToggle()
                end
                
                return ToggleAPI
            end
            
            -- Slider component
            function Section:CreateSlider(options)
                options = options or {}
                options.Name = options.Name or "Slider"
                options.Min = options.Min or 0
                options.Max = options.Max or 100
                options.Default = options.Default or options.Min
                options.Increment = options.Increment or 1
                options.Callback = options.Callback or function() end
                
                local SliderFrame = Create("Frame", {
                    Name = options.Name .. "Slider",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValue = Create("TextLabel", {
                    Name = "Value",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 0),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(options.Default),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBackground = Create("Frame", {
                    Name = "Background",
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 10)
                })
                
                local UICornerSlider = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBackground
                })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBackground,
                    BackgroundColor3 = self.Config.Color,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                
                local UICornerFill = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                
                local SliderCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = SliderFill,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    BorderSizePixel = 0,
                    ZIndex = 2
                })
                
                local UICornerCircle = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderCircle
                })
                
                -- Slider functionality
                local function UpdateSlider(value)
                    value = math.clamp(value, options.Min, options.Max)
                    value = math.floor(value / options.Increment + 0.5) * options.Increment
                    value = math.clamp(value, options.Min, options.Max) -- Clamp again after rounding
                    
                    -- Calculate the percentage for UI
                    local percent = (value - options.Min) / (options.Max - options.Min)
                    
                    -- Update UI
                    SliderValue.Text = tostring(value)
                    SliderFill:TweenSize(UDim2.new(percent, 0, 1, 0), "Out", "Quad", 0.1, true)
                    
                    -- Callback
                    options.Callback(value)
                end
                
                -- Set default value
                UpdateSlider(options.Default)
                
                -- Slider interaction
                local dragging = false
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        
                        -- Calculate value based on mouse position
                        local percent = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                        local value = options.Min + (options.Max - options.Min) * percent
                        
                        UpdateSlider(value)
                    end
                end)
                
                SliderBackground.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        -- Calculate value based on mouse position
                        local percent = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                        local value = options.Min + (options.Max - options.Min) * percent
                        
                        UpdateSlider(value)
                    end
                end)
                
                -- API
                local SliderAPI = {}
                
                function SliderAPI:Set(value)
                    UpdateSlider(value)
                end
                
                return SliderAPI
            end
            
            -- Dropdown component
            function Section:CreateDropdown(options)
                options = options or {}
                options.Name = options.Name or "Dropdown"
                options.Options = options.Options or {}
                options.Default = options.Default or nil
                options.Callback = options.Callback or function() end
                
                local DropdownFrame = Create("Frame", {
                    Name = options.Name .. "Dropdown",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40),
                    ClipsDescendants = true
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = options.Default or "Select...",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    AutoButtonColor = false
                })
                
                local UIPadding = Create("UIPadding", {
                    Parent = DropdownButton,
                    PaddingLeft = UDim.new(0, 10)
                })
                
                local UICornerDropdown = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = DropdownButton
                })
                
                local DropdownIcon = Create("TextLabel", {
                    Name = "Icon",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "▼",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12
                })
                
                local DropdownContent = Create("Frame", {
                    Name = "Content",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Position = UDim2.new(0, 0, 0, 55),
                    Size = UDim2.new(1, 0, 0, 0), -- Will be resized based on options
                    Visible = false,
                    ZIndex = 2
                })
                
                local UICornerContent = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = DropdownContent
                })
                
                local ContentList = Create("UIListLayout", {
                    Parent = DropdownContent,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                -- Create option buttons
                for i, option in ipairs(options.Options) do
                    local OptionButton = Create("TextButton", {
                        Name = option,
                        Parent = DropdownContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 14,
                        ZIndex = 2
                    })
                    
                    local OptionPadding = Create("UIPadding", {
                        Parent = OptionButton,
                        PaddingLeft = UDim.new(0, 10)
                    })
                    
                    -- Option button functionality
                    OptionButton.MouseButton1Click:Connect(function()
                        DropdownButton.Text = option
                        options.Callback(option)
                        
                        -- Close dropdown
                        DropdownContent.Visible = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                        Tween(DropdownIcon, {Rotation = 0}, 0.3)
                    end)
                    
                    -- Hover effect
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 0.8, BackgroundColor3 = self.Config.Color}, 0.3)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundTransparency = 1}, 0.3)
                    end)
                end
                
                -- Update content size based on options
                DropdownContent.Size = UDim2.new(1, 0, 0, #options.Options * 25)
                
                -- Dropdown functionality
                local dropdownOpen = false
                
                DropdownButton.MouseButton1Click:Connect(function()
                    dropdownOpen = not dropdownOpen
                    
                    if dropdownOpen then
                        DropdownContent.Visible = true
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 60 + DropdownContent.Size.Y.Offset)}, 0.3)
                        Tween(DropdownIcon, {Rotation = 180}, 0.3)
                    else
                        DropdownContent.Visible = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                        Tween(DropdownIcon, {Rotation = 0}, 0.3)
                    end
                end)
                
                -- Hover effect
                DropdownButton.MouseEnter:Connect(function()
                    Tween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.3)
                end)
                
                DropdownButton.MouseLeave:Connect(function()
                    Tween(DropdownButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.3)
                end)
                
                -- Set default value
                if options.Default then
                    options.Callback(options.Default)
                end
                
                -- API
                local DropdownAPI = {}
                
                function DropdownAPI:Set(option)
                    if table.find(options.Options, option) then
                        DropdownButton.Text = option
                        options.Callback(option)
                    end
                end
                
                function DropdownAPI:Refresh(newOptions, newDefault)
                    -- Clear existing options
                    for _, child in ipairs(DropdownContent:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Update options
                    options.Options = newOptions or options.Options
                    
                    -- Create new option buttons
                    for i, option in ipairs(options.Options) do
                        local OptionButton = Create("TextButton", {
                            Name = option,
                            Parent = DropdownContent,
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 25),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 14,
                            ZIndex = 2
                        })
                        
                        local OptionPadding = Create("UIPadding", {
                            Parent = OptionButton,
                            PaddingLeft = UDim.new(0, 10)
                        })
                        
                        -- Option button functionality
                        OptionButton.MouseButton1Click:Connect(function()
                            DropdownButton.Text = option
                            options.Callback(option)
                            
                            -- Close dropdown
                            DropdownContent.Visible = false
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                            Tween(DropdownIcon, {Rotation = 0}, 0.3)
                        end)
                        
                        -- Hover effect
                        OptionButton.MouseEnter:Connect(function()
                            Tween(OptionButton, {BackgroundTransparency = 0.8, BackgroundColor3 = self.Config.Color}, 0.3)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Tween(OptionButton, {BackgroundTransparency = 1}, 0.3)
                        end)
                    end
                    
                    -- Update content size
                    DropdownContent.Size = UDim2.new(1, 0, 0, #options.Options * 25)
                    
                    -- Set new default
                    if newDefault then
                        DropdownButton.Text = newDefault
                        options.Callback(newDefault)
                    end
                end
                
                return DropdownAPI
            end
            
            -- Textbox component
            function Section:CreateTextbox(options)
                options = options or {}
                options.Name = options.Name or "Textbox"
                options.Default = options.Default or ""
                options.PlaceholderText = options.PlaceholderText or "Enter text..."
                options.ClearOnFocus = options.ClearOnFocus ~= nil and options.ClearOnFocus or true
                options.Callback = options.Callback or function() end
                
                local TextboxFrame = Create("Frame", {
                    Name = options.Name .. "Textbox",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = TextboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Textbox = Create("TextBox", {
                    Name = "Input",
                    Parent = TextboxFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = options.Default,
                    PlaceholderText = options.PlaceholderText,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = options.ClearOnFocus
                })
                
                local UIPadding = Create("UIPadding", {
                    Parent = Textbox,
                    PaddingLeft = UDim.new(0, 10)
                })
                
                local UICornerTextbox = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = Textbox
                })
                
                -- Textbox functionality
                Textbox.FocusLost:Connect(function(enterPressed)
                    options.Callback(Textbox.Text)
                end)
                
                -- Hover effect
                Textbox.MouseEnter:Connect(function()
                    Tween(Textbox, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.3)
                end)
                
                Textbox.MouseLeave:Connect(function()
                    Tween(Textbox, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.3)
                end)
                
                -- API
                local TextboxAPI = {}
                
                function TextboxAPI:Set(text)
                    Textbox.Text = text
                    options.Callback(text)
                end
                
                return TextboxAPI
            end
            
            -- Label component
            function Section:CreateLabel(options)
                options = options or {}
                options.Text = options.Text or "Label"
                options.Color = options.Color or Color3.fromRGB(255, 255, 255)
                
                local LabelFrame = Create("Frame", {
                    Name = "Label",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                
                local Label = Create("TextLabel", {
                    Name = "Text",
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = options.Text,
                    TextColor3 = options.Color,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true
                })
                
                -- API
                local LabelAPI = {}
                
                function LabelAPI:Set(text, color)
                    Label.Text = text or Label.Text
                    Label.TextColor3 = color or Label.TextColor3
                    
                    -- Adjust frame height based on text wrap
                    Label.Size = UDim2.new(1, 0, 0, 0)
                    Label.AutomaticSize = Enum.AutomaticSize.Y
                    LabelFrame.Size = UDim2.new(1, 0, 0, 0)
                    LabelFrame.AutomaticSize = Enum.AutomaticSize.Y
                end
                
                return LabelAPI
            end
            
            -- Colorpicker component
            function Section:CreateColorPicker(options)
                options = options or {}
                options.Name = options.Name or "Color Picker"
                options.Default = options.Default or Color3.fromRGB(255, 255, 255)
                options.Callback = options.Callback or function() end
                
                local ColorPickerFrame = Create("Frame", {
                    Name = options.Name .. "ColorPicker",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local ColorPickerLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = ColorPickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorDisplay = Create("Frame", {
                    Name = "ColorDisplay",
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = options.Default,
                    Position = UDim2.new(1, -30, 0.5, -10),
                    Size = UDim2.new(0, 30, 0, 20),
                    BorderSizePixel = 0
                })
                
                local UICornerDisplay = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = ColorDisplay
                })
                
                -- Color picker popup
                local ColorPickerPopup = Create("Frame", {
                    Name = "ColorPickerPopup",
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    Position = UDim2.new(1, -200, 1, 10),
                    Size = UDim2.new(0, 200, 0, 220),
                    Visible = false,
                    ZIndex = 10
                })

                local UICornerPopup = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = ColorPickerPopup
                })
                
                local ColorWheel = Create("ImageLabel", {
                    Name = "ColorWheel",
                    Parent = ColorPickerPopup,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, -75, 0, 10),
                    Size = UDim2.new(0, 150, 0, 150),
                    Image = "rbxassetid://4155801252",
                    ZIndex = 10
                })
                
                local ColorWheelPicker = Create("Frame", {
                    Name = "Picker",
                    Parent = ColorWheel,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 11
                })
                
                local UICornerPicker = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ColorWheelPicker
                })
                
                local DarknessSlider = Create("Frame", {
                    Name = "DarknessSlider",
                    Parent = ColorPickerPopup,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0.5, -75, 0, 170),
                    Size = UDim2.new(0, 150, 0, 15),
                    ZIndex = 10
                })
                
                local UIGradient = Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                    }),
                    Parent = DarknessSlider
                })
                
                local UICornerSlider = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = DarknessSlider
                })
                
                local DarknessPicker = Create("Frame", {
                    Name = "Picker",
                    Parent = DarknessSlider,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 5, 1, 0),
                    ZIndex = 11
                })
                
                local UICornerDarkness = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = DarknessPicker
                })
                
                local ConfirmButton = Create("TextButton", {
                    Name = "Confirm",
                    Parent = ColorPickerPopup,
                    BackgroundColor3 = self.Config.Color,
                    Position = UDim2.new(0.5, -50, 0, 195),
                    Size = UDim2.new(0, 100, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = "Confirm",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    ZIndex = 10
                })
                
                local UICornerConfirm = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = ConfirmButton
                })
                
                -- Color picker functionality
                local function UpdateColor()
                    local hue, saturation, value
                    
                    -- Get hue and saturation from color wheel
                    local centerX, centerY = ColorWheel.AbsolutePosition.X + ColorWheel.AbsoluteSize.X/2, ColorWheel.AbsolutePosition.Y + ColorWheel.AbsoluteSize.Y/2
                    local pickerX, pickerY = ColorWheelPicker.AbsolutePosition.X + ColorWheelPicker.AbsoluteSize.X/2, ColorWheelPicker.AbsolutePosition.Y + ColorWheelPicker.AbsoluteSize.Y/2
                    local radius = ColorWheel.AbsoluteSize.X/2
                    
                    local deltaX, deltaY = pickerX - centerX, pickerY - centerY
                    local distance = math.sqrt(deltaX^2 + deltaY^2)
                    
                    if distance > radius then
                        distance = radius
                        local angle = math.atan2(deltaY, deltaX)
                        ColorWheelPicker.Position = UDim2.new(0.5, math.cos(angle) * radius, 0.5, math.sin(angle) * radius)
                    end
                    
                    saturation = distance / radius
                    hue = (math.atan2(deltaY, deltaX) + math.pi) / (2 * math.pi)
                    
                    -- Get value from darkness slider
                    local sliderWidth = DarknessSlider.AbsoluteSize.X
                    local pickerPos = DarknessPicker.AbsolutePosition.X - DarknessSlider.AbsolutePosition.X
                    value = 1 - (pickerPos / sliderWidth)
                    
                    -- Convert HSV to RGB
                    local color = Color3.fromHSV(hue, saturation, value)
                    
                    -- Update color display
                    ColorDisplay.BackgroundColor3 = color
                    
                    -- Update darkness slider gradient
                    UIGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, saturation, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, saturation, 0))
                    })
                    
                    return color
                end
                
                -- Color wheel interaction
                local wheelDragging = false
                
                ColorWheel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        wheelDragging = true
                        
                        -- Update picker position
                        local mousePos = Vector2.new(input.Position.X, input.Position.Y)
                        local centerPos = Vector2.new(
                            ColorWheel.AbsolutePosition.X + ColorWheel.AbsoluteSize.X/2,
                            ColorWheel.AbsolutePosition.Y + ColorWheel.AbsoluteSize.Y/2
                        )
                        local radius = ColorWheel.AbsoluteSize.X/2
                        local delta = mousePos - centerPos
                        local distance = delta.Magnitude
                        
                        if distance > radius then
                            delta = delta.Unit * radius
                        end
                        
                        ColorWheelPicker.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
                        
                        -- Update color
                        UpdateColor()
                    end
                end)
                
                ColorWheel.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        wheelDragging = false
                    end
                end)
                
                -- Darkness slider interaction
                local sliderDragging = false
                
                DarknessSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = true
                        
                        -- Update picker position
                        local mousePos = input.Position.X
                        local sliderPos = DarknessSlider.AbsolutePosition.X
                        local sliderWidth = DarknessSlider.AbsoluteSize.X
                        local position = math.clamp(mousePos - sliderPos, 0, sliderWidth)
                        
                        DarknessPicker.Position = UDim2.new(0, position, 0.5, 0)
                        
                        -- Update color
                        UpdateColor()
                    end
                end)
                
                DarknessSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = false
                    end
                end)
                
                -- Mouse movement
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if wheelDragging then
                            -- Update picker position
                            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
                            local centerPos = Vector2.new(
                                ColorWheel.AbsolutePosition.X + ColorWheel.AbsoluteSize.X/2,
                                ColorWheel.AbsolutePosition.Y + ColorWheel.AbsoluteSize.Y/2
                            )
                            local radius = ColorWheel.AbsoluteSize.X/2
                            local delta = mousePos - centerPos
                            local distance = delta.Magnitude
                            
                            if distance > radius then
                                delta = delta.Unit * radius
                            end
                            
                            ColorWheelPicker.Position = UDim2.new(0.5, delta.X, 0.5, delta.Y)
                            
                            -- Update color
                            UpdateColor()
                        elseif sliderDragging then
                            -- Update picker position
                            local mousePos = input.Position.X
                            local sliderPos = DarknessSlider.AbsolutePosition.X
                            local sliderWidth = DarknessSlider.AbsoluteSize.X
                            local position = math.clamp(mousePos - sliderPos, 0, sliderWidth)
                            
                            DarknessPicker.Position = UDim2.new(0, position, 0.5, 0)
                            
                            -- Update color
                            UpdateColor()
                        end
                    end
                end)
                
                -- Toggle color picker popup
                ColorDisplay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        ColorPickerPopup.Visible = not ColorPickerPopup.Visible
                    end
                end)
                
                -- Confirm button
                ConfirmButton.MouseButton1Click:Connect(function()
                    local color = UpdateColor()
                    options.Callback(color)
                    ColorPickerPopup.Visible = false
                end)
                
                -- Set default color
                local h, s, v = Color3.toHSV(options.Default)
                local radius = ColorWheel.AbsoluteSize.X/2
                local angle = h * (2 * math.pi)
                local distance = s * radius
                
                ColorWheelPicker.Position = UDim2.new(0.5, math.cos(angle - math.pi) * distance, 0.5, math.sin(angle - math.pi) * distance)
                DarknessPicker.Position = UDim2.new(1 - v, 0, 0.5, 0)
                
                ColorDisplay.BackgroundColor3 = options.Default
                options.Callback(options.Default)
                
                -- API
                local ColorPickerAPI = {}
                
                function ColorPickerAPI:Set(color)
                    ColorDisplay.BackgroundColor3 = color
                    options.Callback(color)
                    
                    -- Update UI
                    local h, s, v = Color3.toHSV(color)
                    local radius = ColorWheel.AbsoluteSize.X/2
                    local angle = h * (2 * math.pi)
                    local distance = s * radius
                    
                    ColorWheelPicker.Position = UDim2.new(0.5, math.cos(angle - math.pi) * distance, 0.5, math.sin(angle - math.pi) * distance)
                    DarknessPicker.Position = UDim2.new(1 - v, 0, 0.5, 0)
                    
                    UIGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 0))
                    })
                end
                
                return ColorPickerAPI
            end
            
            -- Keybind component
            function Section:CreateKeybind(options)
                options = options or {}
                options.Name = options.Name or "Keybind"
                options.Default = options.Default or Enum.KeyCode.Unknown
                options.Callback = options.Callback or function() end
                
                local KeybindFrame = Create("Frame", {
                    Name = options.Name .. "Keybind",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = options.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    Parent = KeybindFrame,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Position = UDim2.new(1, -70, 0.5, -12),
                    Size = UDim2.new(0, 70, 0, 24),
                    Font = Enum.Font.Gotham,
                    Text = options.Default.Name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    AutoButtonColor = false
                })
                
                local UICornerKeybind = Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                    Parent = KeybindButton
                })
                
                -- Keybind functionality
                local listening = false
                local currentKey = options.Default
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        currentKey = input.KeyCode
                        KeybindButton.Text = currentKey.Name
                        options.Callback(currentKey)
                    elseif not listening and input.KeyCode == currentKey then
                        options.Callback(currentKey)
                    end
                end)
                
                -- Hover effect
                KeybindButton.MouseEnter:Connect(function()
                    Tween(KeybindButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.3)
                end)
                
                KeybindButton.MouseLeave:Connect(function()
                    Tween(KeybindButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.3)
                end)
                
                -- API
                local KeybindAPI = {}
                
                function KeybindAPI:Set(key)
                    currentKey = key
                    KeybindButton.Text = key.Name
                    options.Callback(key)
                end
                
                return KeybindAPI
            end
            
            return Section
        end
        
        return Tab
    end
    
    return RobloxUILibrary
end

return RobloxUI
