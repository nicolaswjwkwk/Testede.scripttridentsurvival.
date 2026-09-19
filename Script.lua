--[[
    Educational Roblox UI template
    - Safe, local-only functionality
    - No remote scripts, no exploit APIs, no anti-cheat bypasses
    - Suitable for learning how to structure a client UI and world controls
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
    ui = {
        enabled = true,
        theme = "Dark",
        draggable = true,
    },
    world = {
        timeChanger = false,
        timeValue = Lighting.ClockTime,
    },
    watermark = {
        enabled = true,
        text = "Educational Client",
        color = Color3.fromRGB(126, 211, 255),
        accent = Color3.fromRGB(84, 132, 255),
    },
    fps = {
        enabled = true,
    },
}

local function safeFind(parent, name)
    if not parent then
        return nil
    end
    return parent:FindFirstChild(name)
end

local function safeWaitForChild(parent, name)
    if not parent then
        return nil
    end
    local child = parent:FindFirstChild(name)
    if child then
        return child
    end
    return parent:WaitForChild(name)
end

local function create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for key, value in pairs(properties or {}) do
        instance[key] = value
    end
    return instance
end

local function applyCornerRadius(object, radius)
    if typeof(radius) ~= "number" then
        radius = 8
    end

    local uiCorner = object:FindFirstChild("UICorner")
    if not uiCorner then
        uiCorner = create("UICorner", {
            Name = "UICorner",
            CornerRadius = UDim.new(0, radius),
        })
        uiCorner.Parent = object
    end
end

local function createButton(parent, text, size, position, callback)
    local button = create("TextButton", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(34, 37, 43),
        BorderSizePixel = 0,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
        Size = size,
        Position = position,
    })

    applyCornerRadius(button, 8)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(48, 53, 62)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(34, 37, 43)
    end)

    if callback then
        button.MouseButton1Click:Connect(callback)
    end

    return button
end

local function createToggle(parent, labelText, defaultValue, callback)
    local toggle = create("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(26, 28, 33),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 36),
    })
    applyCornerRadius(toggle, 8)

    local title = create("TextLabel", {
        Parent = toggle,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = labelText,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local state = defaultValue == true

    local button = create("TextButton", {
        Parent = toggle,
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundColor3 = state and Color3.fromRGB(52, 168, 83) or Color3.fromRGB(95, 99, 109),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -66, 0.5, -12),
        Size = UDim2.new(0, 52, 0, 24),
        Text = "",
    })
    applyCornerRadius(button, 12)

    local knob = create("Frame", {
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = state and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(0, 22, 0, 20),
    })
    applyCornerRadius(knob, 10)

    local function updateState(newState)
        state = newState
        button.BackgroundColor3 = newState and Color3.fromRGB(52, 168, 83) or Color3.fromRGB(95, 99, 109)
        local tween = TweenService:Create(
            knob,
            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = newState and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2) }
        )
        tween:Play()
        if callback then
            callback(newState)
        end
    end

    button.MouseButton1Click:Connect(function()
        updateState(not state)
    end)

    return {
        Value = function()
            return state
        end,
        Set = updateState,
    }
end

