local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

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

-- Helper to create outline text labels
local function createOutlineLabel(offsetX, offsetY, parent, text)
    local outline = Instance.new("TextLabel")
    outline.Name = "Outline"
    outline.Size = UDim2.new(0, 22, 0, 22)
    outline.Position = UDim2.new(0, offsetX, 0, 3 + offsetY)
    outline.AnchorPoint = Vector2.new(0, 0.5)
    outline.BackgroundTransparency = 1
    outline.Text = text
    outline.TextColor3 = Color3.new(0, 0, 0)
    outline.FontFace = Font.new(
        "rbxasset://fonts/families/GothamSSm.json",
        Enum.FontWeight.ExtraBold,
        Enum.FontStyle.Normal
    )
    outline.TextScaled = true
    outline.ZIndex = 2
    outline.Parent = parent
end

-- Shoot (God Shot) (Z)
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

-- Flash Teleport (Godspeed Flash) (N)
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
    local character = LocalPlayer.Character
    if not character then return end
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

-- Galaxy Curve (F)
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

-- Protect Ball (Y)
local function protectBall()
    local football = workspace:FindFirstChild("Football")
    if not football or not football:IsA("BasePart") then return end

    -- Remove existing velocities
    for _, v in ipairs(football:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyForce") then
            v:Destroy()
        end
    end

    -- Create BodyVelocity to fling ball horizontally (no Y)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5) -- No Y force
    local randomDir = Vector3.new(
        math.random(-50, 50),
        0,
        math.random(-50, 50)
    )
    if randomDir.Magnitude == 0 then
        randomDir = Vector3.new(1, 0, 0)
    end
    bodyVelocity.Velocity = randomDir.Unit * 100
    bodyVelocity.Parent = football

    Debris:AddItem(bodyVelocity, 1)
end

-- Reverse Ball (G) - pulls ball towards player with upward arc, stops on arrival
local reverseConnection
local function reverseBall()
    local football = workspace:FindFirstChild("Football")
    if not football or not football:IsA("BasePart") then return end

    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Disconnect any existing ReverseBall loop to avoid multiple loops
    if reverseConnection then
        reverseConnection:Disconnect()
        reverseConnection = nil
    end

    -- Remove existing BodyVelocity from football
    for _, v in ipairs(football:GetChildren()) do
        if v:IsA("BodyVelocity") then
            v:Destroy()
        end
    end

    -- Create BodyVelocity that pulls ball towards player with upward force
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 6000
    bodyVelocity.Parent = football

    reverseConnection = RunService.Heartbeat:Connect(function()
        if not football or not football.Parent then
            if reverseConnection then
                reverseConnection:Disconnect()
                reverseConnection = nil
            end
            return
        end
        local toPlayer = (root.Position - football.Position)
        local distance = toPlayer.Magnitude

        if distance < 3 then
            -- Close enough, stop the ball and disconnect loop
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity:Destroy()
            if reverseConnection then
                reverseConnection:Disconnect()
                reverseConnection = nil
            end
            return
        end

        -- Direction normalized plus upward curve (0.8 Y)
        local direction = toPlayer.Unit + Vector3.new(0, 0.8, 0)
        bodyVelocity.Velocity = direction.Unit * 120
    end)
end

-- UI Setup
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local inGameUI = playerGui:WaitForChild("InGameUI")
local bottom = inGameUI:WaitForChild("Bottom")
local abilities = bottom:WaitForChild("Abilities")

-- GOD SHOT BUTTON (Z)
local shootButton = Instance.new("ImageButton")
shootButton.Name = "ShootButton"
shootButton.Size = UDim2.new(0, 74, 0, 74)
shootButton.BackgroundTransparency = 1
shootButton.Image = "rbxassetid://94420981449604"
shootButton.ZIndex = 1
shootButton.Parent = abilities

local godShotText = Instance.new("TextLabel")
godShotText.Name = "GodShotText"
godShotText.Size = UDim2.new(1, -10, 1, -10)
godShotText.Position = UDim2.new(0, 5, 0, 5)
godShotText.BackgroundTransparency = 1
godShotText.Text = "GOD SHOT"
godShotText.TextColor3 = Color3.new(1, 1, 1)
godShotText.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
godShotText.TextScaled = true
godShotText.TextWrapped = true
godShotText.ZIndex = 2
godShotText.Parent = shootButton

