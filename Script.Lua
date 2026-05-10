-- ============================================
-- SILVER UI LIBRARY
-- Professional and Safe UI Library for Roblox
-- ============================================

local SilverUILibrary = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Release = "1.0"
local ConfigurationFolder = "SilverUI/Configurations"
local ConfigurationExtension = ".suicfg"

local Themes = {
	Default = {
		TextColor = Color3.fromRGB(240, 240, 240),
		Background = Color3.fromRGB(25, 25, 25),
		Topbar = Color3.fromRGB(34, 34, 34),
		Shadow = Color3.fromRGB(15, 15, 15),
		ElementBackground = Color3.fromRGB(35, 35, 35),
		ElementHover = Color3.fromRGB(40, 40, 40),
		ElementStroke = Color3.fromRGB(50, 50, 50),
		ButtonBg = Color3.fromRGB(35, 35, 35),
		ButtonHover = Color3.fromRGB(45, 45, 45),
		SliderBg = Color3.fromRGB(45, 100, 150),
		SliderProgress = Color3.fromRGB(45, 100, 150),
		ToggleBg = Color3.fromRGB(30, 30, 30),
		ToggleEnabled = Color3.fromRGB(80, 200, 120),
		ToggleDisabled = Color3.fromRGB(100, 100, 100),
		InputBg = Color3.fromRGB(30, 30, 30),
		InputStroke = Color3.fromRGB(65, 65, 65),
	}
}

local SilverUI = game:GetObjects("rbxassetid://10804731440")[1]
SilverUI.Enabled = false

if gethui then
	SilverUI.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(SilverUI)
	SilverUI.Parent = CoreGui
else
	SilverUI.Parent = CoreGui
end

local Main = SilverUI.Main
local Topbar = Main.Topbar
local Elements = Main.Elements
local LoadingFrame = Main.LoadingFrame
local TabList = Main.TabList

SilverUI.DisplayOrder = 100
LoadingFrame.Version.Text = Release

local Notifications = SilverUI.Notifications
local SelectedTheme = Themes.Default
local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false

local function SaveConfiguration()
	if not CEnabled then return end
	local Data = {}
	for i, v in pairs(SilverUILibrary.Flags or {}) do
		Data[i] = v.CurrentValue or v.CurrentKeybind or v.CurrentOption
	end
	local success, encoded = pcall(HttpService.JSONEncode, HttpService, Data)
	if success then
		writefile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension, encoded)
	end
end

local function LoadConfiguration(Configuration)
	local success, Data = pcall(HttpService.JSONDecode, HttpService, Configuration)
	if success then
		for FlagName, FlagValue in pairs(Data) do
			if SilverUILibrary.Flags[FlagName] then
				SilverUILibrary.Flags[FlagName]:Set(FlagValue)
			end
		end
	end
end

local function SmoothTween(obj, time, properties)
	local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
	tween:Play()
	return tween
end

local function AddDraggingFunctionality(DragPoint, MainFrame)
	local dragging = false
	local dragInput, mousePos, framePos
	
	DragPoint.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	DragPoint.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			SmoothTween(MainFrame, 0.45, {
				Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
			})
		end
	end)
end

function SilverUILibrary:Notify(NotificationSettings)
	local Notification = Notifications.Template:Clone()
	Notification.Parent = Notifications
	Notification.Name = NotificationSettings.Title or "Notification"
	Notification.Visible = true
	Notification.Title.Text = NotificationSettings.Title or "Notification"
	Notification.Description.Text = NotificationSettings.Content or ""
	Notification.Icon.Image = NotificationSettings.Icon and ("rbxassetid://" .. NotificationSettings.Icon) or "rbxassetid://3944680095"
	Notification.Size = UDim2.new(0, 260, 0, 80)
	Notification.BackgroundTransparency = 1
	
	SmoothTween(Notification, 0.5, {Size = UDim2.new(0, 295, 0, 91), BackgroundTransparency = 0.2})
	Notification:TweenPosition(UDim2.new(0.5, 0, 0.915, 0), "Out", "Quint", 0.6, true)
	
	task.wait(NotificationSettings.Duration or 3.5)
	
	SmoothTween(Notification, 0.5, {Size = UDim2.new(0, 260, 0, 0), BackgroundTransparency = 1})
	SmoothTween(Notification.Title, 0.4, {TextTransparency = 1})
	SmoothTween(Notification.Description, 0.4, {TextTransparency = 1})
	SmoothTween(Notification.Icon, 0.4, {ImageTransparency = 1})
	task.wait(0.5)
	Notification:Destroy()
