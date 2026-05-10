local ScriptSelectorLib = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local DefaultConfig = {
    WindowSize = UDim2.new(0, 400, 0, 360),
    WindowCornerRadius = 10,
    WindowStrokeThickness = 1.2,
    ProfileColumnWidth = 100,
    AvatarSize = 70,
    AvatarYOffset = 20,
    ContentXOffset = 103,
    ContentWidthOffset = -105,
    ButtonHeight = 32,
    ButtonWidth = 0.9,
    ButtonCornerRadius = 5,
    ButtonMarginX = 10,
    ToggleBgSize = 34,
    ToggleBgHeight = 16,
    ToggleCircleSize = 12,
    SliderHeight = 32,
    SliderTrackHeight = 2,
    SliderKnobSize = 8,
    ColumnGap = 0.52,
    ColumnWidth = 0.48,
    ColumnCornerRadius = 6,
    ColumnStrokeThickness = 1,
    ColumnMinHeight = 60,
    ColumnPadding = 8,
    Colors = {
        Background = Color3.fromRGB(8, 8, 8),
        ProfileColumn = Color3.fromRGB(12, 12, 12),
        AvatarBg = Color3.fromRGB(18, 18, 18),
        ButtonBg = Color3.fromRGB(15, 15, 15),
        ButtonHover = Color3.fromRGB(25, 25, 25),
        Stroke = Color3.fromRGB(25, 25, 25),
        ColumnBg = Color3.fromRGB(12, 12, 12),
        ColumnStroke = Color3.fromRGB(30, 30, 30),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(130, 130, 130),
        SnowColor = Color3.fromRGB(255, 255, 255),
    }
}

local function SmoothTween(obj, time, properties)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local Column = {}
Column.__index = Column

function Column.new(title, parent, position, config)
    local self = setmetatable({}, Column)
    self.config = config or DefaultConfig
    self.Buttons = {}
    
    self.Frame = Instance.new("Frame")
    self.Frame.Parent = parent
    self.Frame.BackgroundColor3 = self.config.Colors.ColumnBg
    self.Frame.BorderSizePixel = 0
    self.Frame.Position = position
    self.Frame.Size = UDim2.new(self.config.ColumnWidth, 0, 0, self.config.ColumnMinHeight)
    self.Frame.ClipsDescendants = true
    
    local columnCorner = Instance.new("UICorner")
    columnCorner.Parent = self.Frame
    columnCorner.CornerRadius = UDim.new(0, self.config.ColumnCornerRadius)
    
    local columnStroke = Instance.new("UIStroke")
    columnStroke.Parent = self.Frame
    columnStroke.Color = self.config.Colors.ColumnStroke
    columnStroke.Thickness = self.config.ColumnStrokeThickness
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Parent = self.Frame
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = title
    self.TitleLabel.Position = UDim2.new(0.5, 0, 0, 6)
    self.TitleLabel.Size = UDim2.new(1, 0, 0, 18)
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextColor3 = self.config.Colors.TextPrimary
    self.TitleLabel.TextSize = 12
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    self.TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
    
    self.Content = Instance.new("ScrollingFrame")
    self.Content.Parent = self.Frame
    self.Content.BackgroundTransparency = 1
    self.Content.Position = UDim2.new(0, 0, 0, 28)
    self.Content.Size = UDim2.new(1, 0, 1, -28)
    self.Content.ScrollBarThickness = 0
    self.Content.BorderSizePixel = 0
    self.Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local padding = Instance.new("UIPadding")
    padding.Parent = self.Content
    padding.PaddingTop = UDim.new(0, self.config.ColumnPadding)
    padding.PaddingBottom = UDim.new(0, self.config.ColumnPadding)
    
    self.Layout = Instance.new("UIListLayout")
    self.Layout.Parent = self.Content
    self.Layout.Padding = UDim.new(0, 6)
    self.Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local function updateHeight()
        local contentHeight = self.Layout.AbsoluteContentSize.Y + self.config.ColumnPadding * 2
        local newHeight = math.max(contentHeight + 32, self.config.ColumnMinHeight)
        self.Frame.Size = UDim2.new(self.config.ColumnWidth, 0, 0, newHeight)
        if self.onHeightChanged then
            self.onHeightChanged()
        end
    end
    
    self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
    task.wait(0.05)
    updateHeight()
    
    return self
end