local function createSlider(parent, labelText, minValue, maxValue, defaultValue, callback)
    local sliderFrame = create("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(26, 28, 33),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 52),
    })
    applyCornerRadius(sliderFrame, 8)

    local title = create("TextLabel", {
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.Gotham,
        Text = labelText,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local bar = create("Frame", {
        Parent = sliderFrame,
        BackgroundColor3 = Color3.fromRGB(62, 67, 75),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -24, 0, 8),
    })
    applyCornerRadius(bar, 4)

    local fill = create("Frame", {
        Parent = bar,
        BackgroundColor3 = Color3.fromRGB(126, 211, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
    })
    applyCornerRadius(fill, 4)

    local valueLabel = create("TextLabel", {
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 0),
        Size = UDim2.new(0, 40, 0, 18),
        Font = Enum.Font.Gotham,
        Text = tostring(defaultValue),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local currentValue = math.clamp(defaultValue, minValue, maxValue)
    local isDragging = false

    local function updateDisplay(value)
        local ratio = (value - minValue) / (maxValue - minValue)
        local width = math.clamp(ratio, 0, 1)
        fill.Size = UDim2.new(width, 0, 1, 0)
        valueLabel.Text = tostring(math.floor(value + 0.5))
        if callback then
            callback(value)
        end
    end

    local function updateFromInput(inputX)
        local absPosition = bar.AbsolutePosition.X
        local absSize = bar.AbsoluteSize.X
        local relative = math.clamp((inputX - absPosition) / absSize, 0, 1)
        local value = minValue + (maxValue - minValue) * relative
        currentValue = value
        updateDisplay(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateFromInput(input.Position.X)
        end
    end)

    bar.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    updateDisplay(currentValue)

    return {
        Set = function(newValue)
            currentValue = math.clamp(newValue, minValue, maxValue)
            updateDisplay(currentValue)
        end,
        Value = function()
            return currentValue
        end,
    }
end

local function createWindow(parent)
    local gui = create("ScreenGui", {
        Parent = parent,
        Name = "EducationalClientGui",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local panel = create("Frame", {
        Parent = gui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 540, 0, 360),
        BackgroundColor3 = Color3.fromRGB(17, 18, 22),
        BorderSizePixel = 0,
    })
    applyCornerRadius(panel, 16)

    local titleBar = create("Frame", {
        Parent = panel,
        BackgroundColor3 = Color3.fromRGB(24, 27, 33),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 32),
    })
    applyCornerRadius(titleBar, 16)

    local titleText = create("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Font = Enum.Font.GothamBold,
        Text = "Educational Client",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local closeButton = createButton(titleBar, "X", UDim2.new(0, 24, 0, 24), UDim2.new(1, -34, 0.5, -12), function()
        gui.Enabled = false
    end)

    local sidebar = create("Frame", {
        Parent = panel,
        BackgroundColor3 = Color3.fromRGB(21, 23, 28),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(0, 160, 1, -32),
    })

    local content = create("Frame", {
        Parent = panel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 32),
        Size = UDim2.new(1, -160, 1, -32),
    })

    local tabs = {}
    local activeTab = nil

    local function switchTab(tabName)
        for _, tab in ipairs(tabs) do
            tab.frame.Visible = (tab.name == tabName)
            tab.button.BackgroundColor3 = tab.name == tabName and Color3.fromRGB(48, 53, 62) or Color3.fromRGB(26, 28, 33)
        end
        activeTab = tabName
    end

    local function addTab(name, buildFunction)
        local button = createButton(sidebar, name, UDim2.new(1, -12, 0, 30), UDim2.new(0, 6, 0, (#tabs * 34) + 8), function()
            switchTab(name)
        end)

        local frame = create("Frame", {
            Parent = content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })

        local listLayout = create("UIListLayout", {
            Parent = frame,
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        local padding = create("UIPadding", {
            Parent = frame,
            PaddingLeft = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingBottom = UDim.new(0, 16),
        })

        local tab = {
            name = name,
            button = button,
            frame = frame,
        }
        table.insert(tabs, tab)

        if buildFunction then
            buildFunction(frame)
        end

        if #tabs == 1 then
            switchTab(name)
        end

        return frame
    end

    local dragStart
    local dragging = false

    if Settings.ui.draggable then
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
            end
        end)

        titleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                panel.Position = panel.Position + UDim2.new(0, delta.X, 0, delta.Y)
                dragStart = input.Position
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    return {
        instance = gui,
        addTab = addTab,
        switchTab = switchTab,
    }
end

local function createWorldTab(frame)
    create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "World",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local timeToggle = createToggle(frame, "Time changer", false, function(value)
        Settings.world.timeChanger = value
    end)
    timeToggle.Set(false)

    local timeSlider = createSlider(frame, "Clock time", 0, 24, Lighting.ClockTime, function(value)
        Settings.world.timeValue = value
    end)

    local timeResetButton = createButton(frame, "Reset to current time", UDim2.new(1, -16, 0, 30), UDim2.new(0, 0, 0, 0), function()
        Settings.world.timeValue = Lighting.ClockTime
        timeSlider.Set(Lighting.ClockTime)
    end)

    local updateTime = function()
        if Settings.world.timeChanger then
            Lighting.ClockTime = Settings.world.timeValue
        end
    end

    RunService.RenderStepped:Connect(function()
        updateTime()
    end)
end

local function createWatermarkTab(frame)
    create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "Watermark",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local enabledToggle = createToggle(frame, "Enable watermark", true, function(value)
        Settings.watermark.enabled = value
    end)
    enabledToggle.Set(true)

    local textInput = create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(26, 28, 33),
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 32),
        Text = "Educational Client",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderText = "Watermark text",
        Font = Enum.Font.Gotham,
        TextSize = 14,
    })
    applyCornerRadius(textInput, 8)

    textInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            Settings.watermark.text = textInput.Text or "Educational Client"
        end
    end)

    local watermarkText = create("TextLabel", {
        Parent = CoreGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 14),
        Size = UDim2.new(0, 200, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "Educational Client | 60 FPS",
        TextColor3 = Settings.watermark.color,
        TextStrokeTransparency = 0.3,
        TextSize = 16,
    })

    local fpsLabel = create("TextLabel", {
        Parent = CoreGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 44),
        Size = UDim2.new(0, 200, 0, 24),
        Font = Enum.Font.Gotham,
        Text = "FPS: 60",
        TextColor3 = Color3.fromRGB(206, 214, 224),
        TextSize = 12,
    })

    local fpsCounter = 0
    local fpsTimer = tick()
    local currentFps = 60

    RunService.RenderStepped:Connect(function()
        fpsCounter += 1
        if tick() - fpsTimer >= 1 then
            currentFps = fpsCounter
            fpsCounter = 0
            fpsTimer = tick()
        end

        if Settings.watermark.enabled then
            watermarkText.Visible = true
            watermarkText.Text = string.format("%s | %s FPS", Settings.watermark.text, currentFps)
            watermarkText.TextColor3 = Settings.watermark.color
            fpsLabel.Visible = true
            fpsLabel.Text = "FPS: " .. tostring(currentFps)
        else
            watermarkText.Visible = false
            fpsLabel.Visible = false
        end
    end)
end

local function createInfoTab(frame)
    create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "Info",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local description = create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 160),
        Font = Enum.Font.Gotham,
        Text = "This script is designed for educational and legitimate use in Roblox Studio.\n\nIt demonstrates:\n- UI creation\n- settings tables\n- toggles and sliders\n- world clock control\n- simple watermark and FPS display",
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    createButton(frame, "Open Developer Docs", UDim2.new(1, -16, 0, 30), UDim2.new(0, 0, 0, 0), function()
        print("Open Roblox developer documentation in your browser or Studio docs.")
    end)
end

local function main()
    local root = PlayerGui or CoreGui
    local window = createWindow(root)

    window.addTab("World", createWorldTab)
    window.addTab("Watermark", createWatermarkTab)
    window.addTab("Info", createInfoTab)

    return window
end

main()

print("Educational client initialized successfully.")