createOutlineLabel(-1, 0, shootButton, "Z")
createOutlineLabel(1, 0, shootButton, "Z")
createOutlineLabel(0, -1, shootButton, "Z")
createOutlineLabel(0, 1, shootButton, "Z")

local shootKeyLabel = Instance.new("TextLabel")
shootKeyLabel.Name = "KeyLabel"
shootKeyLabel.Size = UDim2.new(0, 22, 0, 22)
shootKeyLabel.Position = UDim2.new(0, 0, 0, 3)
shootKeyLabel.AnchorPoint = Vector2.new(0, 0.5)
shootKeyLabel.BackgroundTransparency = 1
shootKeyLabel.Text = "Z"
shootKeyLabel.TextColor3 = Color3.new(1, 1, 1)
shootKeyLabel.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
shootKeyLabel.TextScaled = true
shootKeyLabel.ZIndex = 3
shootKeyLabel.Parent = shootButton

shootButton.MouseButton1Click:Connect(doShoot)

-- GODSPEED FLASH BUTTON (N)
local flashButton = Instance.new("ImageButton")
flashButton.Name = "FlashButton"
flashButton.Size = UDim2.new(0, 74, 0, 74)
flashButton.BackgroundTransparency = 1
flashButton.Image = "rbxassetid://94420981449604"
flashButton.ZIndex = 1
flashButton.Parent = abilities

local flashText = Instance.new("TextLabel")
flashText.Name = "FlashText"
flashText.Size = UDim2.new(1, -10, 1, -10)
flashText.Position = UDim2.new(0, 5, 0, 5)
flashText.BackgroundTransparency = 1
flashText.Text = "Godspeed Flash"
flashText.TextColor3 = Color3.new(1, 1, 1)
flashText.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
flashText.TextScaled = true
flashText.TextWrapped = true
flashText.ZIndex = 2
flashText.Parent = flashButton

createOutlineLabel(-1, 0, flashButton, "N")
createOutlineLabel(1, 0, flashButton, "N")
createOutlineLabel(0, -1, flashButton, "N")
createOutlineLabel(0, 1, flashButton, "N")

local flashKeyLabel = Instance.new("TextLabel")
flashKeyLabel.Name = "KeyLabel"
flashKeyLabel.Size = UDim2.new(0, 22, 0, 22)
flashKeyLabel.Position = UDim2.new(0, 0, 0, 3)
flashKeyLabel.AnchorPoint = Vector2.new(0, 0.5)
flashKeyLabel.BackgroundTransparency = 1
flashKeyLabel.Text = "N"
flashKeyLabel.TextColor3 = Color3.new(1, 1, 1)
flashKeyLabel.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
flashKeyLabel.TextScaled = true
flashKeyLabel.ZIndex = 3
flashKeyLabel.Parent = flashButton

flashButton.MouseButton1Click:Connect(flashTeleport)

-- GALAXY CURVE BUTTON (F)
local curveButton = Instance.new("ImageButton")
curveButton.Name = "CurveButton"
curveButton.Size = UDim2.new(0, 74, 0, 74)
curveButton.BackgroundTransparency = 1
curveButton.Image = "rbxassetid://94420981449604"
curveButton.ZIndex = 1
curveButton.Parent = abilities

local curveText = Instance.new("TextLabel")
curveText.Name = "CurveText"
curveText.Size = UDim2.new(1, -10, 1, -10)
curveText.Position = UDim2.new(0, 5, 0, 5)
curveText.BackgroundTransparency = 1
curveText.Text = "Galaxy Curve"
curveText.TextColor3 = Color3.new(1, 1, 1)
curveText.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
curveText.TextScaled = true
curveText.TextWrapped = true
curveText.ZIndex = 2
curveText.Parent = curveButton

createOutlineLabel(-1, 0, curveButton, "F")
createOutlineLabel(1, 0, curveButton, "F")
createOutlineLabel(0, -1, curveButton, "F")
createOutlineLabel(0, 1, curveButton, "F")

local curveKeyLabel = Instance.new("TextLabel")
curveKeyLabel.Name = "KeyLabel"
curveKeyLabel.Size = UDim2.new(0, 22, 0, 22)
curveKeyLabel.Position = UDim2.new(0, 0, 0, 3)
curveKeyLabel.AnchorPoint = Vector2.new(0, 0.5)
curveKeyLabel.BackgroundTransparency = 1
curveKeyLabel.Text = "F"
curveKeyLabel.TextColor3 = Color3.new(1, 1, 1)
curveKeyLabel.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
curveKeyLabel.TextScaled = true
curveKeyLabel.ZIndex = 3
curveKeyLabel.Parent = curveButton

