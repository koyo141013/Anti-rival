-- AntiRival Custom Shader Button
-- Adds a button visible only to you (LocalPlayer) that launches the Shader Menu when clicked.
-- Saved to: AntiRival_CustomShaderButton.lua

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
if not player then return end

-- If the user already has the button gui, don't create another
local existing = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("CustomShaderButtonGui")
if existing then
    -- bring it to front
    existing.Enabled = true
    return
end

local function createShaderMenu()
    -- The shader menu code is embedded here. It creates its own ScreenGui named "ShaderMenuGui".
    -- If the menu already exists, show it instead of creating a duplicate.
    if player and player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("ShaderMenuGui") then
        player.PlayerGui.ShaderMenuGui.Enabled = true
        return
    end

    -- ==========================================
    -- Shader Menu Implementation (embedded)
    -- ==========================================
    local camera = Workspace.CurrentCamera

    -- Ensure mouse is usable when menu opens
    UserInputService.MouseIconEnabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    -- 1. Effects
    local colorEffect = Instance.new("ColorCorrectionEffect")
    colorEffect.Name = "ThemeColor"
    colorEffect.Enabled = false
    colorEffect.Parent = camera

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "ThemeBlur"
    blurEffect.Enabled = false
    blurEffect.Parent = camera

    local bloomEffect = Instance.new("BloomEffect")
    bloomEffect.Name = "ThemeBloom"
    bloomEffect.Enabled = false
    bloomEffect.Parent = camera

    -- particles
    local originalClockTime = Lighting.ClockTime

    local snowPart = Instance.new("Part")
    snowPart.Name = "LocalSnowPart"
    snowPart.Transparency = 1
    snowPart.CanCollide = false
    snowPart.Anchored = true
    snowPart.Size = Vector3.new(150, 2, 150)
    snowPart.Parent = camera

    local snowEmitter = Instance.new("ParticleEmitter")
    snowEmitter.Enabled = false
    snowEmitter.Texture = "rbxassetid://144211124"
    snowEmitter.Rate = 150
    snowEmitter.Lifetime = NumberRange.new(4, 7)
    snowEmitter.Speed = NumberRange.new(15, 30)
    snowEmitter.EmissionDirection = Enum.NormalId.Bottom
    snowEmitter.Size = NumberSequence.new(0.2, 0.4)
    snowEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    snowEmitter.Parent = snowPart

    local auroraPart = Instance.new("Part")
    auroraPart.Name = "LocalAuroraPart"
    auroraPart.Transparency = 1
    auroraPart.CanCollide = false
    auroraPart.Anchored = true
    auroraPart.Size = Vector3.new(300, 10, 300)
    auroraPart.Parent = camera

    local auroraEmitter = Instance.new("ParticleEmitter")
    auroraEmitter.Enabled = false
    auroraEmitter.Texture = "rbxassetid://1328003666"
    auroraEmitter.Rate = 6
    auroraEmitter.Lifetime = NumberRange.new(15, 20)
    auroraEmitter.Speed = NumberRange.new(2, 5)
    auroraEmitter.EmissionDirection = Enum.NormalId.Right
    auroraEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 30),
        NumberSequenceKeypoint.new(0.5, 120),
        NumberSequenceKeypoint.new(1, 40)
    })
    auroraEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0.6),
        NumberSequenceKeypoint.new(0.7, 0.6),
        NumberSequenceKeypoint.new(1, 1)
    })
    auroraEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 80, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
    })
    auroraEmitter.Parent = auroraPart

    -- Shader presets
    local shaderPresets = {
        { Name = "원본 (OFF)", Color = {Enabled = false}, Blur = {Enabled = false}, Bloom = {Enabled = false} },
        { Name = "과거 회상 (세피아)", Color = {Enabled = true, Brightness = 0, Contrast = 0.2, Saturation = -0.6, TintColor = Color3.fromRGB(255, 210, 160)}, Blur = {Enabled = true, Size = 8}, Bloom = {Enabled = false} },
        { Name = "몽환적인 꿈", Color = {Enabled = true, Brightness = 0.1, Contrast = 0.1, Saturation = 0.4, TintColor = Color3.fromRGB(255, 240, 255)}, Blur = {Enabled = false}, Bloom = {Enabled = true, Intensity = 0.8, Size = 24, Threshold = 1} },
        { Name = "차가운 밤", Color = {Enabled = true, Brightness = -0.15, Contrast = 0.3, Saturation = -0.4, TintColor = Color3.fromRGB(130, 150, 255)}, Blur = {Enabled = false}, Bloom = {Enabled = false} },
        { Name = "브레인롯 (폭주)", Color = {Enabled = true, Brightness = 0.1, Contrast = 0.6, Saturation = 2.5, TintColor = Color3.fromRGB(255, 100, 255)}, Blur = {Enabled = false}, Bloom = {Enabled = true, Intensity = 1, Size = 15, Threshold = 0.5} },
        { Name = "네더의 열기 (용광로)", Color = {Enabled = true, Brightness = 0.05, Contrast = 0.5, Saturation = 0.8, TintColor = Color3.fromRGB(255, 80, 20)}, Blur = {Enabled = true, Size = 4}, Bloom = {Enabled = true, Intensity = 1.2, Size = 30, Threshold = 0.8} },
        { Name = "흑백 영화 (모노톤)", Color = {Enabled = true, Brightness = 0, Contrast = 0.6, Saturation = -1, TintColor = Color3.fromRGB(255, 255, 255)}, Blur = {Enabled = false}, Bloom = {Enabled = false} },
        { Name = "사이버펑크", Color = {Enabled = true, Brightness = -0.1, Contrast = 0.7, Saturation = 1.2, TintColor = Color3.fromRGB(100, 200, 255)}, Blur = {Enabled = false}, Bloom = {Enabled = true, Intensity = 1.5, Size = 20, Threshold = 1.5} },
        { Name = "블리자드 (눈보라)", Color = {Enabled = true, Brightness = 0.1, Contrast = 0.1, Saturation = -0.5, TintColor = Color3.fromRGB(220, 240, 255)}, Blur = {Enabled = true, Size = 3}, Bloom = {Enabled = true, Intensity = 0.3, Size = 15, Threshold = 1}, Snow = true },
        { Name = "우주의 밤 (눈보라)", Color = {Enabled = true, Brightness = 0.05, Contrast = 0.2, Saturation = -0.3, TintColor = Color3.fromRGB(220, 230, 255)}, Blur = {Enabled = false}, Bloom = {Enabled = true, Intensity = 0.5, Size = 10, Threshold = 1.5}, CustomTime = 0, Snow = true },
        { Name = "오로라의 밤", Color = {Enabled = true, Brightness = 0.05, Contrast = 0.3, Saturation = 0.2, TintColor = Color3.fromRGB(200, 255, 220)}, Blur = {Enabled = false}, Bloom = {Enabled = true, Intensity = 0.6, Size = 20, Threshold = 1.2}, CustomTime = 0, Snow = false, Aurora = true }
    }

    -- UI creation
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShaderMenuGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local modalBg = Instance.new("TextButton")
    modalBg.Size = UDim2.new(1, 0, 1, 0)
    modalBg.BackgroundTransparency = 1
    modalBg.Text = ""
    modalBg.Modal = true
    modalBg.ZIndex = -1
    modalBg.Parent = screenGui

    local mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 240, 0, 350)
    mainWindow.Position = UDim2.new(0.8, -250, 0.5, -175)
    mainWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    mainWindow.Active = true
    mainWindow.Parent = screenGui

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 8)
    windowCorner.Parent = mainWindow

    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, -30, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Text = "✨ 쉐이더 설정"
    titleBar.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = 14
    titleBar.Parent = mainWindow

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "❌"
    closeButton.TextSize = 14
    closeButton.Parent = mainWindow

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -40)
    scrollFrame.Position = UDim2.new(0, 5, 0, 35)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #shaderPresets * 45 + 10)
    scrollFrame.Parent = mainWindow

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = scrollFrame

    for i, preset in ipairs(shaderPresets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -15, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Text = preset.Name
        btn.LayoutOrder = i

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        btn.Parent = scrollFrame

        btn.MouseButton1Click:Connect(function()
            colorEffect.Enabled = preset.Color.Enabled
            if preset.Color.Enabled then
                colorEffect.Brightness = preset.Color.Brightness
                colorEffect.Contrast = preset.Color.Contrast
                colorEffect.Saturation = preset.Color.Saturation
                colorEffect.TintColor = preset.Color.TintColor
            end

            blurEffect.Enabled = preset.Blur.Enabled
            if preset.Blur.Enabled then blurEffect.Size = preset.Blur.Size end

            bloomEffect.Enabled = preset.Bloom.Enabled
            if preset.Bloom.Enabled then
                bloomEffect.Intensity = preset.Bloom.Intensity
                bloomEffect.Size = preset.Bloom.Size
                bloomEffect.Threshold = preset.Bloom.Threshold
            end

            if preset.CustomTime then
                Lighting.ClockTime = preset.CustomTime
            else
                Lighting.ClockTime = originalClockTime
            end

            snowEmitter.Enabled = preset.Snow or false
            auroraEmitter.Enabled = preset.Aurora or false
        end)
    end

    -- Dragging
    local dragging = false
    local dragInput, dragStart, startPos

    mainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainWindow.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local runConnection = RunService.RenderStepped:Connect(function()
        if snowEmitter.Enabled then
            snowPart.CFrame = camera.CFrame * CFrame.new(0, 40, -10)
        end

        if auroraEmitter.Enabled then
            auroraPart.CFrame = camera.CFrame * CFrame.new(0, 150, -100)
        end
    end)

    -- Close handling
    closeButton.MouseButton1Click:Connect(function()
        if runConnection then runConnection:Disconnect() end
        colorEffect:Destroy()
        blurEffect:Destroy()
        bloomEffect:Destroy()
        if snowPart then snowPart:Destroy() end
        if auroraPart then auroraPart:Destroy() end
        Lighting.ClockTime = originalClockTime
        UserInputService.MouseIconEnabled = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        screenGui:Destroy()
    end)
end

-- Create the small button visible only to the local player
local gui = Instance.new("ScreenGui")
gui.Name = "CustomShaderButtonGui"
gui.ResetOnSpawn = false
if player and player:FindFirstChild("PlayerGui") then
    gui.Parent = player.PlayerGui
else
    gui.Parent = player:WaitForChild("PlayerGui")
end

local btn = Instance.new("TextButton")
btn.Name = "OpenShaderButton"
btn.Size = UDim2.new(0, 110, 0, 28)
btn.Position = UDim2.new(0.95, -120, 0.02, 0)
btn.AnchorPoint = Vector2.new(1, 0)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
btn.BorderColor3 = Color3.fromRGB(70, 70, 85)
btn.TextColor3 = Color3.fromRGB(200, 200, 255)
btn.Text = "Custom Shader"
btn.Font = Enum.Font.GothamSemibold
btn.TextSize = 13
btn.Parent = gui

btn.MouseButton1Click:Connect(function()
    pcall(function()
        createShaderMenu()
    end)
end)

-- Optional: Right-click or shift-click to hide the button
btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        gui.Enabled = false
    end
end)

-- Clean up on character/respawn to avoid duplicated GUIs
player.CharacterAdded:Connect(function()
    if player.PlayerGui:FindFirstChild("CustomShaderButtonGui") then
        -- keep it, or recreate if preferred
    end
end)