end

function SilverUILibrary:CreateWindow(Settings)
	Topbar.Title.Text = Settings.Name or "Silver UI"
	Main.Size = UDim2.new(0, 450, 0, 260)
	Main.Visible = true
	Main.BackgroundTransparency = 1
	LoadingFrame.Title.Text = Settings.LoadingTitle or "Silver UI Library"
	LoadingFrame.Subtitle.Text = Settings.LoadingSubtitle or "by Developer"
	LoadingFrame.Visible = true
	Topbar.Visible = false
	Elements.Visible = false
	
	if Settings.ConfigurationSaving and Settings.ConfigurationSaving.Enabled then
		CEnabled = true
		CFileName = Settings.ConfigurationSaving.FileName or tostring(game.PlaceId)
		ConfigurationFolder = Settings.ConfigurationSaving.FolderName or ConfigurationFolder
		if not isfolder(ConfigurationFolder) then
			makefolder(ConfigurationFolder)
		end
	end
	
	AddDraggingFunctionality(Topbar, Main)
	
	SilverUILibrary.Flags = {}
	
	LoadingFrame.Title.TextTransparency = 1
	LoadingFrame.Subtitle.TextTransparency = 1
	LoadingFrame.Version.TextTransparency = 1
	
	SmoothTween(Main, 0.5, {BackgroundTransparency = 0})
	SmoothTween(LoadingFrame.Title, 0.5, {TextTransparency = 0})
	SmoothTween(LoadingFrame.Subtitle, 0.5, {TextTransparency = 0})
	SmoothTween(LoadingFrame.Version, 0.5, {TextTransparency = 0})
	
	task.wait(0.8)
	
	SmoothTween(LoadingFrame.Title, 0.5, {TextTransparency = 1})
	SmoothTween(LoadingFrame.Subtitle, 0.5, {TextTransparency = 1})
	SmoothTween(LoadingFrame.Version, 0.5, {TextTransparency = 1})
	
	task.wait(0.3)
	
	SmoothTween(Main, 0.6, {Size = UDim2.new(0, 500, 0, 475)})
	Topbar.Visible = true
	Elements.Visible = true
	LoadingFrame.Visible = false
	
	SmoothTween(Topbar, 0.5, {BackgroundTransparency = 0})
	SmoothTween(Topbar.Title, 0.5, {TextTransparency = 0})
	
	for _, btn in ipairs(Topbar:GetChildren()) do
		if btn.ClassName == "ImageButton" then
			SmoothTween(btn, 0.5, {ImageTransparency = 0.7})
		end
	end
	
	local Window = {}
	
	function Window:CreateTab(Name, Image)
		local TabButton = TabList.Template:Clone()
		TabButton.Name = Name
		TabButton.Title.Text = Name
		TabButton.Parent = TabList
		TabButton.Visible = true
		TabButton.BackgroundTransparency = 1
		TabButton.Title.TextTransparency = 1
		
		if Image then
			TabButton.Image.Image = "rbxassetid://" .. Image
			TabButton.Image.Visible = true
			TabButton.Title.Position = UDim2.new(0, 37, 0.5, 0)
			TabButton.Title.TextXAlignment = Enum.TextXAlignment.Left
		end
		
		local TabPage = Elements.Template:Clone()
		TabPage.Name = Name
		TabPage.Visible = true
		TabPage.Parent = Elements
		
		for _, child in ipairs(TabPage:GetChildren()) do
			if child.Name ~= "Placeholder" then
				child:Destroy()
			end
		end
		
		if #TabList:GetChildren() == 2 then
			Elements.UIPageLayout:JumpTo(TabPage)
			TabButton.BackgroundTransparency = 0
			TabButton.Title.TextTransparency = 0
			if Image then TabButton.Image.ImageTransparency = 0 end
		else
			TabButton.BackgroundTransparency = 0.7
			TabButton.Title.TextTransparency = 0.3
			if Image then TabButton.Image.ImageTransparency = 0.3 end
		end
		
		TabButton.Interact.MouseButton1Click:Connect(function()
			if Debounce then return end
			
			for _, otherBtn in ipairs(TabList:GetChildren()) do
				if otherBtn ~= TabButton and otherBtn.ClassName == "Frame" and otherBtn.Name ~= "Template" then
					SmoothTween(otherBtn, 0.4, {BackgroundTransparency = 0.7})
					SmoothTween(otherBtn.Title, 0.4, {TextTransparency = 0.3})
					if otherBtn.Image then SmoothTween(otherBtn.Image, 0.4, {ImageTransparency = 0.3}) end
				end
			end
			
			SmoothTween(TabButton, 0.4, {BackgroundTransparency = 0})
			SmoothTween(TabButton.Title, 0.4, {TextTransparency = 0})
			if Image then SmoothTween(TabButton.Image, 0.4, {ImageTransparency = 0}) end
			
			Elements.UIPageLayout:JumpTo(TabPage)
		end)
		
		local Tab = {}
		
		function Tab:CreateSection(SectionName)
			local Section = Instance.new("Frame")
			Section.Parent = TabPage
			Section.BackgroundTransparency = 1
			Section.Size = UDim2.new(1, -10, 0, 25)
			
			local Title = Instance.new("TextLabel")
			Title.Parent = Section
			Title.BackgroundTransparency = 1
			Title.Text = SectionName
			Title.Position = UDim2.new(0, 10, 0.5, 0)
			Title.Size = UDim2.new(1, -20, 0, 20)
			Title.Font = Enum.Font.GothamBold
			Title.TextColor3 = SelectedTheme.TextColor
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.AnchorPoint = Vector2.new(0, 0.5)
			
			return {Set = function(self, new) Title.Text = new end}
		end
		
		function Tab:CreateButton(ButtonSettings)
			local Button = Instance.new("TextButton")
			Button.Parent = TabPage
			Button.BackgroundColor3 = SelectedTheme.ButtonBg
			Button.Size = UDim2.new(1, -10, 0, 35)
			Button.Text = ButtonSettings.Name
			Button.Font = Enum.Font.GothamMedium
			Button.TextColor3 = SelectedTheme.TextColor
			Button.TextSize = 13
			Button.AutoButtonColor = false
			
			local Corner = Instance.new("UICorner")
			Corner.Parent = Button
			Corner.CornerRadius = UDim.new(0, 6)
			
			local Stroke = Instance.new("UIStroke")
			Stroke.Parent = Button
			Stroke.Color = SelectedTheme.ElementStroke
			Stroke.Thickness = 1
			
			Button.MouseEnter:Connect(function()
				SmoothTween(Button, 0.2, {BackgroundColor3 = SelectedTheme.ButtonHover})
			end)
			
			Button.MouseLeave:Connect(function()
				SmoothTween(Button, 0.2, {BackgroundColor3 = SelectedTheme.ButtonBg})
			end)
			
			Button.MouseButton1Click:Connect(function()
				local success, err = pcall(ButtonSettings.Callback)
				if not success then
					SilverUILibrary:Notify({Title = "Error", Content = "Callback Error: " .. tostring(err)})
				end
				SaveConfiguration()
			end)
			
			return {Set = function(self, new) Button.Text = new end}
		end
		
		function Tab:CreateToggle(ToggleSettings)
			local Frame = Instance.new("Frame")
			Frame.Parent = TabPage
			Frame.BackgroundColor3 = SelectedTheme.ElementBackground
			Frame.Size = UDim2.new(1, -10, 0, 35)
			
			local Corner = Instance.new("UICorner")
			Corner.Parent = Frame
			Corner.CornerRadius = UDim.new(0, 6)
			
			local Stroke = Instance.new("UIStroke")
			Stroke.Parent = Frame
			Stroke.Color = SelectedTheme.ElementStroke
			Stroke.Thickness = 1
			
			local Title = Instance.new("TextLabel")
			Title.Parent = Frame
			Title.BackgroundTransparency = 1
			Title.Text = ToggleSettings.Name
			Title.Position = UDim2.new(0, 12, 0.5, 0)
			Title.Size = UDim2.new(1, -70, 0, 20)
			Title.Font = Enum.Font.GothamMedium
			Title.TextColor3 = SelectedTheme.TextColor
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.AnchorPoint = Vector2.new(0, 0.5)
			
			local ToggleBg = Instance.new("Frame")
			ToggleBg.Parent = Frame
			ToggleBg.BackgroundColor3 = SelectedTheme.ToggleDisabled
			ToggleBg.Size = UDim2.new(0, 40, 0, 20)
			ToggleBg.Position = UDim2.new(1, -15, 0.5, 0)
			ToggleBg.AnchorPoint = Vector2.new(1, 0.5)
			
			local ToggleCorner = Instance.new("UICorner")
			ToggleCorner.Parent = ToggleBg
			ToggleCorner.CornerRadius = UDim.new(1, 0)
			
			local ToggleCircle = Instance.new("Frame")
			ToggleCircle.Parent = ToggleBg
			ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
			ToggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
			ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
			
			local CircleCorner = Instance.new("UICorner")
			CircleCorner.Parent = ToggleCircle
			CircleCorner.CornerRadius = UDim.new(1, 0)
			
			local Value = ToggleSettings.CurrentValue or false
			
			local function UpdateToggle(val)
				Value = val
				if val then
					SmoothTween(ToggleBg, 0.3, {BackgroundColor3 = SelectedTheme.ToggleEnabled})
					SmoothTween(ToggleCircle, 0.3, {Position = UDim2.new(1, -18, 0.5, 0)})
					ToggleCircle.AnchorPoint = Vector2.new(1, 0.5)
				else
					SmoothTween(ToggleBg, 0.3, {BackgroundColor3 = SelectedTheme.ToggleDisabled})
					SmoothTween(ToggleCircle, 0.3, {Position = UDim2.new(0, 2, 0.5, 0)})
					ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
				end
				local success, err = pcall(ToggleSettings.Callback, val)
				if not success then
					SilverUILibrary:Notify({Title = "Error", Content = "Toggle Callback Error"})
				end
				SaveConfiguration()
			end
			
			Frame.MouseButton1Click:Connect(function()
				UpdateToggle(not Value)
			end)
			
			Frame.MouseEnter:Connect(function()
				SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementHover})
			end)
			
			Frame.MouseLeave:Connect(function()
				SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementBackground})
			end)
			
			UpdateToggle(Value)
			
			if ToggleSettings.Flag and CEnabled then
				SilverUILibrary.Flags[ToggleSettings.Flag] = {Set = UpdateToggle, CurrentValue = Value}
			end
			
			return {Set = UpdateToggle, Get = function() return Value end}
		end
		
		function Tab:CreateSlider(SliderSettings)
			local Frame = Instance.new("Frame")
			Frame.Parent = TabPage
			Frame.BackgroundColor3 = SelectedTheme.ElementBackground
			Frame.Size = UDim2.new(1, -10, 0, 55)
			
			local Corner = Instance.new("UICorner")
			Corner.Parent = Frame
			Corner.CornerRadius = UDim.new(0, 6)
			
			local Stroke = Instance.new("UIStroke")
			Stroke.Parent = Frame
			Stroke.Color = SelectedTheme.ElementStroke
			Stroke.Thickness = 1
			
			local Title = Instance.new("TextLabel")
			Title.Parent = Frame
			Title.BackgroundTransparency = 1
			Title.Text = SliderSettings.Name
			Title.Position = UDim2.new(0, 12, 0, 5)
			Title.Size = UDim2.new(1, -70, 0, 18)
			Title.Font = Enum.Font.GothamMedium
			Title.TextColor3 = SelectedTheme.TextColor
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			
			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Parent = Frame
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(SliderSettings.CurrentValue or SliderSettings.Default or 0)
			ValueLabel.Position = UDim2.new(1, -15, 0, 5)
			ValueLabel.Size = UDim2.new(0, 50, 0, 18)
			ValueLabel.Font = Enum.Font.GothamMedium
			ValueLabel.TextColor3 = SelectedTheme.TextColor
			ValueLabel.TextSize = 13
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.AnchorPoint = Vector2.new(1, 0)
			
			local SliderBg = Instance.new("Frame")
			SliderBg.Parent = Frame
			SliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			SliderBg.Size = UDim2.new(1, -24, 0, 4)
			SliderBg.Position = UDim2.new(0.5, 0, 1, -12)
			SliderBg.AnchorPoint = Vector2.new(0.5, 0)
			
			local SliderBgCorner = Instance.new("UICorner")
			SliderBgCorner.Parent = SliderBg
			SliderBgCorner.CornerRadius = UDim.new(1, 0)
			
			local SliderFill = Instance.new("Frame")
			SliderFill.Parent = SliderBg
			SliderFill.BackgroundColor3 = SelectedTheme.SliderProgress
			SliderFill.Size = UDim2.new(0, 0, 1, 0)
			SliderFill.BorderSizePixel = 0
			
			local FillCorner = Instance.new("UICorner")
			FillCorner.Parent = SliderFill
			FillCorner.CornerRadius = UDim.new(1, 0)
			
			local SliderKnob = Instance.new("Frame")
			SliderKnob.Parent = SliderBg
			SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderKnob.Size = UDim2.new(0, 12, 0, 12)
			SliderKnob.Position = UDim2.new(0, -6, 0.5, 0)
			SliderKnob.AnchorPoint = Vector2.new(0, 0.5)
			
			local KnobCorner = Instance.new("UICorner")
			KnobCorner.Parent = SliderKnob
			KnobCorner.CornerRadius = UDim.new(1, 0)
			
			local Min = SliderSettings.Min or 0
			local Max = SliderSettings.Max or 100
			local Value = SliderSettings.CurrentValue or SliderSettings.Default or Min
			local Dragging = false
			
			local function UpdateSlider(val)
				val = math.clamp(val, Min, Max)
				local percent = (val - Min) / (Max - Min)
				local width = SliderBg.AbsoluteSize.X
				local newWidth = width * percent
				
				Value = val
				ValueLabel.Text = tostring(math.floor(val * 100) / 100) .. (SliderSettings.Suffix or "")
				SliderFill.Size = UDim2.new(percent, 0, 1, 0)
				SliderKnob.Position = UDim2.new(percent, -6, 0.5, 0)
				
				local success, err = pcall(SliderSettings.Callback, val)
				if not success then
					SilverUILibrary:Notify({Title = "Error", Content = "Slider Callback Error"})
				end
				SaveConfiguration()
			end
			
			SliderKnob.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
				end
			end)
			
			SliderKnob.InputEnded:Connect(function()
				Dragging = false
			end)
			
			SliderBg.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local mousePos = UserInputService:GetMouseLocation()
					local sliderPos = SliderBg.AbsolutePosition.X
					local sliderWidth = SliderBg.AbsoluteSize.X
					local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
					local newVal = Min + (Max - Min) * percent
					UpdateSlider(newVal)
					Dragging = true
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos = UserInputService:GetMouseLocation()
					local sliderPos = SliderBg.AbsolutePosition.X
					local sliderWidth = SliderBg.AbsoluteSize.X
					local percent = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
					local newVal = Min + (Max - Min) * percent
					UpdateSlider(newVal)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)
			
			UpdateSlider(Value)
			
			Frame.MouseEnter:Connect(function()
				SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementHover})
			end)
			
			Frame.MouseLeave:Connect(function()
				SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementBackground})
			end)
			
			if SliderSettings.Flag and CEnabled then
				SilverUILibrary.Flags[SliderSettings.Flag] = {Set = UpdateSlider, CurrentValue = Value}
			end
			
			return {Set = UpdateSlider, Get = function() return Value end}
		end
		
		function Tab:CreateInput(InputSettings)
			local Frame = Instance.new("Frame")
			Frame.Parent = TabPage
			Frame.BackgroundColor3 = SelectedTheme.ElementBackground
			Frame.Size = UDim2.new(1, -10, 0, 35)
			
			local Corner = Instance.new("UICorner")
			Corner.Parent = Frame
			Corner.CornerRadius = UDim.new(0, 6)
			
			local Stroke = Instance.new("UIStroke")
			Stroke.Parent = Frame
			Stroke.Color = SelectedTheme.ElementStroke
			Stroke.Thickness = 1
			
			local Title = Instance.new("TextLabel")
			Title.Parent = Frame
			Title.BackgroundTransparency = 1
			Title.Text = InputSettings.Name
			Title.Position = UDim2.new(0, 12, 0.5, 0)
			Title.Size = UDim2.new(0, 80, 0, 20)
			Title.Font = Enum.Font.GothamMedium
			Title.TextColor3 = SelectedTheme.TextColor
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.AnchorPoint = Vector2.new(0, 0.5)
			
			local InputBox = Instance.new("TextBox")
			InputBox.Parent = Frame
			InputBox.BackgroundColor3 = SelectedTheme.InputBg
			InputBox.Size = UDim2.new(1, -105, 0, 25)
			InputBox.Position = UDim2.new(1, -15, 0.5, 0)
			InputBox.AnchorPoint = Vector2.new(1, 0.5)
			InputBox.Font = Enum.Font.GothamMedium
			InputBox.TextColor3 = SelectedTheme.TextColor
			InputBox.TextSize = 12
			InputBox.PlaceholderText = InputSettings.PlaceholderText or ""
			InputBox.Text = InputSettings.CurrentValue or ""
			
			local InputCorner = Instance.new("UICorner")
			InputCorner.Parent = InputBox
			InputCorner.CornerRadius = UDim.new(0, 4)
			
			local InputStroke = Instance.new("UIStroke")
			InputStroke.Parent = InputBox
			InputStroke.Color = SelectedTheme.InputStroke
			InputStroke.Thickness = 1
			
			InputBox.FocusLost:Connect(function()
				local success, err = pcall(InputSettings.Callback, InputBox.Text)
				if not success then
					SilverUILibrary:Notify({Title = "Error", Content = "Input Callback Error"})
				end
				if InputSettings.RemoveTextAfterFocusLost then
					InputBox.Text = ""
				end
				SaveConfiguration()
			end)
			
			Frame.MouseEnter:Connect(function()
				SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementHover})
			end)
			
			Frame.MouseLeave:Connect(function()
				SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementBackground})
			end)
			
			if InputSettings.Flag and CEnabled then
				SilverUILibrary.Flags[InputSettings.Flag] = {Set = function(new) InputBox.Text = new end, CurrentValue = InputBox.Text}
			end
			
			return {Set = function(self, new) InputBox.Text = new end, Get = function() return InputBox.Text end}
		end
		
		function Tab:CreateDropdown(DropdownSettings)
			local Frame = Instance.new("Frame")
			Frame.Parent = TabPage
			Frame.BackgroundColor3 = SelectedTheme.ElementBackground
			Frame.Size = UDim2.new(1, -10, 0, 35)
			Frame.ClipsDescendants = true
			
			local Corner = Instance.new("UICorner")
			Corner.Parent = Frame
			Corner.CornerRadius = UDim.new(0, 6)
			
			local Stroke = Instance.new("UIStroke")
			Stroke.Parent = Frame
			Stroke.Color = SelectedTheme.ElementStroke
			Stroke.Thickness = 1
			
			local Title = Instance.new("TextLabel")
			Title.Parent = Frame
			Title.BackgroundTransparency = 1
			Title.Text = DropdownSettings.Name
			Title.Position = UDim2.new(0, 12, 0.5, 0)
			Title.Size = UDim2.new(0, 80, 0, 20)
			Title.Font = Enum.Font.GothamMedium
			Title.TextColor3 = SelectedTheme.TextColor
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.AnchorPoint = Vector2.new(0, 0.5)
			
			local SelectedBtn = Instance.new("TextButton")
			SelectedBtn.Parent = Frame
			SelectedBtn.BackgroundColor3 = SelectedTheme.InputBg
			SelectedBtn.Size = UDim2.new(1, -105, 0, 25)
			SelectedBtn.Position = UDim2.new(1, -15, 0.5, 0)
			SelectedBtn.AnchorPoint = Vector2.new(1, 0.5)
			SelectedBtn.Font = Enum.Font.GothamMedium
			SelectedBtn.TextColor3 = SelectedTheme.TextColor
			SelectedBtn.TextSize = 12
			SelectedBtn.Text = DropdownSettings.CurrentOption or DropdownSettings.Options[1] or "Select"
			SelectedBtn.AutoButtonColor = false
			
			local BtnCorner = Instance.new("UICorner")
			BtnCorner.Parent = SelectedBtn
			BtnCorner.CornerRadius = UDim.new(0, 4)
			
			local DropdownList = Instance.new("ScrollingFrame")
			DropdownList.Parent = Frame
			DropdownList.BackgroundColor3 = SelectedTheme.InputBg
			DropdownList.Size = UDim2.new(1, -105, 0, 0)
			DropdownList.Position = UDim2.new(1, -15, 0, 35)
			DropdownList.AnchorPoint = Vector2.new(1, 0)
			DropdownList.Visible = false
			DropdownList.ScrollBarThickness = 4
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
			
			local ListCorner = Instance.new("UICorner")
			ListCorner.Parent = DropdownList
			ListCorner.CornerRadius = UDim.new(0, 4)
			
			local ListLayout = Instance.new("UIListLayout")
			ListLayout.Parent = DropdownList
			ListLayout.Padding = UDim.new(0, 2)
			
			local Options = DropdownSettings.Options
			local Current = DropdownSettings.CurrentOption or Options[1]
			local Opened = false
			
			local function UpdateDropdown(val)
				Current = val
				SelectedBtn.Text = val
				local success, err = pcall(DropdownSettings.Callback, val)
				if not success then
					SilverUILibrary:Notify({Title = "Error", Content = "Dropdown Callback Error"})
				end
				SaveConfiguration()
			end
			
			for i, opt in ipairs(Options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Parent = DropdownList
				OptBtn.BackgroundColor3 = SelectedTheme.InputBg
				OptBtn.Size = UDim2.new(1, 0, 0, 28)
				OptBtn.Text = opt
				OptBtn.Font = Enum.Font.GothamMedium
				OptBtn.TextColor3 = SelectedTheme.TextColor
				OptBtn.TextSize = 12
				OptBtn.AutoButtonColor = false
				
				OptBtn.MouseEnter:Connect(function()
					SmoothTween(OptBtn, 0.1, {BackgroundColor3 = SelectedTheme.ButtonHover})
				end)
				
				OptBtn.MouseLeave:Connect(function()
					SmoothTween(OptBtn, 0.1, {BackgroundColor3 = SelectedTheme.InputBg})
				end)
				
				OptBtn.MouseButton1Click:Connect(function()
					UpdateDropdown(opt)
					SelectedBtn.MouseButton1Click:Click()
				end)
			end
			
			local function UpdateListHeight()
				local count = #Options
				local height = math.min(count * 30, 120)
				DropdownList.Size = UDim2.new(1, -105, 0, height)
				DropdownList.CanvasSize = UDim2.new(0, 0, 0, count * 30)
			end
			
			SelectedBtn.MouseButton1Click:Connect(function()
				Opened = not Opened
				if Opened then
					UpdateListHeight()
					DropdownList.Visible = true
					SmoothTween(Frame, 0.3, {Size = UDim2.new(1, -10, 0, 35 + DropdownList.Size.Y.Offset)})
				else
					SmoothTween(Frame, 0.3, {Size = UDim2.new(1, -10, 0, 35)})
					task.wait(0.25)
					DropdownList.Visible = false
				end
			end)
			
			UpdateDropdown(Current)
			
			Frame.MouseEnter:Connect(function()
				if not Opened then
					SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementHover})
				end
			end)
			
			Frame.MouseLeave:Connect(function()
				if not Opened then
					SmoothTween(Frame, 0.2, {BackgroundColor3 = SelectedTheme.ElementBackground})
				end
			end)
			
			if DropdownSettings.Flag and CEnabled then
				SilverUILibrary.Flags[DropdownSettings.Flag] = {Set = UpdateDropdown, CurrentValue = Current}
			end
			
			return {Set = UpdateDropdown, Get = function() return Current end}
		end
		
		return Tab
	end
	
	function Window:Destroy()
		SilverUI:Destroy()
	end
	
	task.delay(0.5, function()
		if CEnabled and isfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension) then
			LoadConfiguration(readfile(ConfigurationFolder .. "/" .. CFileName .. ConfigurationExtension))
		end
	end)
	
	return Window
