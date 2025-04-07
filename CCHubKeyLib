--[[

	Roblibwaita: A Roblox User Interface Library.
	By Blukez
	
	Contributions:
	RealPacket | refactoring

	This UI Library is VERY heavily inspired by the GNOME project (https://gnome.org).
	pls dont sue me

]]--

local rolibwaita = {}

-- \\ Variables // --
local Assets = game:GetObjects("rbxassetid://18397627650")[1]

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local CoreGui = gethui() or game:GetService("CoreGui")
local Mouse = LocalPlayer:GetMouse()

local Examples = Assets.Examples
local Gui = Assets.GUI

local TweenPresets = {
	Fast = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Medium = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}

-- \\ Typings // --

type WindowOptions = {
	Name: string,
	Keybind: string
}

type TabOptions = {
	Name: string,
	Image: string
}

type SectionOptions = {
	Name: string,
	Description: string
}

-- \\ Functions // --

local function createTween(instance: Instance, tweenInfo: TweenInfo, properties: {[string]: any})
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

-- \\ Main // --

function rolibwaita:NewWindow(WindowOptions: WindowOptions)
	local TabTable = {}
	local guiClone = Gui:Clone()
	local mainFrame = guiClone.Main
	local mainCover = mainFrame.Cover
	local sideBar = mainFrame.SideBar
	local tabButtons = sideBar.Items
	local titleBar = sideBar.TitleBar
	local title = titleBar.Title
	local searchBar = titleBar.SearchBar
	local searchQuery = searchBar.TextBox
	local topbar = mainFrame.Topbar
	local tabTitle = topbar.TabTitle
	local searchButton = topbar.Search
	local closeButton = topbar.Close
	local tabs = mainFrame.Tabs
	local cover = tabs.Cover
	local resizeCorner = mainFrame.ResizeCorner
	local resizeHitbox = resizeCorner.Hitbox

	local startMouse, startSize
	local resizing = false
	local guiHidden = false

	if WindowOptions.Name == nil then
		error("Required setting 'Name' not given")
	end

	if WindowOptions.Keybind == nil then
		error("Required setting 'Keybind' not given")
	end

	if WindowOptions.PrintCredits then
		print("Roblibwaita: Roblox User Interface Library.")
		print("Created By Blukez, Inspired By GNOME.")
		print("Contributions:")
		print("RealPacket | refactoring")
	end

	title.Text = WindowOptions.Name

	mainFrame.ClipsDescendants = true
	mainFrame.BackgroundTransparency = 1
	resizeHitbox.BackgroundTransparency = 1
	tabTitle.TextTransparency = 1
	closeButton.BackgroundTransparency = 1
	closeButton.Icon.ImageTransparency = 1
	searchButton.Icon.ImageTransparency = 1
	sideBar.Position = UDim2.new(0, -195, 0.5, 0)
	mainFrame.Size = UDim2.new(0, 80, 0, 50)

	if WindowOptions.UseCoreGui then
		guiClone.Parent = CoreGui
	else
		guiClone.Parent = PlayerGui
	end

	guiClone.Enabled = true

	createTween(mainFrame, TweenPresets.Slow, { Size = UDim2.new(0, 717, 0, 442) })
	task.wait(0.1)
	createTween(mainFrame, TweenPresets.Slow, { BackgroundTransparency = 0 })
	task.wait(0.6)
	createTween(sideBar, TweenPresets.Slow, { Position = UDim2.new(0, 0, 0.5, 0) })
	task.wait(0.5)
	createTween(tabTitle, TweenPresets.Medium, { TextTransparency = 0 })
	createTween(closeButton, TweenPresets.Medium, { BackgroundTransparency = 0 })
	createTween(closeButton.Icon, TweenPresets.Medium, { ImageTransparency = 0 })
	createTween(searchButton.Icon, TweenPresets.Medium, { ImageTransparency = 0 })
	createTween(resizeHitbox, TweenPresets.Medium, { BackgroundTransparency = 0.95 })

	mainFrame.AnchorPoint = Vector2.new(0, 0)
	mainFrame.Position = UDim2.new(0.5, -358, 0.5, -221)

	local mouseIcon = Instance.new("ImageLabel")
	mouseIcon.Parent = guiClone
	mouseIcon.BackgroundTransparency = 1
	mouseIcon.ImageTransparency = 1
	mouseIcon.Size = UDim2.new(0, 20, 0, 20)
	mouseIcon.Rotation = -90

	-- drag

	local dragToggle, dragStart, startPos
	local dragSpeed = 0.21

	local function updateInput(input)
		local delta = input.Position - dragStart
		local position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService("TweenService"):Create(mainFrame, TweenInfo.new(dragSpeed), { Position = position }):Play()
	end

	topbar.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragToggle = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if dragToggle then
				updateInput(input)
			end
		end
	end)

	--resize

	resizeHitbox.MouseEnter:Connect(function()
		UIS.MouseIconEnabled = false
		mouseIcon.Image = "rbxassetid://18593863892"
		mouseIcon.ImageTransparency = 0
	end)

	resizeHitbox.MouseLeave:Connect(function()
		if resizing == false then
			UIS.MouseIconEnabled = true
			mouseIcon.ImageTransparency = 1
		end
	end)

	resizeHitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			startSize = mainFrame.AbsoluteSize
			startMouse = Vector2.new(Mouse.X, Mouse.Y)
		end
	end)

	resizeHitbox.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
			UIS.MouseIconEnabled = true
			mouseIcon.ImageTransparency = 1
		end
	end)

	game:GetService("RunService").RenderStepped:Connect(function()
		mouseIcon.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
		if resizing == true then
			local m = Vector2.new(Mouse.X, Mouse.Y)
			local mouseMoved = Vector2.new(m.X - startMouse.X, m.Y - startMouse.Y)

			local s = startSize + mouseMoved
			local sx = math.max(650, s.X)
			local sy = math.max(300, s.Y)

			createTween(mainFrame, TweenPresets.Fast, { Size = UDim2.fromOffset(sx, sy) })
		end
	end)

	-- hide

	local lastSize = mainFrame.Size
	local function hideGUI()
		guiHidden = true
		mainCover.Visible = true
		lastSize = mainFrame.Size
		mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		mainFrame.Position += UDim2.new(0, mainFrame.Size.X.Offset / 2, 0, mainFrame.Size.Y.Offset / 2)

		createTween(mainCover, TweenPresets.Fast, { BackgroundTransparency = 0 })
		task.wait(0.3)
		resizeCorner.Visible = false
		sideBar.Visible = false
		tabs.Visible = false
		topbar.Visible = false
		createTween(mainCover, TweenPresets.Medium, { BackgroundTransparency = 1 })
		createTween(mainFrame, TweenPresets.Medium, { BackgroundTransparency = 1 })
		task.wait(0.1)
		createTween(mainFrame, TweenPresets.Slow, { Size = UDim2.new(0, 80, 0, 50) })
		task.wait(0.5)
		mainFrame.Visible = false
	end

	local function unHideGUI()
		guiHidden = false
		mainFrame.Visible = true

		createTween(mainFrame, TweenPresets.Slow, { Size = lastSize })
		task.wait(0.1)
		createTween(mainFrame, TweenPresets.Medium, { BackgroundTransparency = 0 })
		createTween(mainCover, TweenPresets.Medium, { BackgroundTransparency = 0 })
		task.wait(0.5)
		resizeCorner.Visible = true
		sideBar.Visible = true
		tabs.Visible = true
		topbar.Visible = true
		createTween(mainCover, TweenPresets.Fast, { BackgroundTransparency = 1 })
		task.wait(0.3)

		mainFrame.AnchorPoint = Vector2.new(0, 0)
		mainFrame.Position -= UDim2.new(0, mainFrame.Size.X.Offset / 2, 0, mainFrame.Size.Y.Offset / 2)
		mainCover.Visible = false
	end

	UIS.InputBegan:Connect(function(Input, IsTyping)
		if IsTyping then
			return
		end
		if Input.KeyCode == Enum.KeyCode[WindowOptions.Keybind] then
			if guiHidden == true then
				unHideGUI()
			else
				hideGUI()
			end
		end
	end)

	closeButton.Hitbox.MouseEnter:Connect(function()
		createTween(closeButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
	end)

	closeButton.Hitbox.MouseLeave:Connect(function()
		createTween(closeButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(50, 50, 50) })
	end)

	closeButton.Hitbox.MouseButton1Down:Connect(function()
		createTween(closeButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(69, 69, 69) })
	end)

	local openandclosenotificationthingshown = false
	closeButton.Hitbox.MouseButton1Up:Connect(function()
		createTween(closeButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
		task.wait(0.2)
		hideGUI()
		if openandclosenotificationthingshown == false then
			openandclosenotificationthingshown = true
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Notification",
				Text = "Press " .. WindowOptions.Keybind .. " to reopen UI.",
			})
		end
	end)

	local firstTab = true
	local window = {}
	function window:NewTab(TabOptions: TabOptions) -- tab
		local tabClone = Examples.Tab:Clone()
		local tabButtonClone = Examples.TabButton:Clone()
		local tabName = TabOptions.Name

		tabClone.Visible = firstTab
		table.insert(TabTable, { Name = tabName, Displayed = firstTab })
		if firstTab then
			tabTitle.Text = tabName
			firstTab = false
		end

		if TabOptions.Name == nil then
			error("Required setting 'Name' not given")
		end

		if TabOptions.Icon ~= nil then
			tabButtonClone.Icon.Image = TabOptions.Icon
		else
			tabButtonClone.Icon.Visible = false
			tabButtonClone.Title.Position = UDim2.new(0.45, 0, 0.5, 0)
		end

		tabClone.Name = tabName
		tabButtonClone.Title.Text = tabName
		tabButtonClone.Name = tabName
		tabClone.Parent = tabs

		tabButtonClone.Icon.ImageTransparency = 1
		tabButtonClone.Title.TextTransparency = 1
		tabButtonClone.Parent = tabButtons

		createTween(tabButtonClone.Icon, TweenPresets.Medium, { ImageTransparency = 0 })
		createTween(tabButtonClone.Title, TweenPresets.Medium, { TextTransparency = 0 })

		tabButtonClone.Hitbox.MouseEnter:Connect(function()
			createTween(tabButtonClone, TweenPresets.Fast, { BackgroundTransparency = 0.9 })
		end)
		tabButtonClone.Hitbox.MouseLeave:Connect(function()
			createTween(tabButtonClone, TweenPresets.Fast, { BackgroundTransparency = 1 })
		end)
		tabButtonClone.Hitbox.MouseButton1Down:Connect(function()
			createTween(tabButtonClone, TweenPresets.Fast, { BackgroundTransparency = 0.85 })
		end)
		tabButtonClone.Hitbox.MouseButton1Up:Connect(function()
			createTween(tabButtonClone, TweenPresets.Fast, { BackgroundTransparency = 0.9 })

			if not tabClone.Visible then
				for _, v in pairs(TabTable) do
					if v.Displayed and v.Name ~= tabName then
						v.Displayed = false
						task.spawn(function()
							task.wait(0.3)
							tabs[v.Name].Visible = false
						end)
					elseif v.Name == tabName then
						v.Displayed = true
					end
				end

				tabTitle.Text = tabName
				createTween(
					cover,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 0 }
				)
				task.wait(0.3)
				tabClone.Visible = true
				createTween(
					cover,
					TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 1 }
				)
			end
		end)

		-- search bar
		local searchBarOpen = false

		searchButton.Hitbox.MouseEnter:Connect(function()
			createTween(searchButton, TweenPresets.Fast, { BackgroundTransparency = 0.92 })
		end)

		searchButton.Hitbox.MouseLeave:Connect(function()
			createTween(searchButton, TweenPresets.Fast, { BackgroundTransparency = 1 })
		end)

		searchButton.Hitbox.MouseButton1Down:Connect(function()
			createTween(searchButton, TweenPresets.Fast, { BackgroundTransparency = 0.85 })
		end)

		searchButton.Hitbox.MouseButton1Up:Connect(function()
			if searchBarOpen == false then
				searchBarOpen = true
				searchBar.Visible = true
				searchQuery.Visible = true
				createTween(searchButton, TweenPresets.Fast, { BackgroundTransparency = 0.92 })
				createTween(searchButton.Icon, TweenPresets.Fast, { ImageTransparency = 1 })
				createTween(searchBar, TweenPresets.Fast, { BackgroundTransparency = 0 })
				createTween(searchBar.TextBox, TweenPresets.Fast, { TextTransparency = 0 })
				createTween(searchButton.Icon1, TweenPresets.Fast, { ImageTransparency = 0 })
				searchQuery:CaptureFocus()
			end
		end)

		searchQuery.FocusLost:Connect(function()
			local InputText = string.lower(searchQuery.Text)
			local noResultsFound = false

			if searchQuery.Text == "" then
				createTween(searchButton.Icon, TweenPresets.Fast, { ImageTransparency = 0 })
				createTween(searchBar, TweenPresets.Fast, { BackgroundTransparency = 1 })
				createTween(searchBar.TextBox, TweenPresets.Fast, { TextTransparency = 1 })
				createTween(searchButton.Icon1, TweenPresets.Fast, { ImageTransparency = 1 })
				task.wait(0.3)
				searchQuery.Text = ""
				searchBar.Visible = false
				searchQuery.Visible = false
				searchBarOpen = false
				return
			end

			for _, v in pairs(tabClone:GetDescendants()) do
				if v:IsA("Frame") and v.Parent.Parent:IsA("ScrollingFrame") then
					if string.find(string.lower(v.Name), InputText) then
						task.spawn(function()
							createTween(searchButton.Icon, TweenPresets.Fast, { ImageTransparency = 0 })
							createTween(searchBar, TweenPresets.Fast, { BackgroundTransparency = 1 })
							createTween(searchBar.TextBox, TweenPresets.Fast, { TextTransparency = 1 })
							createTween(searchButton.Icon1, TweenPresets.Fast, { ImageTransparency = 1 })
							task.wait(0.3)
							searchQuery.Text = ""
							searchBar.Visible = false
							searchQuery.Visible = false
							searchBarOpen = false
						end)

						local searchScrollTo = 0
						for _, b in pairs(v.Parent.Parent:GetChildren()) do
							if b:IsA("Frame") and v.Parent.LayoutOrder > b.LayoutOrder then
								searchScrollTo += b.AbsoluteSize.Y
							end
						end
						for _, b in pairs(v.Parent:GetChildren()) do
							if b:IsA("Frame") and v.LayoutOrder > b.LayoutOrder then
								searchScrollTo += b.AbsoluteSize.Y
							end
						end
						print(searchScrollTo)
						createTween(
							v.Parent.Parent,
							TweenPresets.Fast,
							{ CanvasPosition = Vector2.new(0, searchScrollTo + 50) }
						)
						task.wait(0.1)
						createTween(v, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(75, 75, 75) })
						task.wait(0.3)
						createTween(v, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(54, 54, 54) })
						return
					end
					noResultsFound = true
				end
			end
			if noResultsFound == true then
				noResultsFound = false
				searchQuery.Text = ""
				createTween(
					searchButton.Icon1,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0.8, 0, 0.5, 0) }
				)
				task.wait(0.07)
				createTween(
					searchButton.Icon1,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0.2, 0, 0.5, 0) }
				)
				task.wait(0.07)
				createTween(
					searchButton.Icon1,
					TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Position = UDim2.new(0.5, 0, 0.5, 0) }
				)
				searchQuery:CaptureFocus()
			end
		end)

		local tabFuncs = {}

		local sectionOrder = 0
		function tabFuncs:NewSection(SectionOptions: SectionOptions) -- section
			local sectionClone = Examples.Section:Clone()
			local order = 0

			sectionClone.LayoutOrder = sectionOrder
			sectionOrder += 1

			sectionClone.Name = SectionOptions.Name
			sectionClone.Title.Text = SectionOptions.Name

			sectionClone.Title.TextTransparency = 1
			sectionClone.Description.TextTransparency = 1
			sectionClone.Parent = tabClone

			createTween(sectionClone.Title, TweenPresets.Medium, { TextTransparency = 0 })
			createTween(sectionClone.Description, TweenPresets.Medium, { TextTransparency = 0 })

			local function handleNilDesc(obj, Options: SectionOptions)
				if Options.Description == nil then
					obj.Description:Destroy()
					obj.Title.Position = UDim2.new(0, 12, 0.5, 0)
					return false
				else
					obj.Description.Text = Options.Description
					obj.Description.TextTransparency = 1
					createTween(obj.Description, TweenPresets.Medium, { TextTransparency = 0 })
					return true
				end
			end

			handleNilDesc(sectionClone, SectionOptions)

			local laterElementsExists = false
			local middleElemntsExists = false
			local ealierElementsExists = false
			local function updateElementsExistance()
				laterElementsExists = false
				middleElemntsExists = false
				ealierElementsExists = false
				for _, v in pairs(sectionClone:GetChildren()) do
					if v:IsA("Frame") then
						if v.LayoutOrder > 0 then
							laterElementsExists = true
						end

						if order > 2 then
							middleElemntsExists = true
						end

						if v.LayoutOrder < order - 1 then
							ealierElementsExists = true
						end
					end
				end
			end

			local function handleCornerRadius(obj)
				obj.LayoutOrder = order
				order += 1

				updateElementsExistance()

				if laterElementsExists == true then -- 2 or more elements exists in section
					for _, v in pairs(sectionClone:GetChildren()) do
						if v:IsA("Frame") and v.LayoutOrder == order - 2 then
							task.spawn(function()
								createTween(v.UICorner, TweenPresets.Slow, { CornerRadius = UDim.new(0, 3) })
								task.wait(0.1)
								createTween(v.CornerCover, TweenPresets.Medium, { BackgroundTransparency = 1 })
								task.wait(0.5)
								v.CornerCover:Destroy()
							end)
						end
					end

					local cornerCover = Examples.CornerCover:Clone()
					cornerCover.BackgroundTransparency = 1
					cornerCover.Parent = obj
					cornerCover.Position = UDim2.new(0.5, 0, 0.5, -12)
					task.spawn(function()
						task.wait(0.1)
						createTween(cornerCover, TweenPresets.Medium, { BackgroundTransparency = 0 })
					end)
					obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
						cornerCover.BackgroundColor3 = obj.BackgroundColor3
					end)
				elseif ealierElementsExists == true then -- 1 element exists, 2 elements will now exist
					for _, v in pairs(sectionClone:GetChildren()) do
						if v:IsA("Frame") and v.LayoutOrder == 0 then
							local cornerCover = Examples.CornerCover:Clone()
							cornerCover.BackgroundTransparency = 1
							cornerCover.Parent = v
							cornerCover.Position = UDim2.new(0.5, 0, 0.5, 12)
							task.spawn(function()
								task.wait(0.1)
								createTween(cornerCover, TweenPresets.Medium, { BackgroundTransparency = 0 })
							end)
							v:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
								cornerCover.BackgroundColor3 = v.BackgroundColor3
							end)
						end
					end

					local cornerCover = Examples.CornerCover:Clone()
					cornerCover.BackgroundTransparency = 1
					cornerCover.Parent = obj
					cornerCover.Position = UDim2.new(0.5, 0, 0.5, -12)
					task.spawn(function()
						task.wait(0.1)
						createTween(cornerCover, TweenPresets.Medium, { BackgroundTransparency = 0 })
					end)
					obj:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
						cornerCover.BackgroundColor3 = obj.BackgroundColor3
					end)
				end
			end

			local function OnMainElementRemove(obj)
				local deletedOrder = obj.LayoutOrder
				order -= 1

				for _, v in pairs(sectionClone:GetChildren()) do
					if v:IsA("Frame") and v ~= obj then
						if deletedOrder == 0 then -- deleted thing is the first one
							v.LayoutOrder -= 1
							if middleElemntsExists == true and v.LayoutOrder == 0 then
								local cornerCover = Examples.CornerCover:Clone()
								cornerCover.BackgroundTransparency = 1
								cornerCover.Parent = v
								cornerCover.Position = UDim2.new(0.5, 0, 0.5, 12)
								createTween(v.UICorner, TweenPresets.Medium, { CornerRadius = UDim.new(0, 12) })
								createTween(cornerCover, TweenPresets.Medium, { BackgroundTransparency = 0 })
								v:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
									cornerCover.BackgroundColor3 = v.BackgroundColor3
								end)
							elseif ealierElementsExists == true and v.LayoutOrder == 0 then
								task.spawn(function()
									ealierElementsExists = false
									createTween(v.UICorner, TweenPresets.Medium, { CornerRadius = UDim.new(0, 12) })
									createTween(
										v:FindFirstChild("CornerCover"),
										TweenPresets.Medium,
										{ BackgroundTransparency = 1 }
									)
									task.wait(0.5)
									v:FindFirstChild("CornerCover"):Destroy()
								end)
							end
						elseif deletedOrder == order then -- deleted thing is the last one
							if middleElemntsExists == true and v.LayoutOrder == order - 1 then
								local cornerCover = Examples.CornerCover:Clone()
								cornerCover.BackgroundTransparency = 1
								cornerCover.Parent = v
								cornerCover.Position = UDim2.new(0.5, 0, 0.5, -12)
								createTween(v.UICorner, TweenPresets.Medium, { CornerRadius = UDim.new(0, 12) })
								createTween(cornerCover, TweenPresets.Medium, { BackgroundTransparency = 0 })
								v:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
									cornerCover.BackgroundColor3 = v.BackgroundColor3
								end)
							elseif ealierElementsExists == true and v.LayoutOrder == order - 1 then
								task.spawn(function()
									ealierElementsExists = false
									createTween(v.UICorner, TweenPresets.Medium, { CornerRadius = UDim.new(0, 12) })
									createTween(
										v:FindFirstChild("CornerCover"),
										TweenPresets.Medium,
										{ BackgroundTransparency = 1 }
									)
									task.wait(0.5)
									v:FindFirstChild("CornerCover"):Destroy()
								end)
							end
						else -- deleted thing is the middle one
							if v.LayoutOrder > deletedOrder then
								v.LayoutOrder -= 1
							end
						end
					end
				end

				updateElementsExistance()
			end

			local function editDesc(obj, Options, descExists)
				if descExists and Options.Description ~= nil then
					obj.Description.Text = Options.Description
					return true
				elseif descExists and Options.Description == nil then
					createTween(obj.Description, TweenPresets.Medium, { TextTransparency = 1 })
					task.wait(0.5)
					obj.Description:Destroy()
					createTween(obj.Title, TweenPresets.Medium, { Position = UDim2.new(0, 12, 0.5, 0) })
					return false
				elseif not descExists and Options.Description ~= nil then
					local description = Examples.Button.Description:Clone()
					description.Text = Options.Description
					description.TextTransparency = 1
					description.Parent = obj
					createTween(description, TweenPresets.Medium, { TextTransparency = 0 })
					createTween(obj.Title, TweenPresets.Medium, { Position = UDim2.new(0, 12, 0, 15) })
					return true
				else
					return false
				end
			end

			local sectionFuncs = {}

			function sectionFuncs:NewButton(ButtonOptions) -- button
				local buttonClone = Examples.Button:Clone()
				local descExists = handleNilDesc(buttonClone, ButtonOptions)

				if ButtonOptions.Name == nil then
					error("Required setting 'Name' not given")
				end

				buttonClone.Name = ButtonOptions.Name
				buttonClone.Title.Text = ButtonOptions.Name

				buttonClone.BackgroundTransparency = 1
				buttonClone.Title.TextTransparency = 1
				buttonClone.Icon.ImageTransparency = 1

				handleCornerRadius(buttonClone)

				buttonClone.Parent = sectionClone

				createTween(buttonClone, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(buttonClone.Icon, TweenPresets.Medium, { ImageTransparency = 0 })
				createTween(buttonClone.Title, TweenPresets.Medium, { TextTransparency = 0 })

				buttonClone.Hitbox.MouseEnter:Connect(function()
					createTween(buttonClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
				end)

				buttonClone.Hitbox.MouseLeave:Connect(function()
					createTween(buttonClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(54, 54, 54) })
				end)

				buttonClone.Hitbox.MouseButton1Down:Connect(function()
					createTween(buttonClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(70, 70, 70) })
				end)

				buttonClone.Hitbox.MouseButton1Up:Connect(function()
					createTween(buttonClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
				end)

				local onClickConnection = buttonClone.Hitbox.MouseButton1Click:Connect(function()
					if ButtonOptions.Callback ~= nil then
						ButtonOptions:Callback()
					end
				end)

				local buttonFuncs = {}

				function buttonFuncs:Edit(NewButtonOptions) -- edit button
					if ButtonOptions.Name ~= nil then
						buttonClone.Title.Text = NewButtonOptions.Name
						buttonClone.Name = NewButtonOptions.Name
					end
					onClickConnection:Disconnect()
					onClickConnection = buttonClone.Hitbox.MouseButton1Click:Connect(function()
						if ButtonOptions.Callback ~= nil then
							NewButtonOptions:Callback()
						end
					end)
					descExists = editDesc(buttonClone, NewButtonOptions, descExists)
				end

				function buttonFuncs:Remove() -- remove button
					createTween(buttonClone, TweenPresets.Medium, { BackgroundTransparency = 1 })
					createTween(buttonClone, TweenPresets.Medium, { Size = UDim2.new(1, 0, 0, 0) })
					createTween(buttonClone.Icon, TweenPresets.Medium, { ImageTransparency = 1 })
					createTween(buttonClone.Title, TweenPresets.Medium, { TextTransparency = 1 })
					if descExists == true then
						createTween(buttonClone.Description, TweenPresets.Medium, { TextTransparency = 1 })
					end
					if buttonClone:FindFirstChild("CornerCover") then
						createTween(buttonClone.CornerCover, TweenPresets.Medium, { BackgroundTransparency = 1 })
					end
					task.wait(0.6)
					OnMainElementRemove(buttonClone)
					buttonClone:Destroy()
				end

				return buttonFuncs
			end

			function sectionFuncs:NewToggle(ToggleOptions) -- toggle
				local toggleClone
				local toggled = ToggleOptions.CurrentState or false

				if ToggleOptions.Name == nil then
					error("Required setting 'Name' not given")
				end

				if toggled == true then
					toggleClone = Examples.ToggleOn:Clone()
				elseif toggled == false then
					toggleClone = Examples.Toggle:Clone()
				else
					toggled = false
					toggleClone = Examples.Toggle:Clone()
				end

				local descExists = handleNilDesc(toggleClone, ToggleOptions)

				toggleClone.Name = ToggleOptions.Name
				toggleClone.Title.Text = ToggleOptions.Name

				toggleClone.BackgroundTransparency = 1
				toggleClone.Title.TextTransparency = 1
				toggleClone.Switch.BackgroundTransparency = 1
				toggleClone.Switch.Circle.BackgroundTransparency = 1
				handleCornerRadius(toggleClone)

				toggleClone.Parent = sectionClone

				createTween(toggleClone, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(toggleClone.Title, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(toggleClone.Switch, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(toggleClone.Switch.Circle, TweenPresets.Medium, { BackgroundTransparency = 0 })

				toggleClone.Hitbox.MouseEnter:Connect(function()
					createTween(toggleClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
				end)

				toggleClone.Hitbox.MouseLeave:Connect(function()
					createTween(toggleClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(54, 54, 54) })
				end)

				toggleClone.Hitbox.MouseButton1Down:Connect(function()
					createTween(toggleClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(70, 70, 70) })
				end)

				toggleClone.Hitbox.MouseButton1Up:Connect(function()
					createTween(toggleClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
					if toggled == true then
						toggled = false

						createTween(
							toggleClone.Switch,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(80, 80, 80) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(168, 168, 168) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ Position = UDim2.new(0.3, 0, 0.5, 0) }
						)
					else
						toggled = true

						createTween(
							toggleClone.Switch,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(53, 132, 228) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(255, 255, 255) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ Position = UDim2.new(0.7, 0, 0.5, 0) }
						)
					end
				end)

				local onToggleConnection = toggleClone.Hitbox.MouseButton1Click:Connect(function()
					if ToggleOptions.Callback ~= nil then
						wait()
						ToggleOptions.Callback(toggled)
					end
				end)

				local toggleFuncs = {}
				function toggleFuncs:Edit(NewToggleOptions) -- edit toggle
					if NewToggleOptions.Name ~= nil then
						toggleClone.Title.Text = NewToggleOptions.Name
						toggleClone.Name = NewToggleOptions.Name
					end
					descExists = editDesc(toggleClone, NewToggleOptions, descExists)
					if NewToggleOptions.CurrentState == true then
						createTween(
							toggleClone.Switch,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(53, 132, 228) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(255, 255, 255) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ Position = UDim2.new(0.7, 0, 0.5, 0) }
						)

						toggled = true
					else
						createTween(
							toggleClone.Switch,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(80, 80, 80) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ BackgroundColor3 = Color3.fromRGB(168, 168, 168) }
						)
						createTween(
							toggleClone.Switch.Circle,
							TweenPresets.Fast,
							{ Position = UDim2.new(0.3, 0, 0.5, 0) }
						)

						toggled = false
					end
					onToggleConnection:Disconnect()
					onToggleConnection = toggleClone.Hitbox.MouseButton1Click:Connect(function()
						NewToggleOptions.Callback(toggled)
					end)
				end

				function toggleFuncs:Remove() -- remove toggle
					createTween(toggleClone, TweenPresets.Medium, { BackgroundTransparency = 1 })
					createTween(toggleClone, TweenPresets.Medium, { Size = UDim2.new(1, 0, 0, 0) })
					createTween(toggleClone.Title, TweenPresets.Medium, { TextTransparency = 1 })
					createTween(toggleClone.Switch, TweenPresets.Medium, { BackgroundTransparency = 1 })
					createTween(toggleClone.Switch.Circle, TweenPresets.Medium, { BackgroundTransparency = 1 })
					if descExists == true then
						createTween(toggleClone.Description, TweenPresets.Medium, { BackgroundTransparency = 1 })
					end
					if toggleClone:FindFirstChild("CornerCover") then
						createTween(toggleClone.CornerCover, TweenPresets.Medium, { BackgroundTransparency = 1 })
					end
					task.wait(0.6)
					OnMainElementRemove(toggleClone)
					toggleClone:Destroy()
				end

				return toggleFuncs
			end

			function sectionFuncs:NewTextBox(TextboxOptions) -- textbox
				local textBoxClone = Examples.TextBox:Clone()
				local onTextConnection, callback, trigger

				if TextboxOptions.Name == nil then
					error("Required setting 'Name' not given")
				end

				if TextboxOptions.Text ~= nil then
					textBoxClone.TextBox.Text = TextboxOptions.Text
				else
					textBoxClone.TextBox.Text = ""
				end

				if TextboxOptions.PlaceholderText == nil then
					textBoxClone.TextBox.PlaceholderText = "Text here.."
				else
					textBoxClone.TextBox.PlaceholderText = TextboxOptions.PlaceholderText
				end

				if TextboxOptions.Callback ~= nil then
					callback = TextboxOptions.Callback
				end

                if TextboxOptions.Trigger ~= nil then
					trigger = TextboxOptions.Trigger
				end

				textBoxClone.Name = TextboxOptions.Name
				textBoxClone.Title.Text = TextboxOptions.Name

				textBoxClone.BackgroundTransparency = 1
				textBoxClone.Title.TextTransparency = 1
				textBoxClone.Icon.ImageTransparency = 1
				textBoxClone.TextBox.TextTransparency = 1
				handleCornerRadius(textBoxClone)

				textBoxClone.Parent = sectionClone

				createTween(textBoxClone, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(textBoxClone.Title, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(textBoxClone.TextBox, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(textBoxClone.Icon, TweenPresets.Medium, { ImageTransparency = 0 })

				textBoxClone.MouseEnter:Connect(function()
					createTween(textBoxClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
				end)

				textBoxClone.MouseLeave:Connect(function()
					createTween(textBoxClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(54, 54, 54) })
				end)

                if trigger ~= nil then
                    if trigger == "FocusLost" then
						onTextConnection = textBoxClone.TextBox.FocusLost:Connect(function()
							callback(textBoxClone.TextBox.Text)
						end)
					elseif TextBoxOptions.trigger == "TextChanged" then
						onTextConnection = textBoxClone.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
							callback(textBoxClone.TextBox.Text)
						end)
					end
                end

				local textBoxFuncs = {}
				function textBoxFuncs:Edit(newTextBoxOptions)
					if newTextBoxOptions.Text ~= nil then
						textBoxClone.TextBox.Text = newTextBoxOptions.Text
					end

					if newTextBoxOptions.PlaceholderText == nil then
						textBoxClone.TextBox.PlaceholderText = "Text here.."
					else
						textBoxClone.TextBox.PlaceholderText = newTextBoxOptions.PlaceholderText
					end

					if newTextBoxOptions.Name ~= nil then
						textBoxClone.Title.Text = newTextBoxOptions.Name
						textBoxClone.Name = newTextBoxOptions.Name
					end

					if newTextBoxOptions.Callback ~= nil then
						callback = TextboxOptions.Callback
					end

					if newTextBoxOptions.Trigger ~= nil and callback ~= nil then
						onTextConnection:Disconnect()
						if TextBoxOptions.Trigger == "FocusLost" then
							onTextConnection = textBoxClone.TextBox.FocusLost:Connect(function()
								callback(textBoxClone.TextBox.Text)
							end)
						elseif TextBoxOptions.Trigger == "TextChanged" then
							onTextConnection = textBoxClone.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
								callback(textBoxClone.TextBox.Text)
							end)
						end
					end
				end

				function textBoxFuncs:Remove()
					createTween(textBoxClone, TweenPresets.Medium, { BackgroundTransparency = 1 })
					createTween(textBoxClone, TweenPresets.Medium, { Size = UDim2.new(1, 0, 0, 0) })
					createTween(textBoxClone.Title, TweenPresets.Medium, { TextTransparency = 1 })
					createTween(textBoxClone.TextBox, TweenPresets.Medium, { TextTransparency = 1 })
					createTween(textBoxClone.Icon, TweenPresets.Medium, { ImageTransparency = 1 })
					if textBoxClone:FindFirstChild("CornerCover") then
						createTween(textBoxClone.CornerCover, TweenPresets.Medium, { BackgroundTransparency = 1 })
					end
					task.wait(0.5)
					OnMainElementRemove()
					textBoxClone:Destroy()
				end
				return textBoxFuncs
			end

			function sectionFuncs:NewDropdown(DropdownOptions)
				local dropdownClone = Examples.Dropdown:Clone()
				local dropButton = dropdownClone.DropButton
				local largestChoiceSize = 0
				local descExists = handleNilDesc(dropdownClone, DropdownOptions)
				local selected
				local callback

				if DropdownOptions.Name == nil then
					error("Required setting 'Name' not given")
				end

				if DropdownOptions.Choices == nil then
					error("Required setting 'Choices' not given")
				end

				if DropdownOptions.CurrentState == nil then
					error("Required setting 'CurrentState' not given")
				else
					selected = DropdownOptions.CurrentState
				end

				if DropdownOptions.Callback ~= nil then
					callback = DropdownOptions.Callback
				end

				local function addChoices(v)
					local choice = Examples.Choice:Clone()
					choice.Name = v
					choice.Title.Text = v

					choice.Title.TextTransparency = 1
					choice.Parent = dropdownClone.Drop
					createTween(choice.Title, TweenPresets.Medium, { TextTransparency = 0 })

					choice.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
						if choice.Title.TextBounds.X > largestChoiceSize then
							largestChoiceSize = math.round(choice.Title.TextBounds.X) + 50
						end
						dropdownClone.Drop.Size = UDim2.new(0, largestChoiceSize, 0, 0)
						dropdownClone.Shadow.Position = UDim2.new(
							dropdownClone.Drop.Position.X.Scale,
							dropdownClone.Drop.Position.X.Offset,
							dropdownClone.Drop.Position.Y.Scale,
							dropdownClone.Drop.Position.Y.Offset - 10
						)
						dropdownClone.Shadow.Size = UDim2.new(
							0,
							dropdownClone.Drop.AbsoluteSize.X,
							0,
							dropdownClone.Drop.AbsoluteSize.Y
						) + UDim2.new(0, 20, 0, 20)
					end)

					choice.Hitbox.MouseEnter:Connect(function()
						createTween(choice, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(90, 90, 90) })
					end)

					choice.Hitbox.MouseLeave:Connect(function()
						createTween(choice, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(80, 80, 80) })
					end)

					choice.Hitbox.MouseButton1Down:Connect(function()
						createTween(choice, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(100, 100, 100) })
					end)

					choice.Hitbox.MouseButton1Up:Connect(function()
						createTween(choice, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(90, 90, 90) })
						if choice.Name ~= selected then
							createTween(dropdownClone.Drop[selected].Icon, TweenPresets.Fast, { ImageTransparency = 1 })
							createTween(choice.Icon, TweenPresets.Fast, { ImageTransparency = 0 })
							selected = choice.Name
							dropButton.Choice.Text = choice.Name

							if callback ~= nil then
								callback(choice.Name)
							end

							for _, v in pairs(dropdownClone.Drop:GetChildren()) do
								if v:IsA("Frame") then
									createTween(v, TweenPresets.Fast, { BackgroundTransparency = 1 })
									createTween(v.Title, TweenPresets.Fast, { TextTransparency = 1 })
									if v.Name == selected then
										createTween(v.Icon, TweenPresets.Fast, { ImageTransparency = 1 })
									end
								end
							end
							task.wait(0.02)
							createTween(dropButton.Icon, TweenPresets.Fast, { Rotation = 0 })
							createTween(dropdownClone.Drop, TweenPresets.Fast, { BackgroundTransparency = 1 })
							createTween(dropdownClone.Shadow, TweenPresets.Fast, { ImageTransparency = 1 })
							createTween(dropdownClone.Triangle, TweenPresets.Medium, { ImageTransparency = 1 })
							task.wait(0.3)
							dropdownClone.Drop.Visible = false
						end
					end)
				end

				for _, v in pairs(DropdownOptions.Choices) do
					addChoices(v)
				end

				for _, v in pairs(dropdownClone.Drop:GetChildren()) do
					if v:IsA("Frame") then
						v.BackgroundTransparency = 1
						v.Title.TextTransparency = 1
						v.Icon.ImageTransparency = 1
					end
				end

				handleCornerRadius(dropdownClone)
				dropButton.Choice.Text = selected
				dropdownClone.Title.Text = DropdownOptions.Name
				dropdownClone.Name = DropdownOptions.Name

				dropdownClone.BackgroundTransparency = 1
				dropdownClone.Title.TextTransparency = 1
				dropButton.BackgroundTransparency = 1
				dropButton.Choice.TextTransparency = 1
				dropButton.Icon.ImageTransparency = 1
				dropdownClone.Drop.BackgroundTransparency = 1
				dropdownClone.Triangle.ImageTransparency = 1
				dropdownClone.Shadow.ImageTransparency = 1
				dropdownClone.Drop.Visible = false

				dropdownClone.Parent = sectionClone

				createTween(dropdownClone, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(dropdownClone.Title, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(dropButton, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(dropButton.Choice, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(dropButton.Icon, TweenPresets.Medium, { ImageTransparency = 0 })

				dropdownClone.MouseEnter:Connect(function()
					createTween(dropdownClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
				end)

				dropdownClone.MouseLeave:Connect(function()
					createTween(dropdownClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(54, 54, 54) })
				end)

				dropButton.Hitbox.MouseEnter:Connect(function()
					createTween(dropButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(86, 86, 86) })
				end)

				dropButton.Hitbox.MouseLeave:Connect(function()
					createTween(dropButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(80, 80, 80) })
				end)

				dropButton.Hitbox.MouseButton1Down:Connect(function()
					createTween(dropButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(95, 95, 95) })
				end)

				dropButton.Hitbox.MouseButton1Up:Connect(function()
					if dropdownClone.Drop.Visible == false then
						dropdownClone.Drop.Visible = true
						createTween(dropButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(86, 86, 86) })
						createTween(dropButton.Icon, TweenPresets.Medium, { Rotation = 180 })
						createTween(dropdownClone.Drop, TweenPresets.Fast, { BackgroundTransparency = 0 })
						createTween(dropdownClone.Shadow, TweenPresets.Fast, { ImageTransparency = 0.88 })
						createTween(dropdownClone.Triangle, TweenPresets.Fast, { ImageTransparency = 0 })
						task.wait(0.01)
						for _, v in pairs(dropdownClone.Drop:GetChildren()) do
							if v:IsA("Frame") then
								createTween(v, TweenPresets.Fast, { BackgroundTransparency = 0 })
								createTween(v.Title, TweenPresets.Fast, { TextTransparency = 0 })
								if v.Name == selected then
									createTween(v.Icon, TweenPresets.Fast, { ImageTransparency = 0 })
								end
							end
						end
					else
						createTween(dropButton, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(86, 86, 86) })
						for _, v in pairs(dropdownClone.Drop:GetChildren()) do
							if v:IsA("Frame") then
								createTween(v, TweenPresets.Fast, { BackgroundTransparency = 1 })
								createTween(v.Title, TweenPresets.Fast, { TextTransparency = 1 })
								if v.Name == selected then
									createTween(v.Icon, TweenPresets.Fast, { ImageTransparency = 1 })
								end
							end
						end
						task.wait(0.02)
						createTween(dropButton.Icon, TweenPresets.Fast, { Rotation = 0 })
						createTween(dropdownClone.Drop, TweenPresets.Fast, { BackgroundTransparency = 1 })
						createTween(dropdownClone.Shadow, TweenPresets.Fast, { ImageTransparency = 1 })
						createTween(dropdownClone.Triangle, TweenPresets.Medium, { ImageTransparency = 1 })
						task.wait(0.3)
						dropdownClone.Drop.Visible = false
					end
				end)

				local dropdownFuncs = {}
				function dropdownFuncs:Edit(newDropdownOptions)
					descExists = editDesc(dropdownClone, newDropdownOptions)

					if newDropdownOptions.Name ~= nil then
						dropdownClone.Name = newDropdownOptions.Name
						dropdownClone.Title.Text = newDropdownOptions.Name
					end

					if newDropdownOptions.Choices ~= nil then
						for _, v in pairs(dropdownClone.Drop:GetChildren()) do
							if v:IsA("Frame") then
								v:Destroy()
							end
						end
						for _, v in pairs(newDropdownOptions.Choices) do
							addChoices(v)
						end
					end

					if newDropdownOptions.Callback ~= nil then
						callback = newDropdownOptions.Callback
					end

					if newDropdownOptions.CurrentState ~= nil then
						selected = newDropdownOptions.CurrentState
						dropButton.Choice.Text = selected

						for _, v in pairs(dropdownClone.Drop:GetChildren()) do
							if v:IsA("Frame") then
								if v.Name == selected then
									createTween(v.Icon, TweenPresets.Medium, { ImageTransparency = 0 })
								else
									createTween(v.Icon, TweenPresets.Medium, { ImageTransparency = 1 })
								end
							end
						end
					end
				end

				function dropdownFuncs:Remove()
					createTween(dropdownClone, TweenPresets.Medium, { BackgroundTransparency = 1 })
					createTween(dropdownClone, TweenPresets.Medium, { Size = UDim2.new(1, 0, 0, 0) })
					createTween(dropdownClone.Title, TweenPresets.Medium, { TextTransparency = 1 })
					createTween(dropdownClone.Icon, TweenPresets.Medium, { ImageTransparency = 1 })
					if descExists == true then
						createTween(dropdownClone.Description, TweenPresets.Medium, { TextTransparency = 1 })
					end
					if dropdownClone:FindFirstChild("CornerCover") then
						createTween(dropdownClone.CornerCover, TweenPresets.Medium, { BackgroundTransparency = 1 })
					end
					task.wait(0.5)
					OnMainElementRemove()
					dropdownClone:Destroy()
				end

				return dropdownFuncs
			end

			function sectionFuncs:NewSlider(SliderOptions)
				local slierClone = Examples.Slider:Clone()
				local bar = slierClone.Container.Bar
				local circle = bar.Circle
				local valueIndicator = circle.Value
				local value = slierClone.Value

				local callback
				local step
				local percentage = 0
				local dragging = false

				if SliderOptions.Name == nil then
					error("Required setting 'Name' not given")
				end

				if SliderOptions.Increment == nil then
					error("Required setting 'Increment' not given")
				end

				if SliderOptions.MinMax == nil then
					error("Required setting 'MinMax' not given")
				end

				if SliderOptions.CurrentValue ~= nil then
					value.Value = SliderOptions.CurrentValue
					valueIndicator.Text = SliderOptions.CurrentValue
					percentage = SliderOptions.CurrentValue / SliderOptions.MinMax[2]
					createTween(
						circle,
						TweenPresets.Fast,
						{
							Position = UDim2.new(
								SliderOptions.CurrentValue / SliderOptions.MinMax[2],
								0,
								circle.Position.Y.Scale,
								circle.Position.Y.Offset
							),
						}
					)
				else
					error("Required setting 'CurrentValue' not given")
				end

				if SliderOptions.Callback ~= nil then
					callback = SliderOptions.Callback
				end

				slierClone.Title.Text = SliderOptions.Name
				slierClone.Description.Text = SliderOptions.Description

				handleCornerRadius(slierClone)
				step = SliderOptions.Increment / (SliderOptions.MinMax[2] - SliderOptions.MinMax[1])

				slierClone.BackgroundTransparency = 1
				slierClone.Title.TextTransparency = 1
				slierClone.Description.TextTransparency = 1
				bar.BackgroundTransparency = 1
				circle.BackgroundTransparency = 1
				valueIndicator.TextTransparency = 1

				slierClone.Parent = sectionClone

				createTween(slierClone, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(slierClone.Title, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(slierClone.Description, TweenPresets.Medium, { TextTransparency = 0 })
				createTween(bar, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(circle, TweenPresets.Medium, { BackgroundTransparency = 0 })
				createTween(valueIndicator, TweenPresets.Medium, { TextTransparency = 0 })

				local function snap(number, factor)
					if factor == 0 then
						return number
					else
						return math.floor(number / factor + 0.5) * factor
					end
				end

				value:GetPropertyChangedSignal("Value"):Connect(function()
					createTween(
						circle,
						TweenPresets.Fast,
						{ Position = UDim2.new(percentage, 0, circle.Position.Y.Scale, circle.Position.Y.Offset) }
					)
					valueIndicator.Text = value.Value
					if callback ~= nil then
						callback(value.Value)
					end
				end)

				slierClone.MouseEnter:Connect(function()
					createTween(slierClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(60, 60, 60) })
				end)

				slierClone.MouseLeave:Connect(function()
					createTween(slierClone, TweenPresets.Fast, { BackgroundColor3 = Color3.fromRGB(54, 54, 54) })
				end)

				circle.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				circle.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						while dragging do
							task.wait()
							percentage = math.clamp(
								snap((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, step),
								0,
								1
							)
							value.Value = math.round(
								SliderOptions.MinMax[1]
									+ (percentage * (SliderOptions.MinMax[2] - SliderOptions.MinMax[1]))
							)
						end
					end
				end)
			end

			function sectionFuncs:Edit(NewOptions) -- edit section
				if NewOptions.Name ~= nil then
					sectionClone.Name = NewOptions.Name
					sectionClone.Title.Text = NewOptions.Name
				end
				if NewOptions.Description ~= nil then
					sectionClone.Description.Text = NewOptions.Description
				end
			end
			function sectionFuncs:Remove() -- remove section
				createTween(sectionClone.Title, TweenPresets.Medium, { TextTransparency = 1 })
				if sectionClone.Description ~= nil then
					createTween(sectionClone.Description, TweenPresets.Medium, { TextTransparency = 1 })
				end
				task.wait(0.5)
				sectionClone:Destroy()
			end

			return sectionFuncs
		end

		function tabFuncs:Remove() -- remove tab
			for i, v in pairs(TabTable) do
				if v.Name == tabName then
					table.remove(TabTable, i)
				end
			end
			createTween(tabButtonClone, TweenPresets.Medium, { BackgroundTransparency = 1 })
			createTween(tabButtonClone, TweenPresets.Medium, { Size = UDim2.new(0, 182, 0, 0) })
			createTween(tabButtonClone.Icon, TweenPresets.Medium, { ImageTransparency = 1 })
			createTween(tabButtonClone.Title, TweenPresets.Medium, { TextTransparency = 1 })
			task.wait(0.5)
			tabButtonClone:Destroy()
			tabClone:Destroy()
		end

		function tabFuncs:Edit(NewTabOptions) -- edit tab
			tabButtonClone.Title.Text = NewTabOptions.Name
			tabButtonClone.Name = NewTabOptions.Name
			tabClone.Name = NewTabOptions.Name
			for _, v in pairs(TabTable) do
				if v.Name == tabName then
					v.Name = NewTabOptions.Name
				end
			end
			if NewTabOptions.Icon then
				if tabButtonClone.Icon.Visible == true then
					createTween(tabButtonClone.Icon, TweenPresets.Medium, { ImageTransparency = 1 })
					wait(0.5)
				end
				tabButtonClone.Icon.Visible = true
				tabButtonClone.Icon.Image = NewTabOptions.Icon
				tabButtonClone.Icon.ImageTransparency = 1
				createTween(tabButtonClone.Title, TweenPresets.Medium, { Position = UDim2.new(0.574, 0, 0.5, 0) })
				createTween(tabButtonClone.Icon, TweenPresets.Medium, { ImageTransparency = 0 })
			end
		end

		return tabFuncs
	end

	function window:NewSeparator()
		local separatorClone = Examples.Separator:Clone()
		separatorClone.BackgroundTransparency = 1
		separatorClone.Parent = tabButtons

		createTween(separatorClone, TweenPresets.Fast, { BackgroundTransparency = 0 })

		local separatorFuncs = {}

		function separatorFuncs:Remove()
			createTween(separatorClone, TweenPresets.Medium, { BackgroundTransparency = 1 })
			task.wait(0.5)
			separatorClone:Destroy()
		end

		return separatorFuncs
	end

	return window
end

return rolibwaita
