--[[
    UI Library for Roblox
    A comprehensive UI library with modern design
]]

local UILibrary = {}
UILibrary.__index = UILibrary

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Constants
local PLAYER = Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()

-- Theme
UILibrary.Theme = {
    Primary = Color3.fromRGB(45, 45, 45),
    Secondary = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 170, 255),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(175, 175, 175),
    Error = Color3.fromRGB(255, 75, 75),
    Success = Color3.fromRGB(0, 255, 125),
    Warning = Color3.fromRGB(255, 175, 0),
}

-- Animation Settings
UILibrary.AnimationSettings = {
    TweenInfo = TweenService:Create(game:GetService("TestService"), TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)),
    SpringSettings = {
        Damping = 10,
        Frequency = 5,
        InitialVelocity = 0
    }
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.25,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    
    dragArea = dragArea or frame
    
    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            UpdateDrag(input)
        end
    end)
end

-- Create the main UI container
function UILibrary.new(title)
    local screenGui = CreateInstance("ScreenGui", {
        Name = title or "UILibrary",
        Parent = PLAYER.PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    local self = setmetatable({
        ScreenGui = screenGui,
        Windows = {},
        Notifications = {},
        ActiveWindow = nil,
    }, UILibrary)
    
    return self
end

-- Window Component
function UILibrary:CreateWindow(title, size)
    local windowSize = size or UDim2.new(0, 500, 0, 350)
    
    local window = CreateInstance("Frame", {
        Name = "Window",
        Parent = self.ScreenGui,
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2),
        Size = windowSize,
        ClipsDescendants = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    
    local windowCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = window,
    })
    
    local windowStroke = CreateInstance("UIStroke", {
        Color = self.Theme.Accent,
        Thickness = 1,
        Transparency = 0.5,
        Parent = window,
    })
    
    local titleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = window,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
    })
    
    local titleBarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar,
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Window",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local closeButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.Text,
        TextSize = 20,
    })
    
    local contentContainer = CreateInstance("ScrollingFrame", {
        Name = "ContentContainer",
        Parent = window,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    
    local contentPadding = CreateInstance("UIPadding", {
        Parent = contentContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })
    
    local contentLayout = CreateInstance("UIListLayout", {
        Parent = contentContainer,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    -- Make window draggable
    MakeDraggable(window, titleBar)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        Tween(window, {Size = UDim2.new(0, window.Size.X.Offset, 0, 0)}, 0.25)
        wait(0.25)
        window:Destroy()
    end)
    
    local windowObj = {
        Frame = window,
        Container = contentContainer,
        Title = titleLabel,
    }
    
    table.insert(self.Windows, windowObj)
    self.ActiveWindow = windowObj
    
    -- Window Methods
    local windowMethods = {}
    
    function windowMethods:AddButton(text, callback)
        local button = CreateInstance("TextButton", {
            Name = "Button",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 35),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            AutoButtonColor = false,
        })
        
        local buttonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = button,
        })
        
        -- Button hover and click effects
        button.MouseEnter:Connect(function()
            Tween(button, {BackgroundColor3 = UILibrary.Theme.Accent}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            Tween(button, {BackgroundColor3 = UILibrary.Theme.Secondary}, 0.2)
        end)
        
        button.MouseButton1Down:Connect(function()
            Tween(button, {Size = UDim2.new(1, 0, 0, 32)}, 0.1)
        end)
        
        button.MouseButton1Up:Connect(function()
            Tween(button, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
        end)
        
        button.MouseButton1Click:Connect(function()
            if callback then
                callback()
            end
        end)
        
        return button
    end
    
    function windowMethods:AddToggle(text, default, callback)
        local toggleContainer = CreateInstance("Frame", {
            Name = "ToggleContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 35),
        })
        
        local toggleCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = toggleContainer,
        })
        
        local toggleLabel = CreateInstance("TextLabel", {
            Name = "ToggleLabel",
            Parent = toggleContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local toggleButton = CreateInstance("Frame", {
            Name = "ToggleButton",
            Parent = toggleContainer,
            BackgroundColor3 = default and UILibrary.Theme.Accent or UILibrary.Theme.Error,
            Position = UDim2.new(1, -40, 0.5, -10),
            Size = UDim2.new(0, 30, 0, 16),
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        local toggleButtonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = toggleButton,
        })
        
        local toggleCircle = CreateInstance("Frame", {
            Name = "ToggleCircle",
            Parent = toggleButton,
            BackgroundColor3 = UILibrary.Theme.Text,
            Position = default and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        local toggleCircleCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = toggleCircle,
        })
        
        local toggled = default or false
        
        local function updateToggle()
            if toggled then
                Tween(toggleButton, {BackgroundColor3 = UILibrary.Theme.Accent}, 0.2)
                Tween(toggleCircle, {Position = UDim2.new(1, -14, 0.5, 0)}, 0.2)
            else
                Tween(toggleButton, {BackgroundColor3 = UILibrary.Theme.Error}, 0.2)
                Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
            end
            
            if callback then
                callback(toggled)
            end
        end
        
        toggleContainer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggled = not toggled
                updateToggle()
            end
        end)
        
        return {
            Container = toggleContainer,
            SetValue = function(value)
                toggled = value
                updateToggle()
            end,
            GetValue = function()
                return toggled
            end
        }
    end
    
    function windowMethods:AddSlider(text, min, max, default, callback)
        local sliderContainer = CreateInstance("Frame", {
            Name = "SliderContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 50),
        })
        
        local sliderCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = sliderContainer,
        })
        
        local sliderLabel = CreateInstance("TextLabel", {
            Name = "SliderLabel",
            Parent = sliderContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local sliderValue = CreateInstance("TextLabel", {
            Name = "SliderValue",
            Parent = sliderContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -40, 0, 5),
            Size = UDim2.new(0, 30, 0, 20),
            Font = Enum.Font.Gotham,
            Text = tostring(default),
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
        })
        
        local sliderBackground = CreateInstance("Frame", {
            Name = "SliderBackground",
            Parent = sliderContainer,
            BackgroundColor3 = UILibrary.Theme.Primary,
            Position = UDim2.new(0, 10, 0, 30),
            Size = UDim2.new(1, -20, 0, 5),
        })
        
        local sliderBackgroundCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderBackground,
        })
        
        local sliderFill = CreateInstance("Frame", {
            Name = "SliderFill",
            Parent = sliderBackground,
            BackgroundColor3 = UILibrary.Theme.Accent,
            Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        })
        
        local sliderFillCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderFill,
        })
        
        local sliderButton = CreateInstance("TextButton", {
            Name = "SliderButton",
            Parent = sliderBackground,
            BackgroundColor3 = UILibrary.Theme.Text,
            Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Text = "",
            AnchorPoint = Vector2.new(0.5, 0.5),
        })
        
        local sliderButtonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = sliderButton,
        })
        
        local value = default
        local dragging = false
        
        local function updateSlider(input)
            local sizeX = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
            value = math.floor(min + ((max - min) * sizeX))
            
            sliderValue.Text = tostring(value)
            sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
            sliderButton.Position = UDim2.new(sizeX, 0, 0.5, 0)
            
            if callback then
                callback(value)
            end
        end
        
        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        sliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        sliderBackground.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateSlider(input)
                dragging = true
            end
        end)
        
        sliderBackground.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)
        
        return {
            Container = sliderContainer,
            SetValue = function(newValue)
                value = math.clamp(newValue, min, max)
                local sizeX = (value - min) / (max - min)
                
                sliderValue.Text = tostring(value)
                sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                sliderButton.Position = UDim2.new(sizeX, 0, 0.5, 0)
                
                if callback then
                    callback(value)
                end
            end,
            GetValue = function()
                return value
            end
        }
    end

    function windowMethods:AddDropdown(text, options, default, callback)
        local dropdownContainer = CreateInstance("Frame", {
            Name = "DropdownContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 35),
            ClipsDescendants = true,
        })
        
        local dropdownCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = dropdownContainer,
        })
        
        local dropdownLabel = CreateInstance("TextLabel", {
            Name = "DropdownLabel",
            Parent = dropdownContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -50, 0, 35),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local dropdownButton = CreateInstance("TextButton", {
            Name = "DropdownButton",
            Parent = dropdownContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -35, 0, 0),
            Size = UDim2.new(0, 25, 0, 35),
            Font = Enum.Font.Gotham,
            Text = "▼",
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
        })
        
        local dropdownContent = CreateInstance("Frame", {
            Name = "DropdownContent",
            Parent = dropdownContainer,
            BackgroundColor3 = UILibrary.Theme.Primary,
            Position = UDim2.new(0, 0, 0, 35),
            Size = UDim2.new(1, 0, 0, #options * 25),
            Visible = false,
        })
        
        local dropdownContentLayout = CreateInstance("UIListLayout", {
            Parent = dropdownContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
        
        local selectedOption = default or options[1]
        local dropdownOpen = false
        
        local function updateDropdown()
            dropdownLabel.Text = text .. ": " .. selectedOption
            
            if dropdownOpen then
                dropdownButton.Text = "▲"
                dropdownContent.Visible = true
                Tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 35 + dropdownContent.Size.Y.Offset)}, 0.2)
            else
                dropdownButton.Text = "▼"
                Tween(dropdownContainer, {Size = UDim2.new(1, 0, 0, 35)}, 0.2, nil, nil, function()
                    dropdownContent.Visible = false
                end)
            end
            
            if callback then
                callback(selectedOption)
            end
        end
        
        for i, option in ipairs(options) do
            local optionButton = CreateInstance("TextButton", {
                Name = "Option",
                Parent = dropdownContent,
                BackgroundColor3 = UILibrary.Theme.Primary,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.Gotham,
                Text = option,
                TextColor3 = UILibrary.Theme.Text,
                TextSize = 14,
            })
            
            optionButton.MouseEnter:Connect(function()
                Tween(optionButton, {BackgroundColor3 = UILibrary.Theme.Accent}, 0.2)
            end)
            
            optionButton.MouseLeave:Connect(function()
                Tween(optionButton, {BackgroundColor3 = UILibrary.Theme.Primary}, 0.2)
            end)
            
            optionButton.MouseButton1Click:Connect(function()
                selectedOption = option
                dropdownOpen = false
                updateDropdown()
            end)
        end
        
        dropdownButton.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            updateDropdown()
        end)
        
        updateDropdown()
        
        return {
            Container = dropdownContainer,
            SetValue = function(option)
                if table.find(options, option) then
                    selectedOption = option
                    updateDropdown()
                end
            end,
            GetValue = function()
                return selectedOption
            end,
            AddOption = function(option)
                if not table.find(options, option) then
                    table.insert(options, option)
                    
                    local optionButton = CreateInstance("TextButton", {
                        Name = "Option",
                        Parent = dropdownContent,
                        BackgroundColor3 = UILibrary.Theme.Primary,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = UILibrary.Theme.Text,
                        TextSize = 14,
                    })
                    
                    optionButton.MouseEnter:Connect(function()
                        Tween(optionButton, {BackgroundColor3 = UILibrary.Theme.Accent}, 0.2)
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        Tween(optionButton, {BackgroundColor3 = UILibrary.Theme.Primary}, 0.2)
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        dropdownOpen = false
                        updateDropdown()
                    end)
                    
                    dropdownContent.Size = UDim2.new(1, 0, 0, #options * 25)
                end
            end,
            RemoveOption = function(option)
                local index = table.find(options, option)
                if index then
                    table.remove(options, index)
                    dropdownContent:FindFirstChild("Option" .. index):Destroy()
                    dropdownContent.Size = UDim2.new(1, 0, 0, #options * 25)
                    
                    if selectedOption == option then
                        selectedOption = options[1] or ""
                        updateDropdown()
                    end
                end
            end
        }
    end
    
    function windowMethods:AddTextbox(text, placeholder, callback)
        local textboxContainer = CreateInstance("Frame", {
            Name = "TextboxContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 60),
        })
        
        local textboxCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = textboxContainer,
        })
        
        local textboxLabel = CreateInstance("TextLabel", {
            Name = "TextboxLabel",
            Parent = textboxContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local textboxFrame = CreateInstance("Frame", {
            Name = "TextboxFrame",
            Parent = textboxContainer,
            BackgroundColor3 = UILibrary.Theme.Primary,
            Position = UDim2.new(0, 10, 0, 30),
            Size = UDim2.new(1, -20, 0, 25),
        })
        
        local textboxFrameCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = textboxFrame,
        })
        
        local textbox = CreateInstance("TextBox", {
            Name = "Textbox",
            Parent = textboxFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 5, 0, 0),
            Size = UDim2.new(1, -10, 1, 0),
            Font = Enum.Font.Gotham,
            PlaceholderText = placeholder or "Enter text...",
            Text = "",
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            ClearTextOnFocus = false,
        })
        
        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)
        
        return {
            Container = textboxContainer,
            SetValue = function(value)
                textbox.Text = value
                if callback then
                    callback(value)
                end
            end,
            GetValue = function()
                return textbox.Text
            end
        }
    end
    
    function windowMethods:AddLabel(text)
        local label = CreateInstance("TextLabel", {
            Name = "Label",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
        })
        
        local labelCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = label,
        })
        
        return {
            Label = label,
            SetText = function(newText)
                label.Text = newText
            end
        }
    end
    
    function windowMethods:AddDivider()
        local divider = CreateInstance("Frame", {
            Name = "Divider",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Accent,
            Size = UDim2.new(1, 0, 0, 1),
            Transparency = 0.5,
        })
        
        return divider
    end
    
    function windowMethods:AddColorPicker(text, default, callback)
        local default = default or Color3.fromRGB(255, 255, 255)
        
        local colorPickerContainer = CreateInstance("Frame", {
            Name = "ColorPickerContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 35),
            ClipsDescendants = true,
        })
        
        local colorPickerCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = colorPickerContainer,
        })
        
        local colorPickerLabel = CreateInstance("TextLabel", {
            Name = "ColorPickerLabel",
            Parent = colorPickerContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local colorDisplay = CreateInstance("Frame", {
            Name = "ColorDisplay",
            Parent = colorPickerContainer,
            BackgroundColor3 = default,
            Position = UDim2.new(1, -40, 0.5, 0),
            Size = UDim2.new(0, 25, 0, 25),
            AnchorPoint = Vector2.new(0, 0.5),
        })
        
        local colorDisplayCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = colorDisplay,
        })
        
        local colorPickerButton = CreateInstance("TextButton", {
            Name = "ColorPickerButton",
            Parent = colorPickerContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
        })
        
        local colorPickerFrame = CreateInstance("Frame", {
            Name = "ColorPickerFrame",
            Parent = colorPickerContainer,
            BackgroundColor3 = UILibrary.Theme.Primary,
            Position = UDim2.new(0, 0, 0, 35),
            Size = UDim2.new(1, 0, 0, 115),
            Visible = false,
        })
        
        local colorPickerFrameCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = colorPickerFrame,
        })
        
        local colorPickerPalette = CreateInstance("ImageLabel", {
            Name = "ColorPickerPalette",
            Parent = colorPickerFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 75),
            Image = "rbxassetid://6523286724",
        })
        
        local colorPickerPaletteCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = colorPickerPalette,
        })
        
        local colorPickerHue = CreateInstance("ImageLabel", {
            Name = "ColorPickerHue",
            Parent = colorPickerFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 95),
            Size = UDim2.new(1, -20, 0, 15),
            Image = "rbxassetid://6523291212",
        })
        
        local colorPickerHueCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = colorPickerHue,
        })
        
        local colorPickerSelector = CreateInstance("ImageLabel", {
            Name = "ColorPickerSelector",
            Parent = colorPickerPalette,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 10, 0, 10),
            Image = "rbxassetid://6523555563",
        })
        
        local colorPickerHueSelector = CreateInstance("Frame", {
            Name = "ColorPickerHueSelector",
            Parent = colorPickerHue,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, 3, 1, 0),
        })
        
        local colorPickerHueSelectorCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = colorPickerHueSelector,
        })
        
        local selectedColor = default
        local hue, saturation, value = 0, 0, 1
        local colorPickerOpen = false
        
        local function updateColorPicker()
            if colorPickerOpen then
                colorPickerFrame.Visible = true
                Tween(colorPickerContainer, {Size = UDim2.new(1, 0, 0, 35 + colorPickerFrame.Size.Y.Offset)}, 0.2)
            else
                Tween(colorPickerContainer, {Size = UDim2.new(1, 0, 0, 35)}, 0.2, nil, nil, function()
                    colorPickerFrame.Visible = false
                end)
            end
            
            colorDisplay.BackgroundColor3 = selectedColor
            
            if callback then
                callback(selectedColor)
            end
        end
        
        local function updateHue(input)
            local sizeX = math.clamp((input.Position.X - colorPickerHue.AbsolutePosition.X) / colorPickerHue.AbsoluteSize.X, 0, 1)
            hue = sizeX
            
            colorPickerHueSelector.Position = UDim2.new(sizeX, 0, 0.5, 0)
            
            local hueColor = Color3.fromHSV(hue, 1, 1)
            colorPickerPalette.ImageColor3 = hueColor
            
            selectedColor = Color3.fromHSV(hue, saturation, value)
            colorDisplay.BackgroundColor3 = selectedColor
            
            if callback then
                callback(selectedColor)
            end
        end
        
        local function updateSatVal(input)
            local sizeX = math.clamp((input.Position.X - colorPickerPalette.AbsolutePosition.X) / colorPickerPalette.AbsoluteSize.X, 0, 1)
            local sizeY = math.clamp((input.Position.Y - colorPickerPalette.AbsolutePosition.Y) / colorPickerPalette.AbsoluteSize.Y, 0, 1)
            
            saturation = sizeX
            value = 1 - sizeY
            
            colorPickerSelector.Position = UDim2.new(sizeX, 0, sizeY, 0)
            
            selectedColor = Color3.fromHSV(hue, saturation, value)
            colorDisplay.BackgroundColor3 = selectedColor
            
            if callback then
                callback(selectedColor)
            end
        end
        
        colorPickerButton.MouseButton1Click:Connect(function()
            colorPickerOpen = not colorPickerOpen
            updateColorPicker()
        end)
        
        colorPickerHue.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateHue(input)
                local dragging = true
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
                
                while dragging and RunService.RenderStepped:Wait() do
                    local mousePos = UserInputService:GetMouseLocation()
                    updateHue({Position = mousePos})
                end
            end
        end)
        
        colorPickerPalette.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateSatVal(input)
                local dragging = true
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
                
                while dragging and RunService.RenderStepped:Wait() do
                    local mousePos = UserInputService:GetMouseLocation()
                    updateSatVal({Position = mousePos})
                end
            end
        end)

                -- Initialize color picker with default color
        local h, s, v = Color3.toHSV(default)
        hue, saturation, value = h, s, v
        
        colorPickerHueSelector.Position = UDim2.new(h, 0, 0.5, 0)
        colorPickerSelector.Position = UDim2.new(s, 0, 1 - v, 0)
        colorPickerPalette.ImageColor3 = Color3.fromHSV(h, 1, 1)
        
        return {
            Container = colorPickerContainer,
            SetValue = function(color)
                selectedColor = color
                local h, s, v = Color3.toHSV(color)
                hue, saturation, value = h, s, v
                
                colorPickerHueSelector.Position = UDim2.new(h, 0, 0.5, 0)
                colorPickerSelector.Position = UDim2.new(s, 0, 1 - v, 0)
                colorPickerPalette.ImageColor3 = Color3.fromHSV(h, 1, 1)
                colorDisplay.BackgroundColor3 = color
                
                if callback then
                    callback(color)
                end
            end,
            GetValue = function()
                return selectedColor
            end
        }
    end
    
    function windowMethods:AddKeyBind(text, default, callback)
        local keyBindContainer = CreateInstance("Frame", {
            Name = "KeyBindContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 35),
        })
        
        local keyBindCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = keyBindContainer,
        })
        
        local keyBindLabel = CreateInstance("TextLabel", {
            Name = "KeyBindLabel",
            Parent = keyBindContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -110, 1, 0),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        local keyBindButton = CreateInstance("TextButton", {
            Name = "KeyBindButton",
            Parent = keyBindContainer,
            BackgroundColor3 = UILibrary.Theme.Primary,
            Position = UDim2.new(1, -100, 0.5, 0),
            Size = UDim2.new(0, 90, 0, 25),
            AnchorPoint = Vector2.new(0, 0.5),
            Font = Enum.Font.Gotham,
            Text = default and default.Name or "None",
            TextColor3 = UILibrary.Theme.Text,
            TextSize = 12,
            AutoButtonColor = false,
        })
        
        local keyBindButtonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = keyBindButton,
        })
        
        local currentKey = default
        local listening = false
        
        keyBindButton.MouseButton1Click:Connect(function()
            if listening then return end
            
            listening = true
            keyBindButton.Text = "..."
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    keyBindButton.Text = input.KeyCode.Name
                    listening = false
                    connection:Disconnect()
                    
                    if callback then
                        callback(currentKey)
                    end
                end
            end)
        end)
        
        return {
            Container = keyBindContainer,
            SetValue = function(key)
                currentKey = key
                keyBindButton.Text = key and key.Name or "None"
                
                if callback then
                    callback(key)
                end
            end,
            GetValue = function()
                return currentKey
            end
        }
    end
    
    function windowMethods:AddTabSystem()
        local tabContainer = CreateInstance("Frame", {
            Name = "TabContainer",
            Parent = contentContainer,
            BackgroundColor3 = UILibrary.Theme.Secondary,
            Size = UDim2.new(1, 0, 0, 200),
            ClipsDescendants = true,
        })
        
        local tabContainerCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = tabContainer,
        })
        
        local tabButtons = CreateInstance("Frame", {
            Name = "TabButtons",
            Parent = tabContainer,
            BackgroundColor3 = UILibrary.Theme.Primary,
            Size = UDim2.new(1, 0, 0, 30),
        })
        
        local tabButtonsCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = tabButtons,
        })
        
        local tabButtonsLayout = CreateInstance("UIListLayout", {
            Parent = tabButtons,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
        })
        
        local tabContent = CreateInstance("Frame", {
            Name = "TabContent",
            Parent = tabContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 30),
            Size = UDim2.new(1, 0, 1, -30),
        })
        
        local tabs = {}
        local activeTab = nil
        
        local tabSystem = {
            Container = tabContainer,
            AddTab = function(name)
                local tabButton = CreateInstance("TextButton", {
                    Name = name .. "Button",
                    Parent = tabButtons,
                    BackgroundColor3 = UILibrary.Theme.Secondary,
                    Size = UDim2.new(0, 100, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = UILibrary.Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false,
                })
                
                local tabButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = tabButton,
                })
                
                local tabFrame = CreateInstance("ScrollingFrame", {
                    Name = name .. "Frame",
                    Parent = tabContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = UILibrary.Theme.Accent,
                    BorderSizePixel = 0,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Visible = false,
                })
                
                local tabFramePadding = CreateInstance("UIPadding", {
                    Parent = tabFrame,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10),
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 10),
                })
                
                local tabFrameLayout = CreateInstance("UIListLayout", {
                    Parent = tabFrame,
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                
                local tab = {
                    Button = tabButton,
                    Frame = tabFrame,
                    Name = name,
                }
                
                table.insert(tabs, tab)
                
                tabButton.MouseButton1Click:Connect(function()
                    for _, t in ipairs(tabs) do
                        t.Frame.Visible = (t == tab)
                        Tween(t.Button, {BackgroundColor3 = (t == tab) and UILibrary.Theme.Accent or UILibrary.Theme.Secondary}, 0.2)
                    end
                    activeTab = tab
                end)
                
                -- If this is the first tab, make it active
                if #tabs == 1 then
                    tabButton.BackgroundColor3 = UILibrary.Theme.Accent
                    tabFrame.Visible = true
                    activeTab = tab
                end
                
                -- Tab methods
                local tabMethods = {}
                
                function tabMethods:AddButton(text, callback)
                    local button = CreateInstance("TextButton", {
                        Name = "Button",
                        Parent = tabFrame,
                        BackgroundColor3 = UILibrary.Theme.Secondary,
                        Size = UDim2.new(1, 0, 0, 35),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = UILibrary.Theme.Text,
                        TextSize = 14,
                        AutoButtonColor = false,
                    })
                    
                    local buttonCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = button,
                    })
                    
                    -- Button hover and click effects
                    button.MouseEnter:Connect(function()
                        Tween(button, {BackgroundColor3 = UILibrary.Theme.Accent}, 0.2)
                    end)
                    
                    button.MouseLeave:Connect(function()
                        Tween(button, {BackgroundColor3 = UILibrary.Theme.Secondary}, 0.2)
                    end)
                    
                    button.MouseButton1Down:Connect(function()
                        Tween(button, {Size = UDim2.new(1, 0, 0, 32)}, 0.1)
                    end)
                    
                    button.MouseButton1Up:Connect(function()
                        Tween(button, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                    end)
                    
                    button.MouseButton1Click:Connect(function()
                        if callback then
                            callback()
                        end
                    end)
                    
                    return button
                end
                
                function tabMethods:AddToggle(text, default, callback)
                    local toggleContainer = CreateInstance("Frame", {
                        Name = "ToggleContainer",
                        Parent = tabFrame,
                        BackgroundColor3 = UILibrary.Theme.Secondary,
                        Size = UDim2.new(1, 0, 0, 35),
                    })
                    
                    local toggleCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = toggleContainer,
                    })
                    
                    local toggleLabel = CreateInstance("TextLabel", {
                        Name = "ToggleLabel",
                        Parent = toggleContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -50, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = UILibrary.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    local toggleButton = CreateInstance("Frame", {
                        Name = "ToggleButton",
                        Parent = toggleContainer,
                        BackgroundColor3 = default and UILibrary.Theme.Accent or UILibrary.Theme.Error,
                        Position = UDim2.new(1, -40, 0.5, -10),
                        Size = UDim2.new(0, 30, 0, 16),
                        AnchorPoint = Vector2.new(0, 0.5),
                    })
                    
                    local toggleButtonCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = toggleButton,
                    })
                    
                    local toggleCircle = CreateInstance("Frame", {
                        Name = "ToggleCircle",
                        Parent = toggleButton,
                        BackgroundColor3 = UILibrary.Theme.Text,
                        Position = default and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        AnchorPoint = Vector2.new(0, 0.5),
                    })
                    
                    local toggleCircleCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = toggleCircle,
                    })
                    
                    local toggled = default or false
                    
                    local function updateToggle()
                        if toggled then
                            Tween(toggleButton, {BackgroundColor3 = UILibrary.Theme.Accent}, 0.2)
                            Tween(toggleCircle, {Position = UDim2.new(1, -14, 0.5, 0)}, 0.2)
                        else
                            Tween(toggleButton, {BackgroundColor3 = UILibrary.Theme.Error}, 0.2)
                            Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2)
                        end
                        
                        if callback then
                            callback(toggled)
                        end
                    end
                    
                    toggleContainer.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            toggled = not toggled
                            updateToggle()
                        end
                    end)
                    
                    return {
                        Container = toggleContainer,
                        SetValue = function(value)
                            toggled = value
                            updateToggle()
                        end,
                        GetValue = function()
                            return toggled
                        end
                    }
                end
                
                function tabMethods:AddSlider(text, min, max, default, callback)
                    local sliderContainer = CreateInstance("Frame", {
                        Name = "SliderContainer",
                        Parent = tabFrame,
                        BackgroundColor3 = UILibrary.Theme.Secondary,
                        Size = UDim2.new(1, 0, 0, 50),
                    })
                    
                    local sliderCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = sliderContainer,
                    })
                    
                    local sliderLabel = CreateInstance("TextLabel", {
                        Name = "SliderLabel",
                        Parent = sliderContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 5),
                        Size = UDim2.new(1, -20, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = UILibrary.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    
                    local sliderValue = CreateInstance("TextLabel", {
                        Name = "SliderValue",
                        Parent = sliderContainer,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -40, 0, 5),
                        Size = UDim2.new(0, 30, 0, 20),
                        Font = Enum.Font.Gotham,
                        Text = tostring(default),
                        TextColor3 = UILibrary.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })
                    
                    local sliderBackground = CreateInstance("Frame", {
                        Name = "SliderBackground",
                        Parent = sliderContainer,
                        BackgroundColor3 = UILibrary.Theme.Primary,
                        Position = UDim2.new(0, 10, 0, 30),
                        Size = UDim2.new(1, -20, 0, 5),
                    })
                    
                    local sliderBackgroundCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = sliderBackground,
                    })
                    
                    local sliderFill = CreateInstance("Frame", {
                        Name = "SliderFill",
                        Parent = sliderBackground,
                        BackgroundColor3 = UILibrary.Theme.Accent,
                        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    })
                    
                    local sliderFillCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = sliderFill,
                    })
                    
                    local sliderButton = CreateInstance("TextButton", {
                        Name = "SliderButton",
                        Parent = sliderBackground,
                        BackgroundColor3 = UILibrary.Theme.Text,
                        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        Text = "",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                    })
                    
                    local sliderButtonCorner = CreateInstance("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = sliderButton,
                    })
                    
                    local value = default
                    local dragging = false
                    
                    local function updateSlider(input)
                        local sizeX = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + ((max - min) * sizeX))
                        
                        sliderValue.Text = tostring(value)
                        sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                        sliderButton.Position = UDim2.new(sizeX, 0, 0.5, 0)
                        
                        if callback then
                            callback(value)
                        end
                    end
                    
                    sliderButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                        end
                    end)
                    
                    sliderButton.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    sliderBackground.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            updateSlider(input)
                            dragging = true
                        end
                    end)
                    
                    sliderBackground.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            updateSlider(input)
                        end
                    end)
                    
                    return {
                        Container = sliderContainer,
                        SetValue = function(newValue)
                            value = math.clamp(newValue, min, max)
                            local sizeX = (value - min) / (max - min)
                            
                            sliderValue.Text = tostring(value)
                            sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                            sliderButton.Position = UDim2.new(sizeX, 0, 0.5, 0)
                            
                            if callback then
                                callback(value)
                            end
                        end,
                        GetValue = function()
                            return value
                        end
                    }
                end
                
                -- Add more tab component methods as needed
                
                return tabMethods
            end,
            
            SetTabVisible = function(name)
                for _, tab in ipairs(tabs) do
                    if tab.Name == name then
                        tab.Frame.Visible = true
                        tab.Button.BackgroundColor3 = UILibrary.Theme.Accent
                        activeTab = tab
                    else
                        tab.Frame.Visible = false
                        tab.Button.BackgroundColor3 = UILibrary.Theme.Secondary
                    end
                end
            end,
            
            GetActiveTab = function()
                return activeTab
            end,
            
            SetSize = function(size)
                tabContainer.Size = size
            end
        }
        
        return tabSystem
    end
    
    return windowMethods