function Column:AddToggle(name, callback)
    local config = self.config
    local button = Instance.new("TextButton")
    button.Parent = self.Content
    button.BackgroundColor3 = config.Colors.ButtonBg
    button.Size = UDim2.new(config.ButtonWidth, 0, 0, config.ButtonHeight)
    button.Text = ""
    button.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = button
    btnCorner.CornerRadius = UDim.new(0, config.ButtonCornerRadius)
    
    local toggleState = false
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Parent = button
    toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggleBg.Size = UDim2.new(0, config.ToggleBgSize, 0, config.ToggleBgHeight)
    toggleBg.Position = UDim2.new(1, -config.ButtonMarginX, 0.5, 0)
    toggleBg.AnchorPoint = Vector2.new(1, 0.5)
    
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.Parent = toggleBg
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Parent = toggleBg
    toggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    toggleCircle.Size = UDim2.new(0, config.ToggleCircleSize, 0, config.ToggleCircleSize)
    toggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    
    local toggleCircleCorner = Instance.new("UICorner")
    toggleCircleCorner.Parent = toggleCircle
    toggleCircleCorner.CornerRadius = UDim.new(1, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = button
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.Position = UDim2.new(0, config.ButtonMarginX, 0.5, 0)
    textLabel.Size = UDim2.new(1, -55, 0, 16)
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextColor3 = config.Colors.TextPrimary
    textLabel.TextSize = 11
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.AnchorPoint = Vector2.new(0, 0.5)
    
    local function updateToggle(active)
        toggleState = active
        if active then
            toggleBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.Position = UDim2.new(1, -2, 0.5, 0)
            toggleCircle.AnchorPoint = Vector2.new(1, 0.5)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            toggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
            toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
        end
        if callback then
            callback(active)
        end
    end
    
    button.MouseEnter:Connect(function()
        SmoothTween(button, 0.15, {BackgroundColor3 = config.Colors.ButtonHover})
    end)
    
    button.MouseLeave:Connect(function()
        SmoothTween(button, 0.15, {BackgroundColor3 = config.Colors.ButtonBg})
    end)
    
    button.MouseButton1Click:Connect(function()
        updateToggle(not toggleState)
    end)
    
    updateToggle(false)
    
    table.insert(self.Buttons, {
        type = "toggle",
        button = button,
        setValue = updateToggle,
        getValue = function() return toggleState end
    })
    
    return self.Buttons[#self.Buttons]
end

function Column:AddSlider(name, minVal, maxVal, defaultVal, callback)
    local config = self.config
    local frame = Instance.new("Frame")
    frame.Parent = self.Content
    frame.BackgroundColor3 = config.Colors.ButtonBg
    frame.Size = UDim2.new(config.ButtonWidth, 0, 0, config.SliderHeight)
    frame.BackgroundTransparency = 0
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.Parent = frame
    frameCorner.CornerRadius = UDim.new(0, config.ButtonCornerRadius)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Text = name
    label.Position = UDim2.new(0, config.ButtonMarginX, 0, 6)
    label.Size = UDim2.new(0.5, 0, 0, 14)
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = config.Colors.TextPrimary
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(defaultVal))
    valueLabel.Position = UDim2.new(0.5, 0, 0, 6)
    valueLabel.Size = UDim2.new(0.4, -config.ButtonMarginX, 0, 14)
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextColor3 = config.Colors.TextSecondary
    valueLabel.TextSize = 10
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderBg.Size = UDim2.new(0.85, 0, 0, config.SliderTrackHeight)
    sliderBg.Position = UDim2.new(0.12, 0, 1, -8)
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.Parent = sliderBg
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BorderSizePixel = 0
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.Parent = sliderFill
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Parent = sliderBg
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.Size = UDim2.new(0, config.SliderKnobSize, 0, config.SliderKnobSize)
    sliderKnob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -4, 0.5, 0)
    sliderKnob.AnchorPoint = Vector2.new(0, 0.5)
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.Parent = sliderKnob
    knobCorner.CornerRadius = UDim.new(1, 0)
    
    local currentValue = defaultVal
    local dragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, minVal, maxVal)
        value = math.floor(value)
        if value == currentValue then return end
        currentValue = value
        valueLabel.Text = tostring(currentValue)
        local percent = (currentValue - minVal) / (maxVal - minVal)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderKnob.Position = UDim2.new(percent, -4, 0.5, 0)
        if callback then
            callback(currentValue)
        end
    end
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderWidth = sliderBg.AbsoluteSize.X
            if sliderWidth > 0 then
                local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
                local newValue = minVal + (maxVal - minVal) * percent
                updateSlider(newValue)
            end
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderWidth = sliderBg.AbsoluteSize.X
            if sliderWidth > 0 then
                local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
                local newValue = minVal + (maxVal - minVal) * percent
                updateSlider(newValue)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    updateSlider(defaultVal)
    
    table.insert(self.Buttons, {
        type = "slider",
        frame = frame,
        setValue = updateSlider,
        getValue = function() return currentValue end
    })
    
    return self.Buttons[#self.Buttons]
end

local Window = {}
Window.__index = Window

function ScriptSelectorLib:CreateWindow(config)
    local self = setmetatable({}, Window)
    self.config = config or {}
    
    for k, v in pairs(DefaultConfig) do
        if self.config[k] == nil then
            self.config[k] = v
        end
    end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = config.Name or "ScriptSelectorGUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self.snowContainer = nil
    self.snowflakes = {}
    self.renderConnection = nil
    self.renderConnection2 = nil
    self.isVisible = true
    
    self.columns = {}
    self.columnsContainer = nil
    
    self:_createSnowflakes()
    self:_createMainFrame()
    self:_createProfileColumn()
    self:_createContentFrame()
    self:_createColumnsContainer()
    self:_setupKeybind()
    
    return self
end

function Window:_createSnowflakes()
    self.snowContainer = Instance.new("Frame")
    self.snowContainer.Parent = self.ScreenGui
    self.snowContainer.BackgroundTransparency = 1
    self.snowContainer.Size = UDim2.new(1, 0, 1, 0)
    self.snowContainer.ZIndex = 0
    
    for i = 1, 150 do
        local snowflake = Instance.new("ImageLabel")
        snowflake.Parent = self.snowContainer
        snowflake.BackgroundTransparency = 1
        local size = math.random(3, 8)
        snowflake.Size = UDim2.new(0, size, 0, size)
        snowflake.Image = "rbxassetid://6031091000"
        snowflake.ImageColor3 = self.config.Colors.SnowColor
        snowflake.ImageTransparency = math.random(30, 70) / 100
        snowflake.ZIndex = 0
        
        local xPos = math.random(0, 100)
        local yPos = math.random(-50, 100)
        snowflake.Position = UDim2.new(xPos / 100, 0, yPos / 100, 0)
        
        table.insert(self.snowflakes, {
            obj = snowflake,
            speed = math.random(20, 60),
            drift = math.random(-30, 30) / 100,
            xPos = xPos,
            yPos = yPos,
            rotationSpeed = math.random(-2, 2),
            rotation = math.random(0, 360)
        })
    end
    
    self.renderConnection = RunService.RenderStepped:Connect(function(dt)
        local dtClamped = math.min(dt, 0.033)
        for _, snow in ipairs(self.snowflakes) do
            snow.yPos = snow.yPos + (snow.speed * dtClamped)
            snow.xPos = snow.xPos + (snow.drift * dtClamped)
            snow.rotation = snow.rotation + snow.rotationSpeed
            
            if snow.yPos > 100 then
                snow.yPos = -10
                snow.xPos = math.random(0, 100)
            end
            
            if snow.xPos > 100 then
                snow.xPos = 0
            elseif snow.xPos < 0 then
                snow.xPos = 100
            end
            
            local obj = snow.obj
            if obj then
                obj.Position = UDim2.new(snow.xPos / 100, 0, snow.yPos / 100, 0)
                obj.Rotation = snow.rotation
            end
        end
    end)
end

function Window:_createMainFrame()
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.BackgroundColor3 = self.config.Colors.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.BackgroundTransparency = 1
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.Parent = self.MainFrame
    FrameCorner.CornerRadius = UDim.new(0, self.config.WindowCornerRadius)
    
    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Parent = self.MainFrame
    FrameStroke.Color = self.config.Colors.Stroke
    FrameStroke.Thickness = self.config.WindowStrokeThickness
    
    self.dragData = {
        dragging = false,
        dragStart = nil,
        startPos = nil,
        targetPos = nil
    }
end

function Window:_createProfileColumn()
    local ProfileColumn = Instance.new("Frame")
    ProfileColumn.Parent = self.MainFrame
    ProfileColumn.BackgroundColor3 = self.config.Colors.ProfileColumn
    ProfileColumn.BorderSizePixel = 0
    ProfileColumn.Size = UDim2.new(0, self.config.ProfileColumnWidth, 1, 0)
    ProfileColumn.Position = UDim2.new(0, 0, 0, 0)
    
    local ProfileColumnCorner = Instance.new("UICorner")
    ProfileColumnCorner.Parent = ProfileColumn
    ProfileColumnCorner.CornerRadius = UDim.new(0, 10)
    
    local AvatarCircle = Instance.new("ImageLabel")
    AvatarCircle.Parent = ProfileColumn
    AvatarCircle.BackgroundColor3 = self.config.Colors.AvatarBg
    AvatarCircle.BackgroundTransparency = 0
    AvatarCircle.Size = UDim2.new(0, self.config.AvatarSize, 0, self.config.AvatarSize)
    AvatarCircle.Position = UDim2.new(0.5, 0, 0, self.config.AvatarYOffset)
    AvatarCircle.AnchorPoint = Vector2.new(0.5, 0)
    AvatarCircle.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.Parent = AvatarCircle
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    
    local PlayerName = Instance.new("TextLabel")
    PlayerName.Parent = ProfileColumn
    PlayerName.BackgroundTransparency = 1
    PlayerName.Text = LocalPlayer.DisplayName
    PlayerName.Position = UDim2.new(0.5, 0, 0, 100)
    PlayerName.AnchorPoint = Vector2.new(0.5, 0)
    PlayerName.Size = UDim2.new(0, 90, 0, 20)
    PlayerName.Font = Enum.Font.GothamBold
    PlayerName.TextColor3 = self.config.Colors.TextPrimary
    PlayerName.TextSize = 12
    PlayerName.TextXAlignment = Enum.TextXAlignment.Center
    PlayerName.TextWrapped = true
    
    local PlayerUsername = Instance.new("TextLabel")
    PlayerUsername.Parent = ProfileColumn
    PlayerUsername.BackgroundTransparency = 1
    PlayerUsername.Text = "@" .. LocalPlayer.Name
    PlayerUsername.Position = UDim2.new(0.5, 0, 0, 122)
    PlayerUsername.AnchorPoint = Vector2.new(0.5, 0)
    PlayerUsername.Size = UDim2.new(0, 90, 0, 15)
    PlayerUsername.Font = Enum.Font.GothamMedium
    PlayerUsername.TextColor3 = self.config.Colors.TextSecondary
    PlayerUsername.TextSize = 10
    PlayerUsername.TextXAlignment = Enum.TextXAlignment.Center
    PlayerUsername.TextWrapped = true
    
    local ProfileDivider = Instance.new("Frame")
    ProfileDivider.Parent = self.MainFrame
    ProfileDivider.BackgroundColor3 = self.config.Colors.Stroke
    ProfileDivider.BorderSizePixel = 0
    ProfileDivider.Position = UDim2.new(0, self.config.ProfileColumnWidth, 0, 0)
    ProfileDivider.Size = UDim2.new(0, 1, 1, 0)
end

function Window:_createContentFrame()
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = self.MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, self.config.ContentXOffset, 0, 0)
    ContentFrame.Size = UDim2.new(1, self.config.ContentWidthOffset, 1, 0)
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = ContentFrame
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local function EnableDragging(dragPart, frameToMove)
        dragPart.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.dragData.dragging = true
                self.dragData.dragStart = input.Position
                self.dragData.startPos = frameToMove.Position
                self.dragData.targetPos = frameToMove.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        self.dragData.dragging = false
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and self.dragData.dragging and self.dragData.dragStart and self.dragData.startPos then
                local delta = input.Position - self.dragData.dragStart
                self.dragData.targetPos = UDim2.new(
                    self.dragData.startPos.X.Scale,
                    self.dragData.startPos.X.Offset + delta.X,
                    self.dragData.startPos.Y.Scale,
                    self.dragData.startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    EnableDragging(TitleBar, self.MainFrame)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.config.Name or "SCRIPT SELECTOR"
    TitleLabel.Position = UDim2.new(0, 15, 0.5, 0)
    TitleLabel.Size = UDim2.new(0, 200, 0, 20)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = self.config.Colors.TextPrimary
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
    
    local DividerFrame = Instance.new("Frame")
    DividerFrame.Parent = ContentFrame
    DividerFrame.BackgroundColor3 = self.config.Colors.Stroke
    DividerFrame.BorderSizePixel = 0
    DividerFrame.Position = UDim2.new(0.5, 0, 0, 50)
    DividerFrame.AnchorPoint = Vector2.new(0.5, 0)
    DividerFrame.Size = UDim2.new(0.9, 0, 0, 1)
    
    self.ContentFrame = ContentFrame
    
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Parent = ContentFrame
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Position = UDim2.new(1, -15, 1, -15)
    VersionLabel.Size = UDim2.new(0, 50, 0, 20)
    VersionLabel.Font = Enum.Font.GothamMedium
    VersionLabel.Text = "v1.0"
    VersionLabel.TextColor3 = self.config.Colors.TextSecondary
    VersionLabel.TextSize = 10
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.AnchorPoint = Vector2.new(1, 1)
    
    self.targetSize = self.config.WindowSize
    self.lerpSpeed = 0.15
    self.animationActive = true
    self.originalSize = self.targetSize
    
    self.renderConnection2 = RunService.RenderStepped:Connect(function()
        if self.dragData.dragging and self.dragData.targetPos then
            local currentPos = self.MainFrame.Position
            local newX = currentPos.X.Offset + (self.dragData.targetPos.X.Offset - currentPos.X.Offset) * self.lerpSpeed
            local newY = currentPos.Y.Offset + (self.dragData.targetPos.Y.Offset - currentPos.Y.Offset) * self.lerpSpeed
            self.MainFrame.Position = UDim2.new(currentPos.X.Scale, newX, currentPos.Y.Scale, newY)
        end
        
        if self.animationActive and self.MainFrame.Size ~= self.targetSize then
            local currentW = self.MainFrame.Size.X.Offset
            local currentH = self.MainFrame.Size.Y.Offset
            local newW = currentW + (self.targetSize.X.Offset - currentW) * self.lerpSpeed
            local newH = currentH + (self.targetSize.Y.Offset - currentH) * self.lerpSpeed
            self.MainFrame.Size = UDim2.new(0, newW, 0, newH)
            
            local alpha = self.MainFrame.Size.X.Offset / self.targetSize.X.Offset
            self.MainFrame.BackgroundTransparency = 1 - alpha
            FrameStroke.Transparency = 1 - alpha
        end
    end)
end

function Window:_createColumnsContainer()
    self.columnsContainer = Instance.new("Frame")
    self.columnsContainer.Parent = self.ContentFrame
    self.columnsContainer.BackgroundTransparency = 1
    self.columnsContainer.Position = UDim2.new(0.5, 0, 0, 60)
    self.columnsContainer.AnchorPoint = Vector2.new(0.5, 0)
    self.columnsContainer.Size = UDim2.new(0.95, 0, 0, 0)
end

function Window:_setupKeybind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            self.isVisible = not self.isVisible
            if self.isVisible then
                self.targetSize = self.originalSize
                self.animationActive = true
            else
                self.targetSize = UDim2.new(0, 0, 0, 0)
                self.animationActive = true
            end
        end
    end)
end

function Window:CreateColumn(title, position)
    local column = Column.new(title, self.columnsContainer, position, self.config)
    
    local function updateContainerHeight()
        local maxHeight = 0
        for _, col in pairs(self.columns) do
            local height = col.Frame.Size.Y.Offset
            if height > maxHeight then
                maxHeight = height
            end
        end
        self.columnsContainer.Size = UDim2.new(0.95, 0, 0, maxHeight)
        local newWindowHeight = 340 + maxHeight
        self.targetSize = UDim2.new(0, 400, 0, newWindowHeight)
        self.originalSize = self.targetSize
    end
    
    column.onHeightChanged = updateContainerHeight
    table.insert(self.columns, column)
    updateContainerHeight()
    
    return column
end

function Window:Show()
    local showTween = TweenService:Create(self.MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = self.targetSize
    })
    showTween:Play()
end

function Window:Destroy()
    if self.renderConnection then
        self.renderConnection:Disconnect()
    end
    if self.renderConnection2 then
        self.renderConnection2:Disconnect()
    end
    if self.snowContainer then
        self.snowContainer:Destroy()
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    for _, snow in ipairs(self.snowflakes) do
        if snow and snow.obj then
            snow.obj:Destroy()
        end
    end
end

return ScriptSelectorLib
