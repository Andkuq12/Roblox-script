local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Default settings
local FOVAngle = 60
local MaxDistance = 150
local Strength = 0.2
local Enabled = false
local ESPEnabled = false

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Head")
end)
if LocalPlayer.Character then
    LocalPlayer.Character:WaitForChild("Head")
end

local gui = Instance.new("ScreenGui")
gui.Name = "GrandfuscatorGUI"
gui.Parent = CoreGui
gui.ResetOnSpawn = false

local logoScreen = Instance.new("Frame")
logoScreen.Name = "LogoScreen"
logoScreen.Size = UDim2.new(1, 0, 1, 0)
logoScreen.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
logoScreen.Parent = gui

local logoFrame = Instance.new("Frame")
logoFrame.Name = "LogoFrame"
logoFrame.Size = UDim2.new(0, 300, 0, 300)
logoFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
logoFrame.BackgroundTransparency = 1
logoFrame.Parent = logoScreen

local gBackground = Instance.new("Frame")
gBackground.Name = "GBackground"
gBackground.Size = UDim2.new(1, 0, 1, 0)
gBackground.BackgroundColor3 = Color3.fromRGB(10, 25, 47) -- Dark blue
gBackground.BorderSizePixel = 0
gBackground.Parent = logoFrame

local gCorner = Instance.new("UICorner")
gCorner.CornerRadius = UDim.new(0, 20)
gCorner.Parent = gBackground

local gText = Instance.new("TextLabel")
gText.Name = "GText"
gText.Size = UDim2.new(1, 0, 1, 0)
gText.Position = UDim2.new(0, 0, 0, 0)
gText.Text = "G"
gText.TextColor3 = Color3.fromRGB(25, 118, 210) -- Bright blue
gText.TextScaled = true
gText.Font = Enum.Font.GothamBlack
gText.BackgroundTransparency = 1
gText.Parent = logoFrame

local nameText = Instance.new("TextLabel")
nameText.Name = "NameText"
nameText.Size = UDim2.new(1, 0, 0, 40)
nameText.Position = UDim2.new(0, 0, 1, 10)
nameText.Text = "Grandfuscator"
nameText.TextColor3 = Color3.fromRGB(25, 118, 210) -- Bright blue
nameText.TextScaled = true
nameText.Font = Enum.Font.GothamBold
nameText.BackgroundTransparency = 1
nameText.Parent = logoFrame

local loadingBar = Instance.new("Frame")
loadingBar.Name = "LoadingBar"
loadingBar.Size = UDim2.new(0, 200, 0, 4)
loadingBar.Position = UDim2.new(0.5, -100, 1, 60)
loadingBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
loadingBar.BorderSizePixel = 0
loadingBar.Parent = logoFrame

local loadingBarCorner = Instance.new("UICorner")
loadingBarCorner.CornerRadius = UDim.new(1, 0)
loadingBarCorner.Parent = loadingBar

local loadingFill = Instance.new("Frame")
loadingFill.Name = "LoadingFill"
loadingFill.Size = UDim2.new(0, 0, 1, 0)
loadingFill.BackgroundColor3 = Color3.fromRGB(25, 118, 210) -- Bright blue
loadingFill.BorderSizePixel = 0
loadingFill.Parent = loadingBar

local loadingFillCorner = Instance.new("UICorner")
loadingFillCorner.CornerRadius = UDim.new(1, 0)
loadingFillCorner.Parent = loadingFill

spawn(function()
    local scaleTween = TweenService:Create(gBackground, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, -160, 0.5, -160)
    })
    scaleTween:Play()
    
    task.wait(1.5)
    
    local fillTween = TweenService:Create(loadingFill, TweenInfo.new(2, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, 0, 1, 0)
    })
    fillTween:Play()
    
    task.wait(2.5)
    
    local fadeTween = TweenService:Create(logoScreen, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    fadeTween:Play()
    
    task.wait(1)
    logoScreen.Visible = false
end)

wait(3.5)

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(1, 0, 1, 0)
mainContainer.BackgroundTransparency = 1
mainContainer.Parent = gui

local safeArea = Instance.new("Frame")
safeArea.Name = "SafeArea"
safeArea.Size = UDim2.new(1, -40, 1, -40)
safeArea.Position = UDim2.new(0, 20, 0, 20)
safeArea.BackgroundTransparency = 1
safeArea.Parent = mainContainer

local boxContainer = Instance.new("Frame")
boxContainer.Name = "BoxContainer"
boxContainer.Size = UDim2.new(0, 300, 0, 280)
boxContainer.Position = UDim2.new(0.5, -150, 0.5, -140)
boxContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
boxContainer.BorderSizePixel = 0
boxContainer.Visible = false
boxContainer.Parent = safeArea

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 12)
boxCorner.Parent = boxContainer

