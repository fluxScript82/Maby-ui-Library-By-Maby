--[[
    Example usage of the UI Library
]]

-- Load the UI Library
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/UILibrary/main/UILibrary.lua"))()

-- Create a new UI instance
local UI = UILibrary.new("My UI Library")

-- Create a key system
local keySystem = UILibrary:CreateKeySystem("Welcome", "12345", function(success)
    if success then
        -- Create a window after successful key verification
        local mainWindow = UI:CreateWindow("Main Window")
        
        -- Add a button to the window
        mainWindow:AddButton("Click Me", function()
            print("Button clicked!")
        end)
        
        -- Add a toggle to the window
        local toggle = mainWindow:AddToggle("Toggle Feature", false, function(value)
            print("Toggle value:", value)
        end)
        
        -- Add a slider to the window
        local slider = mainWindow:AddSlider("Walkspeed", 16, 100, 16, function(value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end)
        
        -- Add a dropdown to the window
        local dropdown = mainWindow:AddDropdown("Select Option", {"Option 1", "Option 2", "Option 3"}, "Option 1", function(selected)
            print("Selected option:", selected)
        end)
        
        -- Add a textbox to the window
        local textbox = mainWindow:AddTextbox("Enter Text", "Default text", function(text)
            print("Text entered:", text)
        end)
        
        -- Add a color picker to the window
        local colorPicker = mainWindow:AddColorPicker("Select Color", Color3.fromRGB(255, 0, 0), function(color)
            print("Selected color:", color)
        end)
        
        -- Add a key bind to the window
        local keyBind = mainWindow:AddKeyBind("Toggle UI", Enum.KeyCode.RightControl, function(key)
            print("Key pressed:", key.Name)
        end)
        
        -- Create a second window
        local settingsWindow = UI:CreateWindow("Settings", UDim2.new(0, 400, 0, 300))
        
        -- Add a tab system to the settings window
        local tabSystem = settingsWindow:AddTabSystem()
        
        -- Add tabs to the tab system
        local generalTab = tabSystem:AddTab("General")
        local appearanceTab = tabSystem:AddTab("Appearance")
        local advancedTab = tabSystem:AddTab("Advanced")
        
        -- Add components to the general tab
        generalTab:AddToggle("Enable Sounds", true, function(value)
            print("Sounds enabled:", value)
        end)
        
        generalTab:AddSlider("Volume", 0, 100, 50, function(value)
            print("Volume set to:", value)
        end)
        
        -- Add components to the appearance tab
        appearanceTab:AddColorPicker("UI Color", Color3.fromRGB(0, 170, 255), function(color)
            print("UI color changed to:", color)
        end)
        
        appearanceTab:AddDropdown("Theme", {"Dark", "Light", "Custom"}, "Dark", function(theme)
            print("Theme changed to:", theme)
        end)
        
        -- Add components to the advanced tab
        advancedTab:AddToggle("Developer Mode", false, function(value)
            print("Developer mode:", value)
        end)
        
        advancedTab:AddButton("Reset Settings", function()
            print("Settings reset!")
        end)
        
        -- Create a notification
        UI:CreateNotification("Success", "UI Library loaded successfully!", 5, "success")
    else
        -- Create a notification for failed key verification
        UI:CreateNotification("Error", "Invalid key provided!", 5, "error")
    end
end)