end

-- Key System Component
function UILibrary:CreateKeySystem(title, correctKey, callback)
    local keySystemGui = CreateInstance("ScreenGui", {
        Name = "KeySystem",
        Parent = PLAYER.PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    local keySystemFrame = CreateInstance("Frame", {
        Name = "KeySystemFrame",
        Parent = keySystemGui,
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 300, 0, 200),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    
    local keySystemCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = keySystemFrame,
    })
    
    local keySystemStroke = CreateInstance("UIStroke", {
        Color = self.Theme.Accent,
        Thickness = 1,
        Transparency = 0.5,
        Parent = keySystemFrame,
    })
    
    local titleBar = CreateInstance("Frame", {
        Name = "TitleBar",
        Parent = keySystemFrame,
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
    })
    
    local titleBarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar,
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Key System",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    
    local keyInputContainer = CreateInstance("Frame", {
        Name = "KeyInputContainer",
        Parent = keySystemFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 100),
    })
    
    local keyInputLabel = CreateInstance("TextLabel", {
        Name = "KeyInputLabel",
        Parent = keyInputContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.Gotham,
        Text = "Please enter your key:",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
    })
    
    local keyInputBox = CreateInstance("TextBox", {
        Name = "KeyInputBox",
        Parent = keyInputContainer,
        BackgroundColor3 = self.Theme.Secondary,
        Position = UDim2.new(0.5, -125, 0, 40),
        Size = UDim2.new(0, 250, 0, 35),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Enter key here...",
        Text = "",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        ClearTextOnFocus = false,
    })
    
    local keyInputBoxCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = keyInputBox,
    })
    
    local statusLabel = CreateInstance("TextLabel", {
        Name = "StatusLabel",
        Parent = keySystemFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 140),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = self.Theme.Error,
        TextSize = 12,
    })
    
    local submitButton = CreateInstance("TextButton", {
        Name = "SubmitButton",
        Parent = keySystemFrame,
        BackgroundColor3 = self.Theme.Accent,
        Position = UDim2.new(0.5, -75, 0, 160),
        Size = UDim2.new(0, 150, 0, 30),
        Font = Enum.Font.GothamSemibold,
        Text = "Submit",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
    })
    
    local submitButtonCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = submitButton,
    })
    
    -- Make the key system draggable
    MakeDraggable(keySystemFrame, titleBar)
    
    -- Submit button functionality
    submitButton.MouseButton1Click:Connect(function()
        local inputKey = keyInputBox.Text
        
        if inputKey == correctKey then
            statusLabel.Text = "Key verified successfully!"
            statusLabel.TextColor3 = self.Theme.Success
            
            Tween(keySystemFrame, {Size = UDim2.new(0, 300, 0, 0)}, 0.5, nil, nil, function()
                keySystemGui:Destroy()
                
                if callback then
                    callback(true)
                end
            end)
        else
            statusLabel.Text = "Invalid key. Please try again."
            statusLabel.TextColor3 = self.Theme.Error
            
            Tween(keyInputBox, {Position = UDim2.new(0.5, -125 - 10, 0, 40)}, 0.1, nil, nil, function()
                Tween(keyInputBox, {Position = UDim2.new(0.5, -125 + 10, 0, 40)}, 0.1, nil, nil, function()
                    Tween(keyInputBox, {Position = UDim2.new(0.5, -125, 0, 40)}, 0.1)
                end)
            end)
            
            if callback then
                callback(false)
            end
        end
    end)
    
    return keySystemGui
