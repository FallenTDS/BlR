-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")

-- Player setup
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Animation and sound
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://83474010887370"
local track = humanoid:LoadAnimation(animation)

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://411274847"
sound.Volume = 3
sound.Name = "KickSound"
sound.Parent = character:WaitForChild("HumanoidRootPart")

local shootRemote = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("BallService")
    :WaitForChild("RE")
    :WaitForChild("Shoot")

-- Abilities
local function doShoot()
    track:Play()
    task.delay(0.5, function()
        sound:Play()
        local args = {
            200,
            [500] = Vector3.new(-0.8686492443084717, 0.20258301615715027, 0.5732067942619324)
        }
        shootRemote:FireServer(unpack(args))
    end)
end

local function createElectricFlash(root)
    local flashPart = Instance.new("Part")
    flashPart.Shape = Enum.PartType.Ball
    flashPart.Material = Enum.Material.Neon
    flashPart.Color = Color3.fromRGB(0, 170, 255)
    flashPart.Transparency = 0.3
    flashPart.Anchored = true
    flashPart.CanCollide = false
    flashPart.Size = Vector3.new(4, 4, 4)
    flashPart.CFrame = root.CFrame
    flashPart.Parent = workspace

    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(flashPart, tweenInfo, {Transparency = 1})
    tween:Play()

    tween.Completed:Connect(function()
        flashPart:Destroy()
    end)
end

local function flashTeleport()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local flashSound = Instance.new("Sound")
    flashSound.SoundId = "rbxassetid://81593441952462"
    flashSound.Volume = 2
    flashSound.Parent = root
    flashSound:Play()
    Debris:AddItem(flashSound, 2)

    createElectricFlash(root)
    local forward = root.CFrame.LookVector * 7.5
    root.CFrame = root.CFrame + forward
end

local function getTargetGoal()
    local team = LocalPlayer.Team
    if team == Teams:FindFirstChild("Home") then
        return workspace:WaitForChild("Goals"):WaitForChild("Goal2"):WaitForChild("Model"):FindFirstChild("MeshPart")
    elseif team == Teams:FindFirstChild("Away") then
        return workspace:WaitForChild("Goals"):WaitForChild("Goal"):WaitForChild("Model"):FindFirstChild("MeshPart")
    end
    return nil
end

local function getAdjustedGoalCorner(goalPart)
    local size = goalPart.Size
    local cf = goalPart.CFrame
    local offset = Vector3.new(-size.X / 2 + 6, size.Y / 2 - 5, -size.Z / 2 + 2)
    return (cf * CFrame.new(offset)).Position
end

local function doGalaxyCurve()
    track:Play()
    task.delay(0.5, function()
        sound:Play()
        local football = workspace:FindFirstChild("Football")
        if not football or not football:IsA("BasePart") then return end
        local goalPart = getTargetGoal()
        if not goalPart then return end
        local targetPos = getAdjustedGoalCorner(goalPart)
        local startPos = football.Position
        local direction = (targetPos - startPos).Unit
        for _, v in ipairs(football:GetChildren()) do
            if v:IsA("BodyVelocity") then v:Destroy() end
        end
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = direction * 180
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.P = 6000
        bodyVelocity.Parent = football
        Debris:AddItem(bodyVelocity, 5)
    end)
end

-- Reverse Ball Function
local function doReverseBall()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local football = workspace:FindFirstChild("Football")
    if not football or not football:IsA("BasePart") then return end

    for _, v in ipairs(football:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyPosition") then
            v:Destroy()
        end
    end

    local reverseSound = Instance.new("Sound")
    reverseSound.SoundId = "rbxassetid://1843028847"
    reverseSound.Volume = 2
    reverseSound.Parent = root
    reverseSound:Play()
    Debris:AddItem(reverseSound, 3)

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local targetCFrame = root.CFrame + Vector3.new(0, 2, 0)

    local tween = TweenService:Create(football, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    tween.Completed:Connect(function()
        football.CFrame = targetCFrame
    end)
end

-- UI Setup
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local inGameUI = playerGui:WaitForChild("InGameUI")
local bottom = inGameUI:WaitForChild("Bottom")
local abilities = bottom:WaitForChild("Abilities")

local function createOutlineLabel(offsetX, offsetY, parent, text)
    local outline = Instance.new("TextLabel")
    outline.Name = "Outline"
    outline.Size = UDim2.new(0, 22, 0, 22)
    outline.Position = UDim2.new(0, offsetX, 0, 3 + offsetY)
    outline.AnchorPoint = Vector2.new(0, 0.5)
    outline.BackgroundTransparency = 1
    outline.Text = text
    outline.TextColor3 = Color3.new(0, 0, 0)
    outline.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    outline.TextScaled = true
    outline.ZIndex = 2
    outline.Parent = parent
end

local function createAbilityButton(name, labelText, keyChar, callback)
    local button = Instance.new("ImageButton")
    button.Name = name
    button.Size = UDim2.new(0, 74, 0, 74)
    button.BackgroundTransparency = 1
    button.Image = "rbxassetid://94420981449604"
    button.ZIndex = 1
    button.Parent = abilities

    local text = Instance.new("TextLabel")
    text.Name = name .. "Text"
    text.Size = UDim2.new(1, -10, 1, -10)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.Text = labelText
    text.TextColor3 = Color3.new(1, 1, 1)
    text.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    text.TextScaled = true
    text.TextWrapped = true
    text.ZIndex = 2
    text.Parent = button

    createOutlineLabel(-1, 0, button, keyChar)
    createOutlineLabel(1, 0, button, keyChar)
    createOutlineLabel(0, -1, button, keyChar)
    createOutlineLabel(0, 1, button, keyChar)

    local keyLabel = Instance.new("TextLabel")
    keyLabel.Name = "KeyLabel"
    keyLabel.Size = UDim2.new(0, 22, 0, 22)
    keyLabel.Position = UDim2.new(0, 0, 0, 3)
    keyLabel.AnchorPoint = Vector2.new(0, 0.5)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = keyChar
    keyLabel.TextColor3 = Color3.new(1, 1, 1)
    keyLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    keyLabel.TextScaled = true
    keyLabel.ZIndex = 3
    keyLabel.Parent = button

    button.MouseButton1Click:Connect(callback)
end

createAbilityButton("ShootButton", "GOD SHOT", "Z", doShoot)
createAbilityButton("FlashButton", "Godspeed Flash", "N", flashTeleport)
createAbilityButton("GalaxyCurveButton", "Galaxy Curve", "F", doGalaxyCurve)
createAbilityButton("ReverseButton", "Reverse Ball", "G", doReverseBall)

-- Input Bindings
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyMap = {
            Z = doShoot,
            N = flashTeleport,
            F = doGalaxyCurve,
            G = doReverseBall
        }
        local func = keyMap[input.KeyCode.Name]
        if func then func() end
    end
end)