end

function SilverUILibrary:Destroy()
	SilverUI:Destroy()
end

Topbar.ChangeSize.MouseButton1Click:Connect(function()
	if Debounce then return end
	if Minimised then
		Minimised = false
		SmoothTween(Main, 0.5, {Size = UDim2.new(0, 500, 0, 475)})
		Elements.Visible = true
		TabList.Visible = true
	else
		Minimised = true
		SmoothTween(Main, 0.5, {Size = UDim2.new(0, 500, 0, 45)})
		Elements.Visible = false
		TabList.Visible = false
	end
end)

Topbar.Hide.MouseButton1Click:Connect(function()
	if Debounce then return end
	Debounce = true
	if Hidden then
		Hidden = false
		SmoothTween(Main, 0.4, {Size = UDim2.new(0, 500, 0, 475), BackgroundTransparency = 0})
		SmoothTween(Main.Topbar, 0.4, {BackgroundTransparency = 0})
		Elements.Visible = true
		TabList.Visible = true
		if Minimised then
			SmoothTween(Main, 0.4, {Size = UDim2.new(0, 500, 0, 45)})
			Elements.Visible = false
			TabList.Visible = false
		end
	else
		Hidden = true
		SmoothTween(Main, 0.4, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
		SmoothTween(Main.Topbar, 0.4, {BackgroundTransparency = 1})
		Elements.Visible = false
		TabList.Visible = false
	end
	task.wait(0.5)
	Debounce = false
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightShift then
		Topbar.Hide.MouseButton1Click:Click()
	end
end)

for _, btn in ipairs(Topbar:GetChildren()) do
	if btn.ClassName == "ImageButton" then
		btn.MouseEnter:Connect(function()
			SmoothTween(btn, 0.2, {ImageTransparency = 0.3})
		end)
		btn.MouseLeave:Connect(function()
			SmoothTween(btn, 0.2, {ImageTransparency = 0.7})
		end)
	end
end

return SilverUILibrary
