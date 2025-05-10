--[[
    Maby UI Library
    A comprehensive UI library for Roblox games
    
    Features:
    - Customizable buttons, sliders, toggles, dropdowns
    - Draggable windows
    - Notifications system
    - Tabbed interfaces
    - Input fields with validation
    - Tooltips
    - Animations and transitions
    - Theme support
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local MabyUI = {}
MabyUI.__index = MabyUI

-- Utility functions
local Util = {}

function Util.Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties or {}) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Util.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

function Util.Ripple(button, x, y)
    local ripple = Util.Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button,
        ZIndex = button.ZIndex + 1,
    })
    
    Util.Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local buttonSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    Util.Tween(ripple, {Size = UDim2.new(0, buttonSize, 0, buttonSize), BackgroundTransparency = 1}, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

function Util.Shadow(parent, size, transparency)
    local shadow = Util.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, size or 12, 1, size or 12),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        Parent = parent
    })
    return shadow
end

function Util.GetTextSize(text, fontSize, font, frameSize)
    return TextService:GetTextSize(text, fontSize, font, frameSize)
end

-- Main UI Library
function MabyUI.new(title, theme)
    local screenGui = Util.Create("ScreenGui", {
        Name = "MabyUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Player.PlayerGui
    })
    
    -- Default themes
    local themes = {
        Dark = {
            Background = Color3.fromRGB(30, 30, 30),
            Container = Color3.fromRGB(40, 40, 40),
            Text = Color3.fromRGB(255, 255, 255),
            Primary = Color3.fromRGB(0, 120, 215),
            Secondary = Color3.fromRGB(60, 60, 60),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 240),
            Container = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(30, 30, 30),
            Primary = Color3.fromRGB(0, 120, 215),
            Secondary = Color3.fromRGB(220, 220, 220),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60)
        },
        Blurple = {
            Background = Color3.fromRGB(54, 57, 63),
            Container = Color3.fromRGB(47, 49, 54),
            Text = Color3.fromRGB(255, 255, 255),
            Primary = Color3.fromRGB(114, 137, 218),
            Secondary = Color3.fromRGB(66, 69, 73),
            Success = Color3.fromRGB(67, 181, 129),
            Warning = Color3.fromRGB(250, 166, 26),
            Error = Color3.fromRGB(240, 71, 71)
        }
    }
    
    local activeTheme = themes[theme or "Dark"]
    
    local self = setmetatable({
        ScreenGui = screenGui,
        Windows = {},
        Notifications = {},
        Theme = activeTheme,
        Themes = themes
    }, MabyUI)
    
    -- Create notification container
    self.NotificationContainer = Util.Create("Frame", {
        Name = "NotificationContainer",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = screenGui
    })
    
    Util.Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = self.NotificationContainer
    })
    
    return self
end

