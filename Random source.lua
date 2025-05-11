--[[
    Advanced Roblox UI Library
    Created by v0
    
    Features:
    - Modern, sleek design
    - Customizable themes
    - Draggable windows
    - Multiple UI components (buttons, toggles, sliders, etc.)
    - Key authentication system
    - Notifications
]]

-- Key System Configuration
local ValidKeys = {
    "DEMO-KEY-12345",
    "PREMIUM-KEY-67890",
    "TEST-KEY-ABCDE"
}

-- Library Main Module
local Library = {}
Library.__index = Library

-- UI Variables
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = nil
local Tabs = {}
local CurrentTab = nil
local Dragging = false
local DragStart = nil
local StartPos = nil

-- Theme Configuration
Library.Themes = {
    Default = {
        BackgroundColor = Color3.fromRGB(30, 30, 30),
        SecondaryColor = Color3.fromRGB(40, 40, 40),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(50, 50, 50)
    },
    Dark = {
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        SecondaryColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(255, 70, 70),
        TextColor = Color3.fromRGB(240, 240, 240),
        ElementColor = Color3.fromRGB(40, 40, 40)
    },
    Light = {
        BackgroundColor = Color3.fromRGB(230, 230, 230),
        SecondaryColor = Color3.fromRGB(210, 210, 210),
        AccentColor = Color3.fromRGB(0, 120, 215),
        TextColor = Color3.fromRGB(40, 40, 40),
        ElementColor = Color3.fromRGB(190, 190, 190)
    },
    Contrast = {
        BackgroundColor = Color3.fromRGB(10, 10, 15),
        SecondaryColor = Color3.fromRGB(20, 20, 30),
        AccentColor = Color3.fromRGB(130, 70, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(30, 30, 45)
    }
}

-- Current Theme
Library.CurrentTheme = Library.Themes.Default

-- Utility Functions
local function CreateInstance(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame)
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function UpdateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            UpdateInput(input)
        end
    end)
end

-- Notification System
function Library:Notify(title, message, duration)
    duration = duration or 3
    
    local NotificationFrame = CreateInstance("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 250, 0, 80),
        Position = UDim2.new(1, -260, 1, -90),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = NotificationFrame
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.CurrentTheme.AccentColor,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationFrame
    })
    
    local MessageLabel = CreateInstance("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -10, 0, 40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotificationFrame
    })
    
    -- Animation
    NotificationFrame.Position = UDim2.new(1, 0, 1, -90)
    Tween(NotificationFrame, {Position = UDim2.new(1, -260, 1, -90)}, 0.3)
    
    -- Auto close
    task.delay(duration, function()
        Tween(NotificationFrame, {Position = UDim2.new(1, 0, 1, -90)}, 0.3).Completed:Connect(function()
            NotificationFrame:Destroy()
        end)
    end)
    
    return NotificationFrame
end

-- Key Authentication
function Library:VerifyKey(key)
    for _, validKey in ipairs(ValidKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- Create Key System UI
function Library:CreateKeySystem(callback)
    local KeyFrame = CreateInstance("Frame", {
        Name = "KeySystem",
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, -150, 0.5, -75),
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = KeyFrame
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "Key Authentication",
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = KeyFrame
    })
    
    local KeyInput = CreateInstance("TextBox", {
        Name = "KeyInput",
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = self.CurrentTheme.ElementColor,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Enter your key...",
        TextColor3 = self.CurrentTheme.TextColor,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = KeyFrame
    })
    
    local UICornerInput = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = KeyInput
    })
    
    local SubmitButton = CreateInstance("TextButton", {
        Name = "SubmitButton",
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 95),
        BackgroundColor3 = self.CurrentTheme.AccentColor,
        BorderSizePixel = 0,
        Text = "Submit",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = KeyFrame
    })
    
    local UICornerButton = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = SubmitButton
    })
    
    -- Make draggable
    MakeDraggable(KeyFrame)
    
    -- Button functionality
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if self:VerifyKey(key) then
            self:Notify("Success", "Key verified successfully!", 3)
            KeyFrame:Destroy()
            if callback then
                callback(true, key)
            end
        else
            self:Notify("Error", "Invalid key. Please try again.", 3)
            if callback then
                callback(false, key)
            end
        end
    end)
    
    return KeyFrame