end

-- Notification Component
function UILibrary:CreateNotification(title, message, duration, notificationType)
    local notificationGui = CreateInstance("ScreenGui", {
        Name = "Notification",
        Parent = PLAYER.PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    local notificationFrame = CreateInstance("Frame", {
        Name = "NotificationFrame",
        Parent = notificationGui,
        BackgroundColor3 = self.Theme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 0.9, 0),
        Size = UDim2.new(0, 250, 0, 80),
        AnchorPoint = Vector2.new(0, 1),
    })
    
    local notificationCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notificationFrame,
    })
    
    local notificationStroke = CreateInstance("UIStroke", {
        Color = self.Theme.Accent,
        Thickness = 1,
        Transparency = 0.5,
        Parent = notificationFrame,
    })
    
    local notificationColor
    if notificationType == "success" then
        notificationColor = self.Theme.Success
    elseif notificationType == "error" then
        notificationColor = self.Theme.Error
    elseif notificationType == "warning" then
        notificationColor = self.Theme.Warning
    else
        notificationColor = self.Theme.Accent
    end
    
    local colorBar = CreateInstance("Frame", {
        Name = "ColorBar",
        Parent = notificationFrame,
        BackgroundColor3 = notificationColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 5, 1, 0),
    })
    
    local colorBarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = colorBar,
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Name = "TitleLabel",
        Parent = notificationFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -25, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    
    local messageLabel = CreateInstance("TextLabel", {
        Name = "MessageLabel",
        Parent = notificationFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -25, 0, 35),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = self.Theme.TextDark,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    
    local closeButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = notificationFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.Text,
        TextSize = 16,
    })
    
    -- Progress bar for duration
    local progressBar = CreateInstance("Frame", {
        Name = "ProgressBar",
        Parent = notificationFrame,
        BackgroundColor3 = notificationColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        AnchorPoint = Vector2.new(0, 0),
    })
    
    -- Animation
    Tween(notificationFrame, {Position = UDim2.new(1, -20, 0.9, 0)}, 0.5, Enum.EasingStyle.Quint)
    
    -- Progress bar animation
    Tween(progressBar, {Size = UDim2.new(0, 0, 0, 2)}, duration or 5, Enum.EasingStyle.Linear)
    
    -- Close button functionality
    closeButton.MouseButton1Click:Connect(function()
        Tween(notificationFrame, {Position = UDim2.new(1, 20, 0.9, 0)}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
            notificationGui:Destroy()
        end)
    end)
    
    -- Auto close after duration
    delay(duration or 5, function()
        if notificationGui and notificationGui.Parent then
            Tween(notificationFrame, {Position = UDim2.new(1, 20, 0.9, 0)}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
                notificationGui:Destroy()
            end)
        end
    end)
    
    return notificationGui
end

-- Return the library
return UILibrary