-- Window creation
function MabyUI:CreateWindow(title, size)
    local window = {}
    window.Tabs = {}
    window.ActiveTab = nil
    
    -- Main window frame
    window.Frame = Util.Create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Container,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size or UDim2.new(0, 500, 0, 350),
        Parent = self.ScreenGui,
        ZIndex = 2
    })
    
    Util.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = window.Frame
    })
    
    Util.Shadow(window.Frame)
    
    -- Title bar
    window.TitleBar = Util.Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = self.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = window.Frame,
        ZIndex = 3
    })
    
    Util.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = window.TitleBar
    })
    
    -- Only round the top corners
    Util.Create("Frame", {
        Name = "BottomCover",
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = window.TitleBar,
        ZIndex = 3
    })
    
    -- Title text
    window.Title = Util.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Maby UI",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.TitleBar,
        ZIndex = 3
    })
    
    -- Close button
    window.CloseButton = Util.Create("TextButton", {
        Name = "CloseButton",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        Parent = window.TitleBar,
        ZIndex = 3
    })
    
    -- Tab container
    window.TabContainer = Util.Create("Frame", {
        Name = "TabContainer",
        BackgroundColor3 = self.Theme.Secondary,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 30),
        Parent = window.Frame,
        ZIndex = 3
    })
    
    Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
        Parent = window.TabContainer
    })
    
    Util.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        Parent = window.TabContainer
    })
    
    -- Content container
    window.ContentContainer = Util.Create("Frame", {
        Name = "ContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60),
        Parent = window.Frame,
        ZIndex = 2
    })
    
    -- Make window draggable
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Frame.Position
        end
    end)
    
    window.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    window.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    -- Close button functionality
    window.CloseButton.MouseButton1Click:Connect(function()
        window.Frame:Destroy()
        for i, win in pairs(self.Windows) do
            if win == window then
                table.remove(self.Windows, i)
                break
            end
        end
    end)
    
    -- Tab creation function
    function window:AddTab(name)
        local tab = {}
        tab.Elements = {}
        
        -- Tab button
        tab.Button = Util.Create("TextButton", {
            Name = name .. "Tab",
            BackgroundColor3 = self.ActiveTab == nil and self.Parent.Theme.Primary or self.Parent.Theme.Secondary,
            Size = UDim2.new(0, 100, 0, 25),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            Parent = self.TabContainer,
            ZIndex = 3
        })
        
        Util.Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = tab.Button
        })
        
        -- Tab content
        tab.Container = Util.Create("ScrollingFrame", {
            Name = name .. "Container",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self.Parent.Theme.Primary,
            Visible = self.ActiveTab == nil,
            Parent = self.ContentContainer,
            ZIndex = 2
        })
        
        Util.Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tab.Container
        })
        
        Util.Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = tab.Container
        })
        
        -- Set as active tab if it's the first one
        if self.ActiveTab == nil then
            self.ActiveTab = tab
        else
            tab.Container.Visible = false
        end
        
        -- Tab button click handler
        tab.Button.MouseButton1Click:Connect(function()
            if self.ActiveTab then
                self.ActiveTab.Container.Visible = false
                self.ActiveTab.Button.BackgroundColor3 = self.Parent.Theme.Secondary
            end
            
            tab.Container.Visible = true
            tab.Button.BackgroundColor3 = self.Parent.Theme.Primary
            self.ActiveTab = tab
        end)
        
        -- Element creation functions
        function tab:AddLabel(text)
            local label = {}
            
            label.Frame = Util.Create("Frame", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = self.Container
            })
            
            label.Text = Util.Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                Parent = label.Frame
            })
            
            function label:SetText(newText)
                self.Text.Text = newText
            end
            
            table.insert(self.Elements, label)
            self:UpdateCanvasSize()
            return label
        end
        
        function tab:AddButton(text, callback)
            local button = {}
            
            button.Frame = Util.Create("Frame", {
                Name = "Button",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                Parent = self.Container
            })
            
            button.Button = Util.Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = self.Parent.Parent.Theme.Primary,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                ClipsDescendants = true,
                Parent = button.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = button.Button
            })
            
            -- Ripple effect
            button.Button.MouseButton1Down:Connect(function(x, y)
                local relativeX = x - button.Button.AbsolutePosition.X
                local relativeY = y - button.Button.AbsolutePosition.Y
                Util.Ripple(button.Button, relativeX, relativeY)
            end)
            
            -- Click handler
            button.Button.MouseButton1Click:Connect(function()
                if callback then
                    callback()
                end
            end)
            
            function button:SetText(newText)
                self.Button.Text = newText
            end
            
            table.insert(self.Elements, button)
            self:UpdateCanvasSize()
            return button
        end
        
        function tab:AddToggle(text, default, callback)
            local toggle = {}
            
            toggle.Frame = Util.Create("Frame", {
                Name = "Toggle",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                Parent = self.Container
            })
            
            toggle.Label = Util.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle.Frame
            })

            toggle.Background = Util.Create("Frame", {
                Name = "Background",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = default and self.Parent.Parent.Theme.Primary or self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 20),
                Parent = toggle.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggle.Background
            })
            
            toggle.Indicator = Util.Create("Frame", {
                Name = "Indicator",
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(default and 1 or 0, default and -18 or 2, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = toggle.Background
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = toggle.Indicator
            })
            
            toggle.Value = default or false
            
            toggle.Background.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle.Value = not toggle.Value
                    
                    Util.Tween(toggle.Indicator, {
                        Position = UDim2.new(toggle.Value and 1 or 0, toggle.Value and -18 or 2, 0.5, 0)
                    }, 0.2)
                    
                    Util.Tween(toggle.Background, {
                        BackgroundColor3 = toggle.Value and self.Parent.Parent.Theme.Primary or self.Parent.Parent.Theme.Secondary
                    }, 0.2)
                    
                    if callback then
                        callback(toggle.Value)
                    end
                end
            end)
            
            function toggle:SetValue(value)
                self.Value = value
                
                Util.Tween(self.Indicator, {
                    Position = UDim2.new(value and 1 or 0, value and -18 or 2, 0.5, 0)
                }, 0.2)
                
                Util.Tween(self.Background, {
                    BackgroundColor3 = value and self.Parent.Parent.Theme.Primary or self.Parent.Parent.Theme.Secondary
                }, 0.2)
                
                if callback then
                    callback(value)
                end
            end
            
            table.insert(self.Elements, toggle)
            self:UpdateCanvasSize()
            return toggle
        end
        
        function tab:AddSlider(text, min, max, default, callback)
            local slider = {}
            
            slider.Frame = Util.Create("Frame", {
                Name = "Slider",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = self.Container
            })
            
            slider.Label = Util.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider.Frame
            })
            
            slider.Value = Util.Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -40, 0, 0),
                Size = UDim2.new(0, 40, 0, 20),
                Font = Enum.Font.Gotham,
                Text = tostring(default),
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider.Frame
            })
            
            slider.Background = Util.Create("Frame", {
                Name = "Background",
                BackgroundColor3 = self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 10),
                Parent = slider.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = slider.Background
            })
            
            slider.Fill = Util.Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = self.Parent.Parent.Theme.Primary,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Parent = slider.Background
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = slider.Fill
            })
            
            slider.Knob = Util.Create("Frame", {
                Name = "Knob",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = slider.Background
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = slider.Knob
            })
            
            slider.Min = min
            slider.Max = max
            slider.Value = default
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - slider.Background.AbsolutePosition.X) / slider.Background.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                slider.Fill.Size = UDim2.new(pos, 0, 1, 0)
                slider.Knob.Position = UDim2.new(pos, 0, 0.5, 0)
                slider.Value.Text = tostring(value)
                slider.Value = value
                
                if callback then
                    callback(value)
                end
            end
            
            local dragging = false
            
            slider.Background.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            slider.Background.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            function slider:SetValue(value)
                value = math.clamp(value, self.Min, self.Max)
                local pos = (value - self.Min) / (self.Max - self.Min)
                
                self.Fill.Size = UDim2.new(pos, 0, 1, 0)
                self.Knob.Position = UDim2.new(pos, 0, 0.5, 0)
                self.Value.Text = tostring(value)
                self.Value = value
                
                if callback then
                    callback(value)
                end
            end
            
            table.insert(self.Elements, slider)
            self:UpdateCanvasSize()
            return slider
        end
        
        function tab:AddDropdown(text, options, default, callback)
            local dropdown = {}
            
            dropdown.Frame = Util.Create("Frame", {
                Name = "Dropdown",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                ClipsDescendants = true,
                Parent = self.Container
            })
            
            dropdown.Label = Util.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown.Frame
            })
            
            dropdown.Button = Util.Create("TextButton", {
                Name = "Button",
                BackgroundColor3 = self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 30),
                Font = Enum.Font.Gotham,
                Text = default or "Select...",
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                Parent = dropdown.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdown.Button
            })
            
            dropdown.Arrow = Util.Create("ImageLabel", {
                Name = "Arrow",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -5, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                Image = "rbxassetid://6031091004",
                ImageColor3 = self.Parent.Parent.Theme.Text,
                Parent = dropdown.Button
            })
            
            dropdown.OptionsFrame = Util.Create("Frame", {
                Name = "OptionsFrame",
                BackgroundColor3 = self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(0, 0, 0, 60),
                Size = UDim2.new(1, 0, 0, #options * 30),
                Visible = false,
                ZIndex = 5,
                Parent = dropdown.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = dropdown.OptionsFrame
            })
            
            dropdown.OptionsList = Util.Create("ScrollingFrame", {
                Name = "OptionsList",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, #options * 30),
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = self.Parent.Parent.Theme.Primary,
                ZIndex = 5,
                Parent = dropdown.OptionsFrame
            })
            
            Util.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = dropdown.OptionsList
            })
            
            dropdown.Options = {}
            dropdown.Value = default
            dropdown.Open = false
            
            for i, option in ipairs(options) do
                local optionButton = Util.Create("TextButton", {
                    Name = option,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = self.Parent.Parent.Theme.Text,
                    TextSize = 14,
                    ZIndex = 5,
                    Parent = dropdown.OptionsList
                })
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundTransparency = 0.9
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundTransparency = 1
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdown.Value = option
                    dropdown.Button.Text = option
                    dropdown:Toggle()
                    
                    if callback then
                        callback(option)
                    end
                end)
                
                table.insert(dropdown.Options, optionButton)
            end
            
            function dropdown:Toggle()
                self.Open = not self.Open
                
                if self.Open then
                    self.Frame.Size = UDim2.new(1, 0, 0, 65 + math.min(#self.Options, 5) * 30)
                    self.OptionsFrame.Visible = true
                    Util.Tween(self.Arrow, {Rotation = 180}, 0.2)
                else
                    self.Frame.Size = UDim2.new(1, 0, 0, 60)
                    self.OptionsFrame.Visible = false
                    Util.Tween(self.Arrow, {Rotation = 0}, 0.2)
                end
                
                self.Parent:UpdateCanvasSize()
            end
            
            dropdown.Button.MouseButton1Click:Connect(function()
                dropdown:Toggle()
            end)
            
            function dropdown:SetValue(value)
                if table.find(options, value) then
                    self.Value = value
                    self.Button.Text = value
                    
                    if callback then
                        callback(value)
                    end
                end
            end
            
            table.insert(self.Elements, dropdown)
            self:UpdateCanvasSize()
            return dropdown
        end
        
        function tab:AddTextbox(text, placeholder, default, callback)
            local textbox = {}
            
            textbox.Frame = Util.Create("Frame", {
                Name = "Textbox",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 60),
                Parent = self.Container
            })
            
            textbox.Label = Util.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = textbox.Frame
            })
            
            textbox.Background = Util.Create("Frame", {
                Name = "Background",
                BackgroundColor3 = self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 0, 35),
                Parent = textbox.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = textbox.Background
            })
            
            textbox.Input = Util.Create("TextBox", {
                Name = "Input",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                PlaceholderText = placeholder or "Type here...",
                Text = default or "",
                TextColor3 = self.Parent.Parent.Theme.Text,
                PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = textbox.Background
            })
            
            textbox.Value = default or ""
            
            textbox.Input.FocusLost:Connect(function(enterPressed)
                textbox.Value = textbox.Input.Text
                
                if callback then
                    callback(textbox.Value, enterPressed)
                end
            end)
            
            function textbox:SetValue(value)
                self.Value = value
                self.Input.Text = value
                
                if callback then
                    callback(value, false)
                end
            end
            
            table.insert(self.Elements, textbox)
            self:UpdateCanvasSize()
            return textbox
        end
        
        function tab:AddColorPicker(text, default, callback)
            local colorPicker = {}
            
            colorPicker.Frame = Util.Create("Frame", {
                Name = "ColorPicker",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                ClipsDescendants = true,
                Parent = self.Container
            })
            
            colorPicker.Label = Util.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker.Frame
            })
            
            colorPicker.Display = Util.Create("Frame", {
                Name = "Display",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = default or Color3.fromRGB(255, 0, 0),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 20),
                Parent = colorPicker.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPicker.Display
            })
            
            colorPicker.Picker = Util.Create("Frame", {
                Name = "Picker",
                BackgroundColor3 = self.Parent.Parent.Theme.Container,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 200),
                Visible = false,
                ZIndex = 5,
                Parent = colorPicker.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPicker.Picker
            })
            
            Util.Shadow(colorPicker.Picker)
            
            colorPicker.Hue = Util.Create("ImageLabel", {
                Name = "Hue",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(1, -20, 0, 20),
                Image = "rbxassetid://6523286724",
                ZIndex = 5,
                Parent = colorPicker.Picker
            })

            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPicker.Hue
            })
            
            colorPicker.HueSelector = Util.Create("Frame", {
                Name = "HueSelector",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(0, 4, 1, 0),
                ZIndex = 6,
                Parent = colorPicker.Hue
            })
            
            colorPicker.Saturation = Util.Create("ImageLabel", {
                Name = "Saturation",
                BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                Position = UDim2.new(0, 10, 0, 40),
                Size = UDim2.new(1, -20, 0, 150),
                Image = "rbxassetid://6523291212",
                ZIndex = 5,
                Parent = colorPicker.Picker
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = colorPicker.Saturation
            })
            
            colorPicker.SaturationSelector = Util.Create("Frame", {
                Name = "SaturationSelector",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.new(0, 10, 0, 10),
                ZIndex = 6,
                Parent = colorPicker.Saturation
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = colorPicker.SaturationSelector
            })
            
            Util.Create("UIStroke", {
                Color = Color3.fromRGB(255, 255, 255),
                Thickness = 2,
                Parent = colorPicker.SaturationSelector
            })
            
            colorPicker.Value = default or Color3.fromRGB(255, 0, 0)
            colorPicker.Open = false
            
            function colorPicker:Toggle()
                self.Open = not self.Open
                
                if self.Open then
                    self.Frame.Size = UDim2.new(1, 0, 0, 245)
                    self.Picker.Visible = true
                else
                    self.Frame.Size = UDim2.new(1, 0, 0, 35)
                    self.Picker.Visible = false
                end
                
                self.Parent:UpdateCanvasSize()
            end
            
            colorPicker.Display.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorPicker:Toggle()
                end
            end)
            
            -- Hue selection
            local hueDragging = false
            
            colorPicker.Hue.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = true
                    
                    local huePosition = math.clamp((input.Position.X - colorPicker.Hue.AbsolutePosition.X) / colorPicker.Hue.AbsoluteSize.X, 0, 1)
                    colorPicker.HueSelector.Position = UDim2.new(huePosition, 0, 0.5, 0)
                    
                    local hue = 1 - huePosition
                    local saturation = 1 - colorPicker.SaturationSelector.Position.X.Scale
                    local value = 1 - colorPicker.SaturationSelector.Position.Y.Scale
                    
                    local color = Color3.fromHSV(hue, saturation, value)
                    colorPicker.Saturation.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    colorPicker.Display.BackgroundColor3 = color
                    colorPicker.Value = color
                    
                    if callback then
                        callback(color)
                    end
                end
            end)
            
            colorPicker.Hue.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDragging = false
                end
            end)
            
            -- Saturation/Value selection
            local satDragging = false
            
            colorPicker.Saturation.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    satDragging = true
                    
                    local satPosition = math.clamp((input.Position.X - colorPicker.Saturation.AbsolutePosition.X) / colorPicker.Saturation.AbsoluteSize.X, 0, 1)
                    local valPosition = math.clamp((input.Position.Y - colorPicker.Saturation.AbsolutePosition.Y) / colorPicker.Saturation.AbsoluteSize.Y, 0, 1)
                    
                    colorPicker.SaturationSelector.Position = UDim2.new(satPosition, 0, valPosition, 0)
                    
                    local hue = 1 - colorPicker.HueSelector.Position.X.Scale
                    local saturation = satPosition
                    local value = 1 - valPosition
                    
                    local color = Color3.fromHSV(hue, saturation, value)
                    colorPicker.Display.BackgroundColor3 = color
                    colorPicker.Value = color
                    
                    if callback then
                        callback(color)
                    end
                end
            end)
            
            colorPicker.Saturation.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    satDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if hueDragging then
                        local huePosition = math.clamp((input.Position.X - colorPicker.Hue.AbsolutePosition.X) / colorPicker.Hue.AbsoluteSize.X, 0, 1)
                        colorPicker.HueSelector.Position = UDim2.new(huePosition, 0, 0.5, 0)
                        
                        local hue = 1 - huePosition
                        local saturation = colorPicker.SaturationSelector.Position.X.Scale
                        local value = 1 - colorPicker.SaturationSelector.Position.Y.Scale
                        
                        local color = Color3.fromHSV(hue, saturation, value)
                        colorPicker.Saturation.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                        colorPicker.Display.BackgroundColor3 = color
                        colorPicker.Value = color
                        
                        if callback then
                            callback(color)
                        end
                    elseif satDragging then
                        local satPosition = math.clamp((input.Position.X - colorPicker.Saturation.AbsolutePosition.X) / colorPicker.Saturation.AbsoluteSize.X, 0, 1)
                        local valPosition = math.clamp((input.Position.Y - colorPicker.Saturation.AbsolutePosition.Y) / colorPicker.Saturation.AbsoluteSize.Y, 0, 1)
                        
                        colorPicker.SaturationSelector.Position = UDim2.new(satPosition, 0, valPosition, 0)
                        
                        local hue = 1 - colorPicker.HueSelector.Position.X.Scale
                        local saturation = satPosition
                        local value = 1 - valPosition
                        
                        local color = Color3.fromHSV(hue, saturation, value)
                        colorPicker.Display.BackgroundColor3 = color
                        colorPicker.Value = color
                        
                        if callback then
                            callback(color)
                        end
                    end
                end
            end)
            
            function colorPicker:SetValue(color)
                local h, s, v = Color3.toHSV(color)
                
                self.HueSelector.Position = UDim2.new(1 - h, 0, 0.5, 0)
                self.SaturationSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                self.Saturation.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                self.Display.BackgroundColor3 = color
                self.Value = color
                
                if callback then
                    callback(color)
                end
            end
            
            table.insert(self.Elements, colorPicker)
            self:UpdateCanvasSize()
            return colorPicker
        end
        
        function tab:AddKeybind(text, default, callback)
            local keybind = {}
            
            keybind.Frame = Util.Create("Frame", {
                Name = "Keybind",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 35),
                Parent = self.Container
            })
            
            keybind.Label = Util.Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = keybind.Frame
            })
            
            keybind.Button = Util.Create("TextButton", {
                Name = "Button",
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 90, 0, 25),
                Font = Enum.Font.Gotham,
                Text = default and default.Name or "None",
                TextColor3 = self.Parent.Parent.Theme.Text,
                TextSize = 12,
                Parent = keybind.Frame
            })
            
            Util.Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = keybind.Button
            })
            
            keybind.Value = default
            keybind.Listening = false
            
            keybind.Button.MouseButton1Click:Connect(function()
                if keybind.Listening then return end
                
                keybind.Listening = true
                keybind.Button.Text = "..."
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybind.Value = input.KeyCode
                        keybind.Button.Text = input.KeyCode.Name
                        keybind.Listening = false
                        
                        if callback then
                            callback(input.KeyCode)
                        end
                        
                        connection:Disconnect()
                    end
                end)
            end)
            
            function keybind:SetValue(keyCode)
                self.Value = keyCode
                self.Button.Text = keyCode and keyCode.Name or "None"
                
                if callback then
                    callback(keyCode)
                end
            end
            
            table.insert(self.Elements, keybind)
            self:UpdateCanvasSize()
            return keybind
        end
        
        function tab:AddDivider()
            local divider = {}
            
            divider.Frame = Util.Create("Frame", {
                Name = "Divider",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 10),
                Parent = self.Container
            })
            
            divider.Line = Util.Create("Frame", {
                Name = "Line",
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = self.Parent.Parent.Theme.Secondary,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = divider.Frame
            })
            
            table.insert(self.Elements, divider)
            self:UpdateCanvasSize()
            return divider
        end
        
        function tab:UpdateCanvasSize()
            local contentHeight = self.Container.UIListLayout.AbsoluteContentSize.Y + 20
            self.Container.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        end
        
        table.insert(self.Tabs, tab)
        return tab
    end
    
    table.insert(self.Windows, window)
    window.Parent = self
    return window