end

-- Create Main UI
function Library:CreateWindow(title, size)
    size = size or {x = 500, y = 350}
    
    -- Main Frame
    MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, size.x, 0, size.y),
        Position = UDim2.new(0.5, -size.x/2, 0.5, -size.y/2),
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    local TitleCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TitleBar
    })
    
    -- Fix corner overlap
    local CornerFix = CreateInstance("Frame", {
        Name = "CornerFix",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = TitleBar
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Close Button
    local CloseButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -27, 0, 3),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    local TabContainerCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TabContainer
    })
    
    -- Fix corner overlap
    local TabCornerFix = CreateInstance("Frame", {
        Name = "TabCornerFix",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = TabContainer
    })
    
    -- Tab Content Container
    local TabContentContainer = CreateInstance("Frame", {
        Name = "TabContentContainer",
        Size = UDim2.new(1, -130, 1, -40),
        Position = UDim2.new(0, 125, 0, 35),
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    -- Tab Buttons Container
    local TabButtonsContainer = CreateInstance("ScrollingFrame", {
        Name = "TabButtonsContainer",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = TabContainer
    })
    
    local TabButtonLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabButtonsContainer
    })
    
    -- Make window draggable
    MakeDraggable(TitleBar)
    
    -- Window object
    local Window = {}
    Window.Tabs = {}
    
    -- Create Tab function
    function Window:CreateTab(name, icon)
        icon = icon or ""
        
        -- Tab Button
        local TabButton = CreateInstance("TextButton", {
            Name = name .. "Button",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = self.Tabs[name] and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Library.CurrentTheme.TextColor,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = TabButtonsContainer
        })
        
        local TabButtonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
            Parent = TabContentContainer
        })
        
        local ContentLayout = CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        local ContentPadding = CreateInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabContent
        })
        
        -- Tab object
        local Tab = {}
        Tab.Name = name
        Tab.Content = TabContent
        
        -- Button click handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
            end
            
            -- Reset all tab buttons
            for _, button in pairs(TabButtonsContainer:GetChildren()) do
                if button:IsA("TextButton") then
                    button.BackgroundColor3 = Library.CurrentTheme.ElementColor
                end
            end
            
            -- Show selected tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Library.CurrentTheme.AccentColor
        end)
        
        -- Create Section function
        function Tab:CreateSection(title)
            local SectionFrame = CreateInstance("Frame", {
                Name = title .. "Section",
                Size = UDim2.new(1, 0, 0, 30), -- Will be resized based on content
                BackgroundColor3 = Library.CurrentTheme.SecondaryColor,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabContent
            })

            local SectionCorner = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = SectionFrame
            })
            
            local SectionTitle = CreateInstance("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -10, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Library.CurrentTheme.TextColor,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            local SectionContent = CreateInstance("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            
            local ContentLayout = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            -- Section object
            local Section = {}
            
            -- Create Label function
            function Section:CreateLabel(text)
                local LabelFrame = CreateInstance("Frame", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = LabelFrame
                })
                
                local LabelObj = {}
                
                function LabelObj:Update(newText)
                    Label.Text = newText
                end
                
                return LabelObj
            end
            
            -- Create Button function
            function Section:CreateButton(text, callback)
                local ButtonFrame = CreateInstance("Frame", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local Button = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = ButtonFrame
                })
                
                local ButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Button
                })
                
                -- Button click animation
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = Library.CurrentTheme.AccentColor}, 0.1).Completed:Connect(function()
                        Tween(Button, {BackgroundColor3 = Library.CurrentTheme.ElementColor}, 0.1)
                    end)
                    
                    if callback then
                        callback()
                    end
                end)
                
                local ButtonObj = {}
                
                function ButtonObj:Update(newText)
                    Button.Text = newText
                end
                
                return ButtonObj
    --[[
    Advanced Roblox UI Library
    Created by v0
    
    Features:
    - Modern, sleek design
    - Customizable themes
    - Draggable windows
    - Multiple UI components (buttons, toggles, sliders, etc.)
    - Key authentication system
    - Notifications
]]

-- Key System Configuration
local ValidKeys = {
    "DEMO-KEY-12345",
    "PREMIUM-KEY-67890",
    "TEST-KEY-ABCDE"
}

