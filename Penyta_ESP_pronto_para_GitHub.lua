-- Piñata ESP | Strongest Burger
-- Xeno | Interface com minimizar, fechar e arrastar

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ESP_ENABLED = true
local NOTIFY_ENABLED = true
local currentTarget = nil
local notifiedTarget = nil
local closed = false
local minimized = false

-- Remove uma interface anterior, caso o script seja executado novamente.
local previous = playerGui:FindFirstChild("PenytaESP")
if previous then
    previous:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "PenytaESP"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

-- Janela principal
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.new(0, 230, 0, 125)
frame.Position = UDim2.new(0, 20, 0.5, -62)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Barra superior / área de arraste
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -72, 0, 35)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "HALLOWEEN  |  PIÑATA"
title.TextColor3 = Color3.fromRGB(255, 145, 45)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = frame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "Minimize"
minimizeButton.Size = UDim2.new(0, 28, 0, 27)
minimizeButton.Position = UDim2.new(1, -64, 0, 4)
minimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.TextSize = 17
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.new(0, 28, 0, 27)
closeButton.Position = UDim2.new(1, -32, 0, 4)
closeButton.BackgroundColor3 = Color3.fromRGB(145, 45, 45)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 13
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = frame

for _, button in ipairs({minimizeButton, closeButton}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

-- Notificação central
local notification = Instance.new("TextLabel")
notification.Name = "Notification"
notification.Size = UDim2.new(0, 350, 0, 55)
notification.Position = UDim2.new(0.5, -175, 0.12, 0)
notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
notification.TextColor3 = Color3.fromRGB(255, 160, 60)
notification.Font = Enum.Font.GothamBold
notification.TextSize = 17
notification.Text = "PIÑATA ENCONTRADA!"
notification.Visible = false
notification.Parent = gui

local notificationCorner = Instance.new("UICorner")
notificationCorner.CornerRadius = UDim.new(0, 10)
notificationCorner.Parent = notification

local notificationVersion = 0
local function notify()
    if not NOTIFY_ENABLED or closed then
        return
    end

    notificationVersion += 1
    local thisVersion = notificationVersion

    notification.Text = "PIÑATA ENCONTRADA!"
    notification.Visible = true

    task.delay(5, function()
        if not closed and notificationVersion == thisVersion and notification.Parent then
            notification.Visible = false
        end
    end)
end

local function removeESP()
    if currentTarget then
        local highlight = currentTarget:FindFirstChild("PenytaHighlight")
        local billboard = currentTarget:FindFirstChild("PenytaBillboard")

        if highlight then
            highlight:Destroy()
        end
        if billboard then
            billboard:Destroy()
        end
    end

    currentTarget = nil
end

local function addESP(model)
    if not ESP_ENABLED or closed or not model or not model:IsA("Model") then
        return
    end

    local part = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Head")
        or model.PrimaryPart

    if not part then
        return
    end

    removeESP()
    currentTarget = model

    local highlight = Instance.new("Highlight")
    highlight.Name = "PenytaHighlight"
    highlight.FillColor = Color3.fromRGB(255, 130, 35)
    highlight.OutlineColor = Color3.fromRGB(255, 220, 150)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PenytaBillboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 180, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Name = "DistanceLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 165, 65)
    label.TextStrokeTransparency = 0.2
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.Text = "PIÑATA"
    label.Parent = billboard

    notify()
end

-- Botões de controle
local function makeButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 195, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Text = text
    button.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        callback(button)
    end)

    return button
end

local espButton = makeButton(
    "ESPButton",
    "ESP: LIGADO",
    UDim2.new(0, 17, 0, 43),
    function(button)
        ESP_ENABLED = not ESP_ENABLED
        button.Text = ESP_ENABLED and "ESP: LIGADO" or "ESP: DESLIGADO"

        if ESP_ENABLED then
            local live = Workspace:FindFirstChild("Live")
            local target = live and live:FindFirstChild("Penyta")
            if target then
                addESP(target)
            end
        else
            removeESP()
        end
    end
)

local notifyButton = makeButton(
    "NotificationButton",
    "NOTIFICAÇÕES: LIGADAS",
    UDim2.new(0, 17, 0, 80),
    function(button)
        NOTIFY_ENABLED = not NOTIFY_ENABLED
        button.Text = NOTIFY_ENABLED
            and "NOTIFICAÇÕES: LIGADAS"
            or "NOTIFICAÇÕES: DESLIGADAS"

        if not NOTIFY_ENABLED then
            notification.Visible = false
        end
    end
)

-- Minimizar / restaurar
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized

    frame.Size = minimized
        and UDim2.new(0, 230, 0, 35)
        or UDim2.new(0, 230, 0, 125)

    espButton.Visible = not minimized
    notifyButton.Visible = not minimized
    minimizeButton.Text = minimized and "+" or "—"
end)

-- Fechar e limpar
local renderConnection
local childAddedConnection

closeButton.MouseButton1Click:Connect(function()
    if closed then
        return
    end

    closed = true
    ESP_ENABLED = false
    removeESP()

    if renderConnection then
        renderConnection:Disconnect()
    end
    if childAddedConnection then
        childAddedConnection:Disconnect()
    end

    gui:Destroy()
end)

-- Arrastar pela barra de título
local dragging = false
local dragInput = nil
local dragStart = nil
local startPosition = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

-- Detectar a piñata que já existe ou que aparecer depois.
local live = Workspace:WaitForChild("Live", 10)

if live then
    childAddedConnection = live.ChildAdded:Connect(function(child)
        if child.Name == "Penyta" then
            task.wait(0.2)
            if not closed and child.Parent == live then
                notifiedTarget = child
                if ESP_ENABLED then
                    addESP(child)
                else
                    notify()
                end
            end
        end
    end)
end

-- Monitoramento e atualização da distância
renderConnection = RunService.RenderStepped:Connect(function()
    if closed then
        return
    end

    local currentLive = Workspace:FindFirstChild("Live")
    local target = currentLive and currentLive:FindFirstChild("Penyta")

    if target and target ~= notifiedTarget then
        notifiedTarget = target

        if ESP_ENABLED then
            addESP(target)
        else
            notify()
        end
    elseif not target then
        notifiedTarget = nil
        removeESP()
    end

    if target and ESP_ENABLED and currentTarget ~= target then
        addESP(target)
    end

    if currentTarget and currentTarget.Parent then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local part = currentTarget:FindFirstChild("HumanoidRootPart")
            or currentTarget:FindFirstChild("Head")
        local billboard = currentTarget:FindFirstChild("PenytaBillboard")
        local label = billboard and billboard:FindFirstChild("DistanceLabel")

        if root and part and label then
            local distance = math.floor((root.Position - part.Position).Magnitude)
            label.Text = "PIÑATA  |  " .. distance .. "m"
        end
    end
end)