end

-- Notification system
function MabyUI:Notify(options)
    options = options or {}
    local title = options.title or "Notification"
    local text = options.text or ""
    local duration = options.duration or 5
    local type = options.type or "info" -- info, success, warning, error
    
    local colors = {
        info = self.Theme.Primary,
        success = self.Theme.Success,
        warning = self.Theme.Warning,
        error = self.Theme.Error
    }
    
    local notification = {}
    
    notification.Frame = Util.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = self.Theme.Container,
        Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true,
        Parent = self.NotificationContainer,
        ZIndex = 100
    })
    
    Util.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification.Frame
    })
    
    Util.Shadow(notification.Frame)
    
    notification.TopBar = Util.Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = colors[type],
        Size = UDim2.new(1, 0, 0, 4),
        Parent = notification.Frame,
        ZIndex = 101
    })
    
    Util.Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification.TopBar
    })
    
    notification.Title = Util.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -50, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification.Frame,
        ZIndex = 101
    })
    
    notification.Text = Util.Create("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 35),
        Size = UDim2.new(1, -20, 0, 0),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification.Frame,
        ZIndex = 101
    })
    
    notification.CloseButton = Util.Create("TextButton", {
        Name = "CloseButton",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -5, 0, 10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.Text,
        TextSize = 20,
        Parent = notification.Frame,
        ZIndex = 101
    })
    
    notification.ProgressBar = Util.Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = colors[type],
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = notification.Frame,
        ZIndex = 101
    })
    
    -- Calculate text height
    local textSize = Util.GetTextSize(text, 14, Enum.Font.Gotham, Vector2.new(notification.Text.AbsoluteSize.X, math.huge))
    notification.Text.Size = UDim2.new(1, -20, 0, textSize.Y)
    
    -- Set notification height
    local height = 45 + textSize.Y
    notification.Frame.Size = UDim2.new(1, 0, 0, height)
    
    -- Close button functionality
    notification.CloseButton.MouseButton1Click:Connect(function()
        notification:Close()
    end)
    
    -- Progress bar animation
    Util.Tween(notification.ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration)
    
    -- Auto close after duration
    task.delay(duration, function()
        notification:Close()
    end)
    
    function notification:Close()
        Util.Tween(self.Frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.3, function()
            self.Frame:Destroy()
        end)
    end
    
    table.insert(self.Notifications, notification)
    return notification