-- Library Main Module
local Library = {}
Library.__index = Library

-- UI Variables
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = nil
local Tabs = {}
local CurrentTab = nil
local Dragging = false
local DragStart = nil
local StartPos = nil

-- Theme Configuration
Library.Themes = {
    Default = {
        BackgroundColor = Color3.fromRGB(30, 30, 30),
        SecondaryColor = Color3.fromRGB(40, 40, 40),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(50, 50, 50)
    },
    Dark = {
        BackgroundColor = Color3.fromRGB(20, 20, 20),
        SecondaryColor = Color3.fromRGB(30, 30, 30),
        AccentColor = Color3.fromRGB(255, 70, 70),
        TextColor = Color3.fromRGB(240, 240, 240),
        ElementColor = Color3.fromRGB(40, 40, 40)
    },
    Light = {
        BackgroundColor = Color3.fromRGB(230, 230, 230),
        SecondaryColor = Color3.fromRGB(210, 210, 210),
        AccentColor = Color3.fromRGB(0, 120, 215),
        TextColor = Color3.fromRGB(40, 40, 40),
        ElementColor = Color3.fromRGB(190, 190, 190)
    },
    Contrast = {
        BackgroundColor = Color3.fromRGB(10, 10, 15),
        SecondaryColor = Color3.fromRGB(20, 20, 30),
        AccentColor = Color3.fromRGB(130, 70, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(30, 30, 45)
    }
}

-- Current Theme
Library.CurrentTheme = Library.Themes.Default

-- Utility Functions
local function CreateInstance(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame)
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function UpdateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            UpdateInput(input)
        end
    end)
end

-- Notification System
function Library:Notify(title, message, duration)
    duration = duration or 3
    
    local NotificationFrame = CreateInstance("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 250, 0, 80),
        Position = UDim2.new(1, -260, 1, -90),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = NotificationFrame
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.CurrentTheme.AccentColor,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = NotificationFrame
    })
    
    local MessageLabel = CreateInstance("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -10, 0, 40),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = NotificationFrame
    })
    
    -- Animation
    NotificationFrame.Position = UDim2.new(1, 0, 1, -90)
    Tween(NotificationFrame, {Position = UDim2.new(1, -260, 1, -90)}, 0.3)
    
    -- Auto close
    task.delay(duration, function()
        Tween(NotificationFrame, {Position = UDim2.new(1, 0, 1, -90)}, 0.3).Completed:Connect(function()
            NotificationFrame:Destroy()
        end)
    end)
    
    return NotificationFrame
end

-- Key Authentication
function Library:VerifyKey(key)
    for _, validKey in ipairs(ValidKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- Create Key System UI
function Library:CreateKeySystem(callback)
    local KeyFrame = CreateInstance("Frame", {
        Name = "KeySystem",
        Size = UDim2.new(0, 300, 0, 150),
        Position = UDim2.new(0.5, -150, 0.5, -75),
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = KeyFrame
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "Key Authentication",
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = KeyFrame
    })
    
    local KeyInput = CreateInstance("TextBox", {
        Name = "KeyInput",
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = self.CurrentTheme.ElementColor,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Enter your key...",
        TextColor3 = self.CurrentTheme.TextColor,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        Parent = KeyFrame
    })
    
    local UICornerInput = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = KeyInput
    })
    
    local SubmitButton = CreateInstance("TextButton", {
        Name = "SubmitButton",
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 10, 0, 95),
        BackgroundColor3 = self.CurrentTheme.AccentColor,
        BorderSizePixel = 0,
        Text = "Submit",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = KeyFrame
    })
    
    local UICornerButton = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = SubmitButton
    })
    
    -- Make draggable
    MakeDraggable(KeyFrame)
    
    -- Button functionality
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if self:VerifyKey(key) then
            self:Notify("Success", "Key verified successfully!", 3)
            KeyFrame:Destroy()
            if callback then
                callback(true, key)
            end
        else
            self:Notify("Error", "Invalid key. Please try again.", 3)
            if callback then
                callback(false, key)
            end
        end
    end)
    
    return KeyFrame
end