local boxStroke = Instance.new("UIStroke")
boxStroke.Thickness = 2
boxStroke.Color = Color3.fromRGB(80, 80, 120)
boxStroke.Parent = boxContainer

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "AIM SYSTEM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = boxContainer

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 40)
tabContainer.Position = UDim2.new(0, 0, 0, 45)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = boxContainer

-- Main Tab
local mainTabButton = Instance.new("TextButton")
mainTabButton.Name = "MainTab"
mainTabButton.Size = UDim2.new(0.5, 0, 1, 0)
mainTabButton.Position = UDim2.new(0, 0, 0, 0)
mainTabButton.Text = "MAIN"
mainTabButton.TextScaled = true
mainTabButton.Font = Enum.Font.GothamBold
mainTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
mainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTabButton.Parent = tabContainer

local mainTabCorner = Instance.new("UICorner")
mainTabCorner.CornerRadius = UDim.new(0, 8)
mainTabCorner.Parent = mainTabButton

-- Config Tab
local configTabButton = Instance.new("TextButton")
configTabButton.Name = "ConfigTab"
configTabButton.Size = UDim2.new(0.5, 0, 1, 0)
configTabButton.Position = UDim2.new(0.5, 0, 0, 0)
configTabButton.Text = "CONFIG"
configTabButton.TextScaled = true
configTabButton.Font = Enum.Font.GothamBold
configTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
configTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
configTabButton.Parent = tabContainer

local configTabCorner = Instance.new("UICorner")
configTabCorner.CornerRadius = UDim.new(0, 8)
configTabCorner.Parent = configTabButton

-- Content containers
local mainContent = Instance.new("Frame")
mainContent.Name = "MainContent"
mainContent.Size = UDim2.new(1, -20, 0, 150)
mainContent.Position = UDim2.new(0, 10, 0, 90)
mainContent.BackgroundTransparency = 1
mainContent.Parent = boxContainer

local configContent = Instance.new("ScrollingFrame")
configContent.Name = "ConfigContent"
configContent.Size = UDim2.new(1, -20, 0, 150)
configContent.Position = UDim2.new(0, 10, 0, 90)
configContent.BackgroundTransparency = 1
configContent.BorderSizePixel = 0
configContent.ScrollBarThickness = 4
configContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
configContent.CanvasSize = UDim2.new(0, 0, 0, 200)
configContent.Visible = false
configContent.Parent = boxContainer

-- Main Tab Content
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, 0, 0, 60)
buttonContainer.Position = UDim2.new(0, 0, 0, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainContent

-- Button Toggle
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "LockOnToggle"
toggleButton.Size = UDim2.new(0.45, 0, 1, 0)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.Text = "🔒"
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = buttonContainer

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- ESP Button
local espButton = Instance.new("TextButton")
espButton.Name = "ESPToggle"
espButton.Size = UDim2.new(0.45, 0, 1, 0)
espButton.Position = UDim2.new(0.55, 0, 0, 0)
espButton.Text = "👁"
espButton.TextScaled = true
espButton.Font = Enum.Font.GothamBold
espButton.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
espButton.Parent = buttonContainer

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espButton

-- Status
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, 0, 0, 30)
statusText.Position = UDim2.new(0, 0, 0, 70)
statusText.Text = "Status: OFF"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.BackgroundTransparency = 1
statusText.Parent = mainContent

-- Config Tab Content
local function createSlider(parent, name, icon, min, max, default, yPos)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name .. "Slider"
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    sliderFrame.Position = UDim2.new(0, 0, 0, yPos)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = icon .. " " .. name .. ": " .. string.format("%.1f", default)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = sliderFrame
    
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    bar.Parent = sliderFrame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    fill.Parent = bar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local knob = Instance.new("TextButton")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.Text = ""
    knob.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    knob.Parent = sliderFrame
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local dragging = false
    
    local function updateValue(x)
        local relativeX = math.clamp(x - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local value = min + (relativeX / bar.AbsoluteSize.X) * (max - min)
        
        knob.Position = UDim2.new(relativeX / bar.AbsoluteSize.X, -8, 0.5, -8)
        fill.Size = UDim2.new(relativeX / bar.AbsoluteSize.X, 0, 1, 0)
        label.Text = icon .. " " .. name .. ": " .. string.format("%.1f", value)
        
        if name == "Strength" then
            Strength = value
        elseif name == "FOV" then
            FOVAngle = value
            ring.Size = UDim2.new(0, FOVAngle * 4, 0, FOVAngle * 4)
            ring.Position = UDim2.new(0.5, -(FOVAngle * 2), 0.5, -(FOVAngle * 2))
        elseif name == "Distance" then
            MaxDistance = value
        end
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            knob.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
        end
    end)
    
    knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            knob.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateValue(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateValue(input.Position.X)
        end
    end)
    
    return sliderFrame
end