end

-- Change theme
function MabyUI:SetTheme(theme)
    if self.Themes[theme] then
        self.Theme = self.Themes[theme]
        
        -- Update all windows with new theme
        for _, window in ipairs(self.Windows) do
            window.Frame.BackgroundColor3 = self.Theme.Container
            window.TitleBar.BackgroundColor3 = self.Theme.Primary
            window.TabContainer.BackgroundColor3 = self.Theme.Secondary
            
            -- Update tabs
            for _, tab in ipairs(window.Tabs) do
                if tab == window.ActiveTab then
                    tab.Button.BackgroundColor3 = self.Theme.Primary
                else
                    tab.Button.BackgroundColor3 = self.Theme.Secondary
                end
                
                -- Update elements
                for _, element in ipairs(tab.Elements) do
                    if element.Label then
                        element.Label.TextColor3 = self.Theme.Text
                    end
                    
                    if element.Text then
                        element.Text.TextColor3 = self.Theme.Text
                    end
                    
                    if element.Button and element.Button:IsA("TextButton") then
                        if element.Frame.Name == "Button" then
                            element.Button.BackgroundColor3 = self.Theme.Primary
                        else
                            element.Button.TextColor3 = self.Theme.Text
                        end
                    end
                    
                    if element.Background then
                        element.Background.BackgroundColor3 = self.Theme.Secondary
                    end
                    
                    if element.Fill then
                        element.Fill.BackgroundColor3 = self.Theme.Primary
                    end
                    
                    if element.Line then
                        element.Line.BackgroundColor3 = self.Theme.Secondary
                    end
                end
            end
        end
    end
end

-- Create a custom theme
function MabyUI:CreateTheme(name, colors)
    self.Themes[name] = colors
    return self.Themes[name]
end

return MabyUI