-- Create Main UI
function Library:CreateWindow(title, size)
    size = size or {x = 500, y = 350}
    
    -- Main Frame
    MainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, size.x, 0, size.y),
        Position = UDim2.new(0.5, -size.x/2, 0.5, -size.y/2),
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = MainFrame
    })
    
    -- Title Bar
    local TitleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    local TitleCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TitleBar
    })
    
    -- Fix corner overlap
    local CornerFix = CreateInstance("Frame", {
        Name = "CornerFix",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = TitleBar
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })
    
    -- Close Button
    local CloseButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -27, 0, 3),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = self.CurrentTheme.TextColor,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Container
    local TabContainer = CreateInstance("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    local TabContainerCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TabContainer
    })
    
    -- Fix corner overlap
    local TabCornerFix = CreateInstance("Frame", {
        Name = "TabCornerFix",
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundColor3 = self.CurrentTheme.SecondaryColor,
        BorderSizePixel = 0,
        Parent = TabContainer
    })
    
    -- Tab Content Container
    local TabContentContainer = CreateInstance("Frame", {
        Name = "TabContentContainer",
        Size = UDim2.new(1, -130, 1, -40),
        Position = UDim2.new(0, 125, 0, 35),
        BackgroundColor3 = self.CurrentTheme.BackgroundColor,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })

    -- Tab Buttons Container
    local TabButtonsContainer = CreateInstance("ScrollingFrame", {
        Name = "TabButtonsContainer",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = TabContainer
    })
    
    local TabButtonLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabButtonsContainer
    })
    
    -- Make window draggable
    MakeDraggable(TitleBar)
    
    -- Window object
    local Window = {}
    Window.Tabs = {}
    
    -- Create Tab function
    function Window:CreateTab(name, icon)
        icon = icon or ""
        
        -- Tab Button
        local TabButton = CreateInstance("TextButton", {
            Name = name .. "Button",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = self.Tabs[name] and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Library.CurrentTheme.TextColor,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = TabButtonsContainer
        })
        
        local TabButtonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
            Parent = TabContentContainer
        })
        
        local ContentLayout = CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        local ContentPadding = CreateInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = TabContent
        })
        
        -- Tab object
        local Tab = {}
        Tab.Name = name
        Tab.Content = TabContent
        
        -- Button click handler
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
            end
            
            -- Reset all tab buttons
            for _, button in pairs(TabButtonsContainer:GetChildren()) do
                if button:IsA("TextButton") then
                    button.BackgroundColor3 = Library.CurrentTheme.ElementColor
                end
            end
            
            -- Show selected tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Library.CurrentTheme.AccentColor
        end)
        
        -- Create Section function
        function Tab:CreateSection(title)
            local SectionFrame = CreateInstance("Frame", {
                Name = title .. "Section",
                Size = UDim2.new(1, 0, 0, 30), -- Will be resized based on content
                BackgroundColor3 = Library.CurrentTheme.SecondaryColor,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = TabContent
            })
            
            local SectionCorner = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = SectionFrame
            })
            
            local SectionTitle = CreateInstance("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -10, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Library.CurrentTheme.TextColor,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            local SectionContent = CreateInstance("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = SectionFrame
            })
            
            local ContentLayout = CreateInstance("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            -- Section object
            local Section = {}
            
            -- Create Label function
            function Section:CreateLabel(text)
                local LabelFrame = CreateInstance("Frame", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local Label = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = LabelFrame
                })
                
                local LabelObj = {}
                
                function LabelObj:Update(newText)
                    Label.Text = newText
                end
                
                return LabelObj
            end
            
            -- Create Button function
            function Section:CreateButton(text, callback)
                local ButtonFrame = CreateInstance("Frame", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local Button = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = ButtonFrame
                })
                
                local ButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Button
                })
                
                -- Button click animation
                Button.MouseButton1Click:Connect(function()
                    Tween(Button, {BackgroundColor3 = Library.CurrentTheme.AccentColor}, 0.1).Completed:Connect(function()
                        Tween(Button, {BackgroundColor3 = Library.CurrentTheme.ElementColor}, 0.1)
                    end)
                    
                    if callback then
                        callback()
                    end
                end)
                
                local ButtonObj = {}
                
                function ButtonObj:Update(newText)
                    Button.Text = newText
                end
                
                return ButtonObj
            end
            
            -- Create Toggle function
            function Section:CreateToggle(text, default, callback)
                local ToggleFrame = CreateInstance("Frame", {
                    Name = "Toggle",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ToggleLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleButton = CreateInstance("Frame", {
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    BackgroundColor3 = default and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    Parent = ToggleFrame
                })
                
                local ToggleCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })
                
                local ToggleCircle = CreateInstance("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(default and 0.6 or 0.1, 0, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = ToggleButton
                })
                
                local ToggleCircleCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })
                
                local Toggled = default or false
                
                local function UpdateToggle()
                    Toggled = not Toggled
                    Tween(ToggleCircle, {Position = Toggled and UDim2.new(0.6, 0, 0.5, -8) or UDim2.new(0.1, 0, 0.5, -8)}, 0.1)
                    Tween(ToggleButton, {BackgroundColor3 = Toggled and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor}, 0.1)
                    
                    if callback then
                        callback(Toggled)
                    end
                end
                
                ToggleButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        UpdateToggle()
                    end
                end)
                
                local ToggleObj = {}
                
                function ToggleObj:Update(newText)
                    ToggleLabel.Text = newText
                end
                
                function ToggleObj:SetValue(value)
                    if value ~= Toggled then
                        UpdateToggle()
                    end
                end
                
                function ToggleObj:GetValue()
                    return Toggled
                end
                
                return ToggleObj
            end
            
            -- Create Slider function
            function Section:CreateSlider(text, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = default or min
                
                local SliderFrame = CreateInstance("Frame", {
                    Name = "Slider",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local SliderLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local SliderValue = CreateInstance("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -50, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBackground = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 10),
                    Position = UDim2.new(0, 0, 0, 30),
                    BackgroundColor3 = Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    Parent = SliderFrame
                })
                
                local SliderBackgroundCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBackground
                })
                
                local SliderFill = CreateInstance("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.CurrentTheme.AccentColor,
                    BorderSizePixel = 0,
                    Parent = SliderBackground
                })
                
                local SliderFillCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                
                local SliderButton = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = SliderBackground
                })
                
                local Value = default
                
                local function UpdateSlider(input)
                    local pos = UDim2.new(math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1), 0, 1, 0)
                    SliderFill.Size = pos
                    
                    local value = math.floor(min + ((max - min) * pos.X.Scale))
                    Value = value
                    SliderValue.Text = tostring(value)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        UpdateSlider(input)
                        local connection
                        connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                UpdateSlider(input)
                            end
                        end)
                        
                        game:GetService("UserInputService").InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                if connection then
                                    connection:Disconnect()
                                end
                            end
                        end)
                    end
                end)
                
                local SliderObj = {}
                
                function SliderObj:Update(newText)
                    SliderLabel.Text = newText
                end
                
                function SliderObj:SetValue(value)
                    value = math.clamp(value, min, max)
                    Value = value
                    SliderValue.Text = tostring(value)
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    
                    if callback then
                        callback(value)
                    end
                end
                
                function SliderObj:GetValue()
                    return Value
                end
                
                return SliderObj
            end
            
            -- Create Dropdown function
            function Section:CreateDropdown(text, options, default, callback)
                options = options or {}
                default = default or options[1]
                
                local DropdownFrame = CreateInstance("Frame", {
                    Name = "Dropdown",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local DropdownLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 25),
                    BackgroundColor3 = Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    Text = default or "Select...",
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownFrame
                })
                
                local DropdownCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton
                })
                
                local DropdownIcon = CreateInstance("TextLabel", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0.5, -10),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = DropdownButton
                })
                
                local DropdownContent = CreateInstance("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 60),
                    BackgroundColor3 = Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = DropdownFrame
                })

                local DropdownContentCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownContent
                })
                
                local DropdownOptionsList = CreateInstance("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ScrollBarThickness = 2,
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Parent = DropdownContent
                })
                
                local OptionsLayout = CreateInstance("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownOptionsList
                })
                
                local OptionsPadding = CreateInstance("UIPadding", {
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5),
                    Parent = DropdownOptionsList
                })
                
                local DropdownOpen = false
                local SelectedOption = default
                
                -- Create option buttons
                for i, option in ipairs(options) do
                    local OptionButton = CreateInstance("TextButton", {
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundColor3 = option == default and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor,
                        BorderSizePixel = 0,
                        Text = option,
                        TextColor3 = Library.CurrentTheme.TextColor,
                        TextSize = 14,
                        Font = Enum.Font.Gotham,
                        Parent = DropdownOptionsList
                    })
                    
                    local OptionCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionButton
                    })
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        SelectedOption = option
                        DropdownButton.Text = option
                        
                        -- Update selected option appearance
                        for _, child in pairs(DropdownOptionsList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.BackgroundColor3 = child.Text == option and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor
                            end
                        end
                        
                        -- Close dropdown
                        DropdownOpen = false
                        Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, 0)}, 0.1).Completed:Connect(function()
                            DropdownContent.Visible = false
                        end)
                        
                        if callback then
                            callback(option)
                        end
                    end)
                end
                
                -- Toggle dropdown
                DropdownButton.MouseButton1Click:Connect(function()
                    DropdownOpen = not DropdownOpen
                    
                    if DropdownOpen then
                        DropdownContent.Visible = true
                        local optionsHeight = math.min(150, #options * 30)
                        Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, optionsHeight)}, 0.1)
                        DropdownIcon.Text = "▲"
                    else
                        Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, 0)}, 0.1).Completed:Connect(function()
                            DropdownContent.Visible = false
                        end)
                        DropdownIcon.Text = "▼"
                    end
                end)
                
                -- Update dropdown frame size
                DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
                
                local DropdownObj = {}
                
                function DropdownObj:Update(newText)
                    DropdownLabel.Text = newText
                end
                
                function DropdownObj:SetValue(value)
                    if table.find(options, value) then
                        SelectedOption = value
                        DropdownButton.Text = value
                        
                        -- Update selected option appearance
                        for _, child in pairs(DropdownOptionsList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.BackgroundColor3 = child.Text == value and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor
                            end
                        end
                        
                        if callback then
                            callback(value)
                        end
                    end
                end
                
                function DropdownObj:GetValue()
                    return SelectedOption
                end
                
                function DropdownObj:SetOptions(newOptions)
                    options = newOptions
                    
                    -- Clear existing options
                    for _, child in pairs(DropdownOptionsList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Create new option buttons
                    for i, option in ipairs(options) do
                        local OptionButton = CreateInstance("TextButton", {
                            Size = UDim2.new(1, 0, 0, 25),
                            BackgroundColor3 = option == SelectedOption and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor,
                            BorderSizePixel = 0,
                            Text = option,
                            TextColor3 = Library.CurrentTheme.TextColor,
                            TextSize = 14,
                            Font = Enum.Font.Gotham,
                            Parent = DropdownOptionsList
                        })
                        
                        local OptionCorner = CreateInstance("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = OptionButton
                        })
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            SelectedOption = option
                            DropdownButton.Text = option
                            
                            -- Update selected option appearance
                            for _, child in pairs(DropdownOptionsList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child.BackgroundColor3 = child.Text == option and Library.CurrentTheme.AccentColor or Library.CurrentTheme.ElementColor
                                end
                            end
                            
                            -- Close dropdown
                            DropdownOpen = false
                            Tween(DropdownContent, {Size = UDim2.new(1, 0, 0, 0)}, 0.1).Completed:Connect(function()
                                DropdownContent.Visible = false
                            end)
                            
                            if callback then
                                callback(option)
                            end
                        end)
                    end
                    
                    -- Reset selected option if it's not in the new options
                    if not table.find(options, SelectedOption) and #options > 0 then
                        self:SetValue(options[1])
                    elseif #options == 0 then
                        SelectedOption = nil
                        DropdownButton.Text = "Select..."
                    end
                end
                
                return DropdownObj
            end
            
            -- Create ColorPicker function
            function Section:CreateColorPicker(text, default, callback)
                default = default or Color3.fromRGB(255, 255, 255)
                
                local ColorPickerFrame = CreateInstance("Frame", {
                    Name = "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ColorPickerLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorPickerFrame
                })
                
                local ColorDisplay = CreateInstance("Frame", {
                    Size = UDim2.new(0, 30, 0, 30),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Parent = ColorPickerFrame
                })
                
                local ColorDisplayCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorDisplay
                })
                
                local ColorPickerButton = CreateInstance("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = ColorDisplay
                })
                
                local ColorPickerContent = CreateInstance("Frame", {
                    Size = UDim2.new(0, 200, 0, 200),
                    Position = UDim2.new(1, -200, 1, 10),
                    BackgroundColor3 = Library.CurrentTheme.SecondaryColor,
                    BorderSizePixel = 0,
                    Visible = false,
                    Parent = ColorPickerFrame
                })
                
                local ColorPickerContentCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorPickerContent
                })
                
                -- Color picker implementation (simplified for this example)
                local ColorPickerOpen = false
                local SelectedColor = default
                
                ColorPickerButton.MouseButton1Click:Connect(function()
                    ColorPickerOpen = not ColorPickerOpen
                    ColorPickerContent.Visible = ColorPickerOpen
                end)
                
                -- Close color picker when clicking outside
                game:GetService("UserInputService").InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorPickerOpen then
                        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                        local pickerPos = ColorPickerContent.AbsolutePosition
                        local pickerSize = ColorPickerContent.AbsoluteSize
                        
                        if mousePos.X < pickerPos.X or mousePos.X > pickerPos.X + pickerSize.X or
                           mousePos.Y < pickerPos.Y or mousePos.Y > pickerPos.Y + pickerSize.Y then
                            if not (mousePos.X >= ColorDisplay.AbsolutePosition.X and
                                   mousePos.X <= ColorDisplay.AbsolutePosition.X + ColorDisplay.AbsoluteSize.X and
                                   mousePos.Y >= ColorDisplay.AbsolutePosition.Y and
                                   mousePos.Y <= ColorDisplay.AbsolutePosition.Y + ColorDisplay.AbsoluteSize.Y) then
                                ColorPickerOpen = false
                                ColorPickerContent.Visible = false
                            end
                        end
                    end
                end)
                
                -- Simplified color picker (just RGB sliders for this example)
                local function CreateColorSlider(color, defaultValue, parent)
                    local ColorSlider = CreateInstance("Frame", {
                        Size = UDim2.new(1, -20, 0, 20),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                        BorderSizePixel = 0,
                        Parent = parent
                    })
                    
                    local ColorSliderCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ColorSlider
                    })
                    
                    local ColorSliderFill = CreateInstance("Frame", {
                        Size = UDim2.new(defaultValue/255, 0, 1, 0),
                        BackgroundColor3 = Color3.fromRGB(
                            color == "R" and 255 or 0,
                            color == "G" and 255 or 0,
                            color == "B" and 255 or 0
                        ),
                        BorderSizePixel = 0,
                        Parent = ColorSlider
                    })
                    
                    local ColorSliderFillCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = ColorSliderFill
                    })
                    
                    local ColorSliderButton = CreateInstance("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = ColorSlider
                    })
                    
                    local ColorLabel = CreateInstance("TextLabel", {
                        Size = UDim2.new(0, 20, 1, 0),
                        Position = UDim2.new(0, -25, 0, 0),
                        BackgroundTransparency = 1,
                        Text = color,
                        TextColor3 = Library.CurrentTheme.TextColor,
                        TextSize = 14,
                        Font = Enum.Font.GothamBold,
                        Parent = ColorSlider
                    })
                    
                    local Value = defaultValue
                    
                    local function UpdateSlider(input)
                        local pos = UDim2.new(math.clamp((input.Position.X - ColorSlider.AbsolutePosition.X) / ColorSlider.AbsoluteSize.X, 0, 1), 0, 1, 0)
                        ColorSliderFill.Size = pos
                        
                        Value = math.floor(pos.X.Scale * 255)
                        
                        -- Update selected color
                        if color == "R" then
                            SelectedColor = Color3.fromRGB(Value, SelectedColor.G * 255, SelectedColor.B * 255)
                        elseif color == "G" then
                            SelectedColor = Color3.fromRGB(SelectedColor.R * 255, Value, SelectedColor.B * 255)
                        elseif color == "B" then
                            SelectedColor = Color3.fromRGB(SelectedColor.R * 255, SelectedColor.G * 255, Value)
                        end
                        
                        ColorDisplay.BackgroundColor3 = SelectedColor
                        
                        if callback then
                            callback(SelectedColor)
                        end
                    end
                    
                    ColorSliderButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            UpdateSlider(input)
                            local connection
                            connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseMovement then
                                    UpdateSlider(input)
                                end
                            end)
                            
                            game:GetService("UserInputService").InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    if connection then
                                        connection:Disconnect()
                                    end
                                end
                            end)
                        end
                    end)
                    
                    return ColorSlider
                end
                
                local RSlider = CreateColorSlider("R", default.R * 255, ColorPickerContent)
                RSlider.Position = UDim2.new(0, 10, 0, 20)
                
                local GSlider = CreateColorSlider("G", default.G * 255, ColorPickerContent)
                GSlider.Position = UDim2.new(0, 10, 0, 50)
                
                local BSlider = CreateColorSlider("B", default.B * 255, ColorPickerContent)
                BSlider.Position = UDim2.new(0, 10, 0, 80)
                
                local ApplyButton = CreateInstance("TextButton", {
                    Size = UDim2.new(1, -20, 0, 30),
                    Position = UDim2.new(0, 10, 0, 120),
                    BackgroundColor3 = Library.CurrentTheme.AccentColor,
                    BorderSizePixel = 0,
                    Text = "Apply",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    Parent = ColorPickerContent
                })
                
                local ApplyButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ApplyButton
                })
                
                ApplyButton.MouseButton1Click:Connect(function()
                    ColorPickerOpen = false
                    ColorPickerContent.Visible = false
                    
                    if callback then
                        callback(SelectedColor)
                    end
                end)
                
                local ColorPickerObj = {}
                
                function ColorPickerObj:Update(newText)
                    ColorPickerLabel.Text = newText
                end
                
                function ColorPickerObj:SetValue(color)
                    SelectedColor = color
                    ColorDisplay.BackgroundColor3 = color
                    
                    if callback then
                        callback(color)
                    end
                end
                
                function ColorPickerObj:GetValue()
                    return SelectedColor
                end
                
                return ColorPickerObj
            end
            
            -- Create TextBox function
            function Section:CreateTextBox(text, placeholder, default, callback)
                local TextBoxFrame = CreateInstance("Frame", {
                    Name = "TextBox",
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local TextBoxLabel = CreateInstance("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TextBoxFrame
                })
                
                local TextBoxInput = CreateInstance("TextBox", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Library.CurrentTheme.ElementColor,
                    BorderSizePixel = 0,
                    Text = default or "",
                    PlaceholderText = placeholder or "",
                    TextColor3 = Library.CurrentTheme.TextColor,
                    PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = TextBoxFrame
                })
                
                local TextBoxCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextBoxInput
                })
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    if callback then
                        callback(TextBoxInput.Text, enterPressed)
                    end
                end)
                
                local TextBoxObj = {}
                
                function TextBoxObj:Update(newText)
                    TextBoxLabel.Text = newText
                end
                
                function TextBoxObj:SetValue(value)
                    TextBoxInput.Text = value
                    
                    if callback then
                        callback(value, false)
                    end
                end
                
                function TextBoxObj:GetValue()
                    return TextBoxInput.Text
                end
                
                return TextBoxObj
            end
            
            return Section
        end
        
        -- Show first tab by default
        if #self.Tabs == 0 then
            self.Tabs[name] = Tab
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Library.CurrentTheme.AccentColor
        else
            self.Tabs[name] = Tab
        end
        
        return Tab
    end
    
    -- Set theme function
    function Window:SetTheme(theme)
        if Library.Themes[theme] then
            Library.CurrentTheme = Library.Themes[theme]
            
            -- Update UI with new theme
            -- (This would be a more complex implementation to update all elements)
        end
    end
    
    return Window
end

-- Change theme function
function Library:SetTheme(theme)
    if self.Themes[theme] then
        self.CurrentTheme = self.Themes[theme]
    end
end

-- Initialize
function Library:Init()
    -- Create ScreenGui
    if syn and syn.protect_gui then
        ScreenGui = Instance.new("ScreenGui")
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = gethui()
    else
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    ScreenGui.Name = "UILibrary"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    return self
end

-- Return the library
return Library:Init()
    