createSlider(configContent, "Strength", "🎯", 0.05, 0.9, Strength, 0)
createSlider(configContent, "FOV", "🔍", 30, 120, FOVAngle, 50)
createSlider(configContent, "Distance", "📏", 50, 300, MaxDistance, 100)

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.Text = "✕"
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.BackgroundColor3 = Color3.fromRGB(80, 60, 60)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = boxContainer

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Draggable Open Button
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 70, 0, 70)
openButton.Position = UDim2.new(0.5, -35, 0.5, -35) -- Centered
openButton.Text = "⚙️"
openButton.TextScaled = true
openButton.Font = Enum.Font.GothamBold
openButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Parent = safeArea

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Thickness = 2
openStroke.Color = Color3.fromRGB(100, 100, 150)
openStroke.Parent = openButton

local dragConnection
local dragging = false
local dragStart = nil
local startPos = nil

openButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = openButton.Position
    end
end)

openButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        local maxX = safeArea.AbsoluteSize.X - openButton.AbsoluteSize.X
        local maxY = safeArea.AbsoluteSize.Y - openButton.AbsoluteSize.Y
        
        newPosition = UDim2.new(
            0, math.clamp(newPosition.X.Offset, 0, maxX),
            0, math.clamp(newPosition.Y.Offset, 0, maxY)
        )
        
        openButton.Position = newPosition
    end
end)

-- Indicator (visual FOV)
local ring = Instance.new("Frame")
ring.Name = "FOVRing"
ring.Size = UDim2.new(0, FOVAngle*4, 0, FOVAngle*4)
ring.Position = UDim2.new(0.5, -(FOVAngle*2), 0.5, -(FOVAngle*2))
ring.BackgroundTransparency = 1
ring.BorderSizePixel = 0
ring.Visible = false
ring.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = ring

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(255, 50, 50)
uiStroke.Transparency = 0.8
uiStroke.Parent = ring

-- Tab switching 
local function switchTab(tabName)
    if tabName == "Main" then
        mainContent.Visible = true
        configContent.Visible = false
        mainTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        mainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        configTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        configTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    elseif tabName == "Config" then
        mainContent.Visible = false
        configContent.Visible = true
        mainTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        mainTabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        configTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        configTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

mainTabButton.MouseButton1Click:Connect(function()
    switchTab("Main")
end)

configTabButton.MouseButton1Click:Connect(function()
    switchTab("Config")
end)

switchTab("Main")

toggleButton.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    toggleButton.Text = Enabled and "🔒" or "🔓"
    toggleButton.BackgroundColor3 = Enabled and Color3.fromRGB(80, 60, 80) or Color3.fromRGB(60, 60, 80)
    ring.Visible = Enabled
    statusText.Text = "Status: " .. (Enabled and "ON" or "OFF")
end)

espButton.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    espButton.Text = ESPEnabled and "👁" or "📷"
    espButton.BackgroundColor3 = ESPEnabled and Color3.fromRGB(80, 100, 80) or Color3.fromRGB(60, 80, 60)
    
    -- ESP highlights
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if ESPEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = player.Character
                end
            else
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end)

closeButton.MouseButton1Click:Connect(function()
    boxContainer.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    boxContainer.Visible = true
    openButton.Visible = false
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.Parent = player.Character
            end
        end
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        if ESPEnabled then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.Parent = player.Character
            end
        end
    end)
end

local function hasLineOfSight(originPart, targetPart)
    if not originPart or not targetPart then
        return false
    end
    
    local origin = originPart.Position
    local target = targetPart.Position
    local direction = (target - origin)
    local distance = direction.Magnitude
    direction = direction.Unit
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    params.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction * distance, params)
    return result == nil
end

-- Targeting function
local function getTarget()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    
    local head = character:FindFirstChild("Head")
    if not head then
        return nil
    end
    
    local forward = head.CFrame.LookVector
    local closestTarget, closestDist = nil, math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHead = player.Character:FindFirstChild("Head")
            if targetHead then
                local direction = targetHead.Position - head.Position
                local distance = direction.Magnitude
                
                if distance <= MaxDistance then
                    local dot = forward:Dot(direction.Unit)
                    if dot > 0 then -- Only targets in front
                        local angle = math.deg(math.acos(dot))
                        if angle <= FOVAngle / 2 then -- Use half FOV for cone
                            if hasLineOfSight(head, targetHead) then
                                if distance < closestDist then
                                    closestDist = distance
                                    closestTarget = targetHead
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

RunService.RenderStepped:Connect(function(dt)
    if Enabled then
        local target = getTarget()
        if target then
            local desiredCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, Strength * dt * 60) -- Frame rate independent
            
            uiStroke.Color = Color3.fromRGB(0, 255, 0)
            uiStroke.Transparency = 0.5
            statusText.Text = "Status: LOCKED"
        else
            uiStroke.Color = Color3.fromRGB(255, 50, 50)
            uiStroke.Transparency = 0.8
            statusText.Text = "Status: TRACKING"
        end
    else
        statusText.Text = "Status: OFF"
    end
end)