curveButton.MouseButton1Click:Connect(doGalaxyCurve)

-- PROTECT BALL BUTTON (Y)
local protectButton = Instance.new("ImageButton")
protectButton.Name = "ProtectButton"
protectButton.Size = UDim2.new(0, 74, 0, 74)
protectButton.BackgroundTransparency = 1
protectButton.Image = "rbxassetid://94420981449604"
protectButton.ZIndex = 1
protectButton.Parent = abilities

local protectText = Instance.new("TextLabel")
protectText.Name = "ProtectText"
protectText.Size = UDim2.new(1, -10, 1, -10)
protectText.Position = UDim2.new(0, 5, 0, 5)
protectText.BackgroundTransparency = 1
protectText.Text = "Protect Ball"
protectText.TextColor3 = Color3.new(1, 1, 1)
protectText.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
protectText.TextScaled = true
protectText.TextWrapped = true
protectText.ZIndex = 2
protectText.Parent = protectButton

createOutlineLabel(-1, 0, protectButton, "Y")
createOutlineLabel(1, 0, protectButton, "Y")
createOutlineLabel(0, -1, protectButton, "Y")
createOutlineLabel(0, 1, protectButton, "Y")

local protectKeyLabel = Instance.new("TextLabel")
protectKeyLabel.Name = "KeyLabel"
protectKeyLabel.Size = UDim2.new(0, 22, 0, 22)
protectKeyLabel.Position = UDim2.new(0, 0, 0, 3)
protectKeyLabel.AnchorPoint = Vector2.new(0, 0.5)
protectKeyLabel.BackgroundTransparency = 1
protectKeyLabel.Text = "Y"
protectKeyLabel.TextColor3 = Color3.new(1, 1, 1)
protectKeyLabel.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
protectKeyLabel.TextScaled = true
protectKeyLabel.ZIndex = 3
protectKeyLabel.Parent = protectButton

protectButton.MouseButton1Click:Connect(protectBall)

-- REVERSE BALL BUTTON (G)
local reverseButton = Instance.new("ImageButton")
reverseButton.Name = "ReverseButton"
reverseButton.Size = UDim2.new(0, 74, 0, 74)
reverseButton.BackgroundTransparency = 1
reverseButton.Image = "rbxassetid://94420981449604"
reverseButton.ZIndex = 1
reverseButton.Parent = abilities

local reverseText = Instance.new("TextLabel")
reverseText.Name = "ReverseText"
reverseText.Size = UDim2.new(1, -10, 1, -10)
reverseText.Position = UDim2.new(0, 5, 0, 5)
reverseText.BackgroundTransparency = 1
reverseText.Text = "Reverse Ball"
reverseText.TextColor3 = Color3.new(1, 1, 1)
reverseText.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
reverseText.TextScaled = true
reverseText.TextWrapped = true
reverseText.ZIndex = 2
reverseText.Parent = reverseButton

createOutlineLabel(-1, 0, reverseButton, "G")
createOutlineLabel(1, 0, reverseButton, "G")
createOutlineLabel(0, -1, reverseButton, "G")
createOutlineLabel(0, 1, reverseButton, "G")

local reverseKeyLabel = Instance.new("TextLabel")
reverseKeyLabel.Name = "KeyLabel"
reverseKeyLabel.Size = UDim2.new(0, 22, 0, 22)
reverseKeyLabel.Position = UDim2.new(0, 0, 0, 3)
reverseKeyLabel.AnchorPoint = Vector2.new(0, 0.5)
reverseKeyLabel.BackgroundTransparency = 1
reverseKeyLabel.Text = "G"
reverseKeyLabel.TextColor3 = Color3.new(1, 1, 1)
reverseKeyLabel.FontFace = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.ExtraBold,
    Enum.FontStyle.Normal
)
reverseKeyLabel.TextScaled = true
reverseKeyLabel.ZIndex = 3
reverseKeyLabel.Parent = reverseButton

reverseButton.MouseButton1Click:Connect(reverseBall)

-- Keybinds listener (optional)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.Z then
            doShoot()
        elseif key == Enum.KeyCode.N then
            flashTeleport()
        elseif key == Enum.KeyCode.F then
            doGalaxyCurve()
        elseif key == Enum.KeyCode.Y then
            protectBall()
        elseif key == Enum.KeyCode.G then
            reverseBall()
        end
    end
end)
