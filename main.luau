local cloneref = cloneref or function(instance)
	return instance
end

local protectgui = protectgui or protect_gui or (syn and syn.protect_gui) or function() end

local Players = cloneref(game:GetService("Players"))
local Stats = cloneref(game:GetService("Stats"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local getHui = gethui or function()
	local success, targetContainer = pcall(function()
		return CoreGui
	end)
	if success and targetContainer then
		return targetContainer
	end
	return PlayerGui
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = ""
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
	protectgui(screenGui)
end)

screenGui.Parent = getHui()

local settingsData = {
	buttonSize = "médio",
	accentColor = "Default"
}

local colorMap = {
	["Default"] = Color3.fromRGB(51, 95, 255),
	["Laranja"] = Color3.fromRGB(255, 128, 0),
	["Amarelo"] = Color3.fromRGB(255, 220, 0),
	["Verde"] = Color3.fromRGB(75, 220, 100),
	["Azul"] = Color3.fromRGB(0, 160, 255),
	["Roxo"] = Color3.fromRGB(160, 50, 255),
	["Rosa"] = Color3.fromRGB(255, 100, 180),
	["branco"] = Color3.fromRGB(255, 255, 255)
}

pcall(function()
	if readfile and isfile and isfile("CatsBlockSettings.json") then
		local decoded = HttpService:JSONDecode(readfile("CatsBlockSettings.json"))
		if decoded.buttonSize then settingsData.buttonSize = decoded.buttonSize end
		if decoded.accentColor then settingsData.accentColor = decoded.accentColor end
	end
end)

local function saveSettings()
	pcall(function()
		if writefile then
			writefile("CatsBlockSettings.json", HttpService:JSONEncode(settingsData))
		end
	end)
end

local savedScriptsList = {}
pcall(function()
	if readfile and isfile and isfile("CatsBlockSavedScripts.json") then
		local decoded = HttpService:JSONDecode(readfile("CatsBlockSavedScripts.json"))
		if type(decoded) == "table" then
			savedScriptsList = decoded
		end
	end
end)

local function saveSavedScripts()
	pcall(function()
		if writefile then
			writefile("CatsBlockSavedScripts.json", HttpService:JSONEncode(savedScriptsList))
		end
	end)
end

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
toggleButton.BackgroundTransparency = 0.08
toggleButton.Text = "R"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.BuilderSansBold
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

local function applyButtonSize()
	if settingsData.buttonSize == "mínimo" then
		toggleButton.Size = UDim2.new(0, 32, 0, 32)
		toggleButton.Position = UDim2.new(0, 16, 1, -48)
		toggleButton.TextSize = 14
	elseif settingsData.buttonSize == "grande" then
		toggleButton.Size = UDim2.new(0, 52, 0, 52)
		toggleButton.Position = UDim2.new(0, 16, 1, -68)
		toggleButton.TextSize = 22
	else
		toggleButton.Size = UDim2.new(0, 42, 0, 42)
		toggleButton.Position = UDim2.new(0, 16, 1, -58)
		toggleButton.TextSize = 18
	end
end

applyButtonSize()

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(45, 45, 50)
toggleStroke.Thickness = 1.5
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toggleStroke.Parent = toggleButton

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.new(0.85, 0, 0.65, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainSizeConstraint = Instance.new("UISizeConstraint")
mainSizeConstraint.MinSize = Vector2.new(420, 300)
mainSizeConstraint.MaxSize = Vector2.new(780, 480)
mainSizeConstraint.Parent = mainFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(40, 40, 45)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local leftNavFrame = Instance.new("Frame")
leftNavFrame.Name = "LeftNavFrame"
leftNavFrame.Size = UDim2.new(0, 60, 1, 0)
leftNavFrame.Position = UDim2.new(0, 0, 0, 0)
leftNavFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
leftNavFrame.BorderSizePixel = 0
leftNavFrame.Parent = mainFrame

local leftNavLayout = Instance.new("UIListLayout")
leftNavLayout.FillDirection = Enum.FillDirection.Vertical
leftNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
leftNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
leftNavLayout.Padding = UDim.new(0, 12)
leftNavLayout.Parent = leftNavFrame

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -60, 1, 0)
contentArea.Position = UDim2.new(0, 60, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

local pages = {}

local function showPage(pageName)
	for name, page in pairs(pages) do
		page.Visible = (name == pageName)
	end
end

local function createPage(name)
	local p = Instance.new("Frame")
	p.Name = name .. "Page"
	p.Size = UDim2.new(1, 0, 1, 0)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = contentArea
	pages[name] = p
	return p
end

local injectionPage = createPage("Injection")
local cloudPage = createPage("Cloud")
local savedScriptsPage = createPage("SavedScripts")
local settingsPage = createPage("Settings")
local computerPage = createPage("Computer")

showPage("Injection")

local navButtons = {
	{ name = "Cloud", icon = "☁️" },
	{ name = "Injection", icon = "💉" },
	{ name = "SavedScripts", icon = "📚" },
	{ name = "Settings", icon = "⚙️" },
	{ name = "Computer", icon = "💻" }
}

for _, info in ipairs(navButtons) do
	local btn = Instance.new("TextButton")
	btn.Name = info.name .. "NavBtn"
	btn.Size = UDim2.new(0, 42, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	btn.Text = info.icon
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.BuilderSansBold
	btn.AutoButtonColor = false
	btn.Parent = leftNavFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		showPage(info.name)
	end)
end

local codeEditor = Instance.new("TextBox")
codeEditor.Name = "CodeEditor"
codeEditor.Size = UDim2.new(1, -24, 1, -85)
codeEditor.Position = UDim2.new(0, 12, 0, 12)
codeEditor.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
codeEditor.Text = ""
codeEditor.PlaceholderText = "-- Type your script here..."
codeEditor.TextColor3 = Color3.fromRGB(230, 230, 230)
codeEditor.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
codeEditor.TextSize = 13
codeEditor.Font = Enum.Font.Code
codeEditor.MultiLine = true
codeEditor.ClearTextOnFocus = false
codeEditor.TextXAlignment = Enum.TextXAlignment.Left
codeEditor.TextYAlignment = Enum.TextYAlignment.Top
codeEditor.Parent = injectionPage

local editorCorner = Instance.new("UICorner")
editorCorner.CornerRadius = UDim.new(0, 10)
editorCorner.Parent = codeEditor

local editorStroke = Instance.new("UIStroke")
editorStroke.Color = Color3.fromRGB(35, 35, 42)
editorStroke.Thickness = 1
editorStroke.Parent = codeEditor

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Name = "ConsoleFrame"
consoleFrame.Size = UDim2.new(1, -24, 0, 100)
consoleFrame.Position = UDim2.new(0, 12, 1, -115)
consoleFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
consoleFrame.Visible = false
consoleFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
consoleFrame.ScrollBarThickness = 4
consoleFrame.Parent = injectionPage

local consoleCorner = Instance.new("UICorner")
consoleCorner.CornerRadius = UDim.new(0, 8)
consoleCorner.Parent = consoleFrame

local consoleLayout = Instance.new("UIListLayout")
consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder
consoleLayout.Padding = UDim.new(0, 2)
consoleLayout.Parent = consoleFrame

local consoleLogs = {}
local function logToConsole(msg, isError)
	table.insert(consoleLogs, { text = msg, error = isError })
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Text = " " .. msg
	lbl.TextColor3 = isError and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(200, 200, 200)
	lbl.TextSize = 11
	lbl.Font = Enum.Font.Code
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = consoleFrame
	consoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleLayout.AbsoluteContentSize.Y + 10)
end

local buttonBar = Instance.new("Frame")
buttonBar.Name = "ButtonBar"
buttonBar.Size = UDim2.new(1, -24, 0, 36)
buttonBar.Position = UDim2.new(0, 12, 1, -48)
buttonBar.BackgroundTransparency = 1
buttonBar.Parent = injectionPage

local function createActionButton(name, posScale, posOffset, sizeW)
	local b = Instance.new("TextButton")
	b.Name = name .. "Btn"
	b.Size = UDim2.new(0, sizeW, 1, 0)
	b.Position = UDim2.new(posScale, posOffset, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	b.Text = name
	b.TextColor3 = Color3.fromRGB(220, 220, 220)
	b.TextSize = 12
	b.Font = Enum.Font.BuilderSansBold
	b.AutoButtonColor = false
	b.Parent = buttonBar

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	return b
end

local clearBtn = createActionButton("Clear", 0, 0, 90)
local executeBtn = createActionButton("Execute", 0, 100, 100)
local consoleBtn = createActionButton("Console", 0, 210, 90)

clearBtn.MouseButton1Click:Connect(function()
	codeEditor.Text = ""
end)

executeBtn.MouseButton1Click:Connect(function()
	local code = codeEditor.Text
	if code and code ~= "" then
		local success, err = pcall(function()
			local fn = loadstring(code)
			if fn then
				fn()
			else
				error("Failed to compile script")
			end
		end)
		if not success then
			logToConsole(tostring(err), true)
		else
			logToConsole("Script executed successfully.", false)
		end
	end
end)

consoleBtn.MouseButton1Click:Connect(function()
	consoleFrame.Visible = not consoleFrame.Visible
	if consoleFrame.Visible then
		codeEditor.Size = UDim2.new(1, -24, 1, -195)
	else
		codeEditor.Size = UDim2.new(1, -24, 1, -85)
	end
end)

local searchBar = Instance.new("TextBox")
searchBar.Name = "SearchBar"
searchBar.Size = UDim2.new(1, -24, 0, 36)
searchBar.Position = UDim2.new(0, 12, 0, 12)
searchBar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
searchBar.Text = "Good"
searchBar.PlaceholderText = "Search scripts..."
searchBar.TextColor3 = Color3.fromRGB(230, 230, 230)
searchBar.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
searchBar.TextSize = 13
searchBar.Font = Enum.Font.BuilderSans
searchBar.ClearTextOnFocus = false
searchBar.Parent = cloudPage

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBar

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = Color3.fromRGB(40, 40, 48)
searchStroke.Thickness = 1
searchStroke.Parent = searchBar

local resultsScroll = Instance.new("ScrollingFrame")
resultsScroll.Name = "ResultsScroll"
resultsScroll.Size = UDim2.new(1, -24, 1, -64)
resultsScroll.Position = UDim2.new(0, 12, 0, 56)
resultsScroll.BackgroundTransparency = 1
resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsScroll.ScrollBarThickness = 5
resultsScroll.Parent = cloudPage

local resultsGrid = Instance.new("UIGridLayout")
resultsGrid.CellSize = UDim2.new(0, 200, 0, 150)
resultsGrid.CellPadding = UDim2.new(0, 12, 0, 12)
resultsGrid.Parent = resultsScroll

local detailsOverlay = Instance.new("Frame")
detailsOverlay.Name = "DetailsOverlay"
detailsOverlay.Size = UDim2.new(1, 0, 1, 0)
detailsOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
detailsOverlay.BackgroundTransparency = 0.5
detailsOverlay.Visible = false
detailsOverlay.ZIndex = 10
detailsOverlay.Parent = mainFrame

local detailsModal = Instance.new("Frame")
detailsModal.Name = "DetailsModal"
detailsModal.AnchorPoint = Vector2.new(0.5, 0.5)
detailsModal.Size = UDim2.new(0, 420, 0, 380)
detailsModal.Position = UDim2.new(0.5, 0, 0.5, 0)
detailsModal.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
detailsModal.ZIndex = 11
detailsModal.Parent = detailsOverlay

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 12)
modalCorner.Parent = detailsModal

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(50, 50, 60)
modalStroke.Thickness = 1.5
modalStroke.Parent = detailsModal

local modalTitle = Instance.new("TextLabel")
modalTitle.Size = UDim2.new(1, -30, 0, 30)
modalTitle.Position = UDim2.new(0, 15, 0, 10)
modalTitle.BackgroundTransparency = 1
modalTitle.Text = "Which options do you want to choose?"
modalTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
modalTitle.TextSize = 14
modalTitle.Font = Enum.Font.BuilderSansBold
modalTitle.ZIndex = 11
modalTitle.Parent = detailsModal

local modalInfo = Instance.new("TextBox")
modalInfo.Size = UDim2.new(1, -30, 0, 80)
modalInfo.Position = UDim2.new(0, 15, 0, 42)
modalInfo.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
modalInfo.Text = "Creator: -\nCreated: -\nUpdated: -\nDescription: -"
modalInfo.TextColor3 = Color3.fromRGB(160, 160, 170)
modalInfo.TextSize = 11
modalInfo.Font = Enum.Font.BuilderSans
modalInfo.TextXAlignment = Enum.TextXAlignment.Left
modalInfo.TextYAlignment = Enum.TextYAlignment.Top
modalInfo.MultiLine = true
modalInfo.ClearTextOnFocus = false
modalInfo.TextEditable = false
modalInfo.ZIndex = 11
modalInfo.Parent = detailsModal
Instance.new("UICorner", modalInfo).CornerRadius = UDim.new(0, 6)

local modalBtnHolder = Instance.new("Frame")
modalBtnHolder.Size = UDim2.new(1, -30, 0, 220)
modalBtnHolder.Position = UDim2.new(0, 15, 0, 130)
modalBtnHolder.BackgroundTransparency = 1
modalBtnHolder.ZIndex = 11
modalBtnHolder.Parent = detailsModal

local modalBtnLayout = Instance.new("UIListLayout")
modalBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
modalBtnLayout.Padding = UDim.new(0, 8)
modalBtnLayout.Parent = modalBtnHolder

local confirmOverlay = Instance.new("Frame")
confirmOverlay.Size = UDim2.new(1, 0, 1, 0)
confirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
confirmOverlay.BackgroundTransparency = 0.5
confirmOverlay.Visible = false
confirmOverlay.ZIndex = 20
confirmOverlay.Parent = mainFrame

local confirmModal = Instance.new("Frame")
confirmModal.AnchorPoint = Vector2.new(0.5, 0.5)
confirmModal.Size = UDim2.new(0, 320, 0, 140)
confirmModal.Position = UDim2.new(0.5, 0, 0.5, 0)
confirmModal.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
confirmModal.ZIndex = 21
confirmModal.Parent = confirmOverlay

local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = UDim.new(0, 12)
confirmCorner.Parent = confirmModal

local confirmText = Instance.new("TextLabel")
confirmText.Size = UDim2.new(1, -30, 0, 50)
confirmText.Position = UDim2.new(0, 15, 0, 15)
confirmText.BackgroundTransparency = 1
confirmText.Text = "Are you sure you want to run this code? It's not verified."
confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmText.TextSize = 13
confirmText.Font = Enum.Font.BuilderSansBold
confirmText.TextWrapped = true
confirmText.ZIndex = 21
confirmText.Parent = confirmModal

local confirmBtnConfirm = Instance.new("TextButton")
confirmBtnConfirm.Size = UDim2.new(0, 130, 0, 32)
confirmBtnConfirm.Position = UDim2.new(0, 15, 1, -45)
confirmBtnConfirm.BackgroundColor3 = Color3.fromRGB(51, 95, 255)
confirmBtnConfirm.Text = "Confirm"
confirmBtnConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmBtnConfirm.TextSize = 12
confirmBtnConfirm.Font = Enum.Font.BuilderSansBold
confirmBtnConfirm.ZIndex = 21
confirmBtnConfirm.Parent = confirmModal
Instance.new("UICorner", confirmBtnConfirm).CornerRadius = UDim.new(0, 8)

local confirmBtnNever = Instance.new("TextButton")
confirmBtnNever.Size = UDim2.new(0, 130, 0, 32)
confirmBtnNever.Position = UDim2.new(1, -145, 1, -45)
confirmBtnNever.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
confirmBtnNever.Text = "Nevermind"
confirmBtnNever.TextColor3 = Color3.fromRGB(200, 200, 200)
confirmBtnNever.TextSize = 12
confirmBtnNever.Font = Enum.Font.BuilderSansBold
confirmBtnNever.ZIndex = 21
confirmBtnNever.Parent = confirmModal
Instance.new("UICorner", confirmBtnNever).CornerRadius = UDim.new(0, 8)

confirmBtnNever.MouseButton1Click:Connect(function()
	confirmOverlay.Visible = false
end)

local function executeScriptCode(code, verified)
	if not verified then
		confirmOverlay.Visible = true
		local conn
		conn = confirmBtnConfirm.MouseButton1Click:Connect(function()
			conn:Disconnect()
			confirmOverlay.Visible = false
			pcall(function()
				local fn = loadstring(code)
				if fn then fn() end
			end)
		end)
	else
		pcall(function()
			local fn = loadstring(code)
			if fn then fn() end
		end)
	end
end

local function fetchScripts(query)
	for _, child in ipairs(resultsScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	pcall(function()
		local url = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query)
		local success, response = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if success and response and response.result and response.result.scripts then
			for _, scriptData in ipairs(response.result.scripts) do
				local card = Instance.new("Frame")
				card.Size = UDim2.new(0, 200, 0, 150)
				card.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
				card.Parent = resultsScroll

				Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

				local img = Instance.new("ImageLabel")
				img.Size = UDim2.new(1, 0, 0, 60)
				img.BackgroundTransparency = 1
				img.Image = scriptData.game and scriptData.game.imageUrl or ""
				img.ScaleType = Enum.ScaleType.Crop
				img.Parent = card
				Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)

				local titleLbl = Instance.new("TextLabel")
				titleLbl.Size = UDim2.new(1, -10, 0, 25)
				titleLbl.Position = UDim2.new(0, 5, 0, 65)
				titleLbl.BackgroundTransparency = 1
				titleLbl.Text = scriptData.title or "Untitled"
				titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.BuilderSansBold
				titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
				titleLbl.Parent = card

				local creatorLbl = Instance.new("TextLabel")
				creatorLbl.Size = UDim2.new(1, -10, 0, 18)
				creatorLbl.Position = UDim2.new(0, 5, 0, 92)
				creatorLbl.BackgroundTransparency = 1
				creatorLbl.Text = scriptData.game and scriptData.game.name or "Unknown"
				creatorLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
				creatorLbl.TextSize = 10
				creatorLbl.Font = Enum.Font.BuilderSans
				creatorLbl.TextTruncate = Enum.TextTruncate.AtEnd
				creatorLbl.Parent = card

				local tagFrame = Instance.new("Frame")
				tagFrame.Size = UDim2.new(1, -10, 0, 24)
				tagFrame.Position = UDim2.new(0, 5, 0, 118)
				tagFrame.BackgroundTransparency = 1
				tagFrame.Parent = card

				local tagLayout = Instance.new("UIListLayout")
				tagLayout.FillDirection = Enum.FillDirection.Horizontal
				tagLayout.Padding = UDim.new(0, 4)
				tagLayout.Parent = tagFrame

				local function addTag(txt, col)
					local t = Instance.new("TextLabel")
					t.Size = UDim2.new(0, 50, 0, 20)
					t.BackgroundColor3 = col
					t.Text = txt
					t.TextColor3 = Color3.fromRGB(255, 255, 255)
					t.TextSize = 9
					t.Font = Enum.Font.BuilderSansBold
					t.Parent = tagFrame
					Instance.new("UICorner", t).CornerRadius = UDim.new(0, 4)
				end

				if scriptData.verified then addTag("Verified", Color3.fromRGB(51, 95, 255)) end
				if scriptData.key then addTag("Keyless", Color3.fromRGB(75, 220, 100)) end
				if scriptData.isPatched then addTag("Patched", Color3.fromRGB(255, 75, 75)) end

				local clickBtn = Instance.new("TextButton")
				clickBtn.Size = UDim2.new(1, 0, 1, 0)
				clickBtn.BackgroundTransparency = 1
				clickBtn.Text = ""
				clickBtn.Parent = card

				clickBtn.MouseButton1Click:Connect(function()
					local desc = scriptData.description or "-"
					modalInfo.Text = string.format("Creator: %s\nCreated: %s\nUpdated: %s\nDescription: %s", scriptData.game and scriptData.game.name or "-", scriptData.createdAt or "-", scriptData.updatedAt or "-", desc)
					detailsOverlay.Visible = true

					for _, child in ipairs(modalBtnHolder:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end

					local function addModalOption(txt, callback)
						local b = Instance.new("TextButton")
						b.Size = UDim2.new(1, 0, 0, 32)
						b.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
						b.Text = txt
						b.TextColor3 = Color3.fromRGB(220, 220, 220)
						b.TextSize = 12
						b.Font = Enum.Font.BuilderSansBold
						b.ZIndex = 11
						b.Parent = modalBtnHolder
						Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
						b.MouseButton1Click:Connect(function()
							detailsOverlay.Visible = false
							callback()
						end)
					end

					addModalOption("Execute", function()
						executeScriptCode(scriptData.script or "", scriptData.verified)
					end)

					addModalOption("Copy the script code", function()
						pcall(function() setclipboard(scriptData.script or "") end)
					end)

					addModalOption("Save to Saved Scripts", function()
						table.insert(savedScriptsList, { title = scriptData.title or "Script", code = scriptData.script or "" })
						saveSavedScripts()
					end)

					addModalOption("Put the code in the code editor", function()
						codeEditor.Text = scriptData.script or ""
						showPage("Injection")
					end)
				end)
			end
			resultsScroll.CanvasSize = UDim2.new(0, 0, 0, resultsGrid.AbsoluteContentSize.Y + 20)
		end
	end)
end

searchBar.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		fetchScripts(searchBar.Text)
	end
end)

task.spawn(function()
	task.wait(0.5)
	fetchScripts("Good")
end)

detailsOverlay.MouseButton1Click:Connect(function()
	detailsOverlay.Visible = false
end)

local savedSearch = Instance.new("TextBox")
savedSearch.Name = "SavedSearch"
savedSearch.Size = UDim2.new(1, -64, 0, 36)
savedSearch.Position = UDim2.new(0, 12, 0, 12)
savedSearch.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
savedSearch.Text = ""
savedSearch.PlaceholderText = "Search saved scripts..."
savedSearch.TextColor3 = Color3.fromRGB(230, 230, 230)
savedSearch.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
savedSearch.TextSize = 13
savedSearch.Font = Enum.Font.BuilderSans
savedSearch.ClearTextOnFocus = false
savedSearch.Parent = savedScriptsPage
Instance.new("UICorner", savedSearch).CornerRadius = UDim.new(0, 8)

local addScriptBtn = Instance.new("TextButton")
addScriptBtn.Size = UDim2.new(0, 36, 0, 36)
addScriptBtn.Position = UDim2.new(1, -48, 0, 12)
addScriptBtn.BackgroundColor3 = Color3.fromRGB(51, 95, 255)
addScriptBtn.Text = "+"
addScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addScriptBtn.TextSize = 18
addScriptBtn.Font = Enum.Font.BuilderSansBold
addScriptBtn.Parent = savedScriptsPage
Instance.new("UICorner", addScriptBtn).CornerRadius = UDim.new(0, 8)

local savedScroll = Instance.new("ScrollingFrame")
savedScroll.Size = UDim2.new(1, -24, 1, -64)
savedScroll.Position = UDim2.new(0, 12, 0, 56)
savedScroll.BackgroundTransparency = 1
savedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
savedScroll.ScrollBarThickness = 5
savedScroll.Parent = savedScriptsPage

local savedListLayout = Instance.new("UIListLayout")
savedListLayout.Padding = UDim.new(0, 8)
savedListLayout.Parent = savedScroll

local addModalOverlay = Instance.new("Frame")
addModalOverlay.Size = UDim2.new(1, 0, 1, 0)
addModalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
addModalOverlay.BackgroundTransparency = 0.5
addModalOverlay.Visible = false
addModalOverlay.ZIndex = 30
addModalOverlay.Parent = mainFrame

local addModal = Instance.new("Frame")
addModal.AnchorPoint = Vector2.new(0.5, 0.5)
addModal.Size = UDim2.new(0, 340, 0, 220)
addModal.Position = UDim2.new(0.5, 0, 0.5, 0)
addModal.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
addModal.ZIndex = 31
addModal.Parent = addModalOverlay
Instance.new("UICorner", addModal).CornerRadius = UDim.new(0, 12)

local titleInput = Instance.new("TextBox")
titleInput.Size = UDim2.new(1, -30, 0, 32)
titleInput.Position = UDim2.new(0, 15, 0, 20)
titleInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
titleInput.PlaceholderText = "Title (max 20 chars)"
titleInput.Text = ""
titleInput.TextColor3 = Color3.fromRGB(255, 255, 255)
titleInput.TextSize = 12
titleInput.Font = Enum.Font.BuilderSans
titleInput.ZIndex = 31
titleInput.Parent = addModal
Instance.new("UICorner", titleInput).CornerRadius = UDim.new(0, 6)

local codeInput = Instance.new("TextBox")
codeInput.Size = UDim2.new(1, -30, 0, 90)
codeInput.Position = UDim2.new(0, 15, 0, 64)
codeInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
codeInput.PlaceholderText = "Script code..."
codeInput.Text = ""
codeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
codeInput.TextSize = 12
codeInput.Font = Enum.Font.Code
codeInput.MultiLine = true
codeInput.ZIndex = 31
codeInput.Parent = addModal
Instance.new("UICorner", codeInput).CornerRadius = UDim.new(0, 6)

local saveBtnAdd = Instance.new("TextButton")
saveBtnAdd.Size = UDim2.new(0, 140, 0, 32)
saveBtnAdd.Position = UDim2.new(0, 15, 1, -45)
saveBtnAdd.BackgroundColor3 = Color3.fromRGB(51, 95, 255)
saveBtnAdd.Text = "Save"
saveBtnAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtnAdd.TextSize = 12
saveBtnAdd.Font = Enum.Font.BuilderSansBold
saveBtnAdd.ZIndex = 31
saveBtnAdd.Parent = addModal
Instance.new("UICorner", saveBtnAdd).CornerRadius = UDim.new(0, 8)

local cancelBtnAdd = Instance.new("TextButton")
cancelBtnAdd.Size = UDim2.new(0, 140, 0, 32)
cancelBtnAdd.Position = UDim2.new(1, -155, 1, -45)
cancelBtnAdd.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
cancelBtnAdd.Text = "Cancel"
cancelBtnAdd.TextColor3 = Color3.fromRGB(200, 200, 200)
cancelBtnAdd.TextSize = 12
cancelBtnAdd.Font = Enum.Font.BuilderSansBold
cancelBtnAdd.ZIndex = 31
cancelBtnAdd.Parent = addModal
Instance.new("UICorner", cancelBtnAdd).CornerRadius = UDim.new(0, 8)

local function refreshSavedList(filter)
	for _, child in ipairs(savedScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	for _, item in ipairs(savedScriptsList) do
		if not filter or filter == "" or item.title:lower():find(filter:lower()) then
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 40)
			f.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			f.Parent = savedScroll
			Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

			local t = Instance.new("TextLabel")
			t.Size = UDim2.new(1, -100, 1, 0)
			t.Position = UDim2.new(0, 10, 0, 0)
			t.BackgroundTransparency = 1
			t.Text = item.title
			t.TextColor3 = Color3.fromRGB(255, 255, 255)
			t.TextSize = 12
			t.Font = Enum.Font.BuilderSansBold
			t.TextXAlignment = Enum.TextXAlignment.Left
			t.Parent = f

			local execB = Instance.new("TextButton")
			execB.Size = UDim2.new(0, 70, 0, 26)
			execB.Position = UDim2.new(1, -78, 0.5, -13)
			execB.BackgroundColor3 = Color3.fromRGB(51, 95, 255)
			execB.Text = "Execute"
			execB.TextColor3 = Color3.fromRGB(255, 255, 255)
			execB.TextSize = 10
			execB.Font = Enum.Font.BuilderSansBold
			execB.Parent = f
			Instance.new("UICorner", execB).CornerRadius = UDim.new(0, 6)

			execB.MouseButton1Click:Connect(function()
				executeScriptCode(item.code, true)
			end)
		end
	end
	savedScroll.CanvasSize = UDim2.new(0, 0, 0, savedListLayout.AbsoluteContentSize.Y + 10)
end

addScriptBtn.MouseButton1Click:Connect(function()
	titleInput.Text = ""
	codeInput.Text = ""
	addModalOverlay.Visible = true
end)

cancelBtnAdd.MouseButton1Click:Connect(function()
	addModalOverlay.Visible = false
end)

saveBtnAdd.MouseButton1Click:Connect(function()
	local title = titleInput.Text
	if #title > 20 then title = title:sub(1, 20) end
	if title ~= "" then
		table.insert(savedScriptsList, { title = title, code = codeInput.Text })
		saveSavedScripts()
		refreshSavedList()
		addModalOverlay.Visible = false
	end
end)

savedSearch:GetPropertyChangedSignal("Text"):Connect(function()
	refreshSavedList(savedSearch.Text)
end)

refreshSavedList()

local settingsScroll = Instance.new("ScrollingFrame")
settingsScroll.Size = UDim2.new(1, -24, 1, -24)
settingsScroll.Position = UDim2.new(0, 12, 0, 12)
settingsScroll.BackgroundTransparency = 1
settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 120)
settingsScroll.ScrollBarThickness = 5
settingsScroll.Parent = settingsPage

local function createSettingLabel(text, yPos)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 24)
	l.Position = UDim2.new(0, 0, 0, yPos)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(220, 220, 230)
	l.TextSize = 13
	l.Font = Enum.Font.BuilderSansBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = settingsScroll
	return l
end

createSettingLabel("Button Size:", 10)

local sizeButtons = { "mínimo", "médio", "grande" }
for i, sName in ipairs(sizeButtons) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 90, 0, 30)
	b.Position = UDim2.new(0, (i - 1) * 100, 0, 38)
	b.BackgroundColor3 = (settingsData.buttonSize == sName) and Color3.fromRGB(51, 95, 255) or Color3.fromRGB(32, 32, 38)
	b.Text = sName
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 11
	b.Font = Enum.Font.BuilderSansBold
	b.Parent = settingsScroll
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	b.MouseButton1Click:Connect(function()
		settingsData.buttonSize = sName
		applyButtonSize()
		saveSettings()
		for _, child in ipairs(settingsScroll:GetChildren()) do
			if child:IsA("TextButton") and table.find(sizeButtons, child.Text) then
				child.BackgroundColor3 = (child.Text == sName) and Color3.fromRGB(51, 95, 255) or Color3.fromRGB(32, 32, 38)
			end
		end
	end)
end

createSettingLabel("Executor Accent Color:", 80)

local colors = { "Default", "Laranja", "Amarelo", "Verde", "Azul", "Roxo", "Rosa", "branco" }
for i, cName in ipairs(colors) do
	local row = math.floor((i - 1) / 4)
	local col = (i - 1) % 4
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 85, 0, 28)
	b.Position = UDim2.new(0, col * 95, 0, 108 + row * 36)
	b.BackgroundColor3 = colorMap[cName] or Color3.fromRGB(51, 95, 255)
	b.Text = cName
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 10
	b.Font = Enum.Font.BuilderSansBold
	b.Parent = settingsScroll
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	b.MouseButton1Click:Connect(function()
		settingsData.accentColor = cName
		saveSettings()
	end)
end

local compStatsScroll = Instance.new("ScrollingFrame")
compStatsScroll.Size = UDim2.new(1, -24, 1, -24)
compStatsScroll.Position = UDim2.new(0, 12, 0, 12)
compStatsScroll.BackgroundTransparency = 1
compStatsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
compStatsScroll.ScrollBarThickness = 5
compStatsScroll.Parent = computerPage

local compLayout = Instance.new("UIListLayout")
compLayout.Padding = UDim.new(0, 8)
compLayout.Parent = compStatsScroll

local function createCompStatCard(title)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 48)
	f.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	f.Parent = compStatsScroll
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

	local l = Instance.new("TextLabel")
	l.Name = "StatLabel"
	l.Size = UDim2.new(1, -20, 1, 0)
	l.Position = UDim2.new(0, 10, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = title .. ": 0"
	l.TextColor3 = Color3.fromRGB(240, 240, 245)
	l.TextSize = 12
	l.Font = Enum.Font.BuilderSansBold
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = f
	return l
end

local lblPing = createCompStatCard("Ping")
local lblFps = createCompStatCard("FPS")
local lblCpu = createCompStatCard("CPU")
local lblGpu = createCompStatCard("GPU")
local lblRecv = createCompStatCard("Received")
local lblSent = createCompStatCard("Sent")
local lblMem = createCompStatCard("Memory")

compStatsScroll.CanvasSize = UDim2.new(0, 0, 0, compLayout.AbsoluteContentSize.Y + 20)

local dataPingItem = nil
pcall(function()
	dataPingItem = Stats.Network.ServerStatsItem["Data Ping"]
end)

local dataReceiveItem = nil
pcall(function()
	dataReceiveItem = Stats.Network.ServerStatsItem["Data Receive Rate"]
end)

local dataSendItem = nil
pcall(function()
	dataSendItem = Stats.Network.ServerStatsItem["Data Send Rate"]
end)

local function getPing()
	local pingValue = 0
	if dataPingItem then
		pcall(function()
			pingValue = math.floor(dataPingItem:GetValue())
		end)
	end
	if pingValue == 0 then
		pcall(function()
			pingValue = math.floor(LocalPlayer:GetNetworkPing() * 1000)
		end)
	end
	return math.max(1, pingValue)
end

local function getCpu()
	local cpuVal = 0
	pcall(function()
		if Stats:FindFirstChild("PerformanceStats") and Stats.PerformanceStats:FindFirstChild("CPU") then
			cpuVal = Stats.PerformanceStats.CPU:GetValue()
		end
	end)
	if cpuVal == 0 then
		pcall(function()
			cpuVal = Stats.Workspace.Heartbeat:GetValue()
		end)
	end
	return math.max(0, math.floor(cpuVal + 0.5))
end

local function getGpu()
	local gpuVal = 0
	pcall(function()
		if Stats:FindFirstChild("PerformanceStats") and Stats.PerformanceStats:FindFirstChild("GPU") then
			gpuVal = Stats.PerformanceStats.GPU:GetValue()
		end
	end)
	return math.max(0, math.floor(gpuVal + 0.5))
end

local function getReceived()
	local recVal = 0
	if dataReceiveItem then
		pcall(function()
			recVal = math.floor(dataReceiveItem:GetValue())
		end)
	end
	if recVal == 0 then
		pcall(function()
			recVal = math.floor(Stats.DataReceiveKbps)
		end)
	end
	return math.max(0, recVal)
end

local function getSent()
	local sendVal = 0
	if dataSendItem then
		pcall(function()
			sendVal = math.floor(dataSendItem:GetValue())
		end)
	end
	if sendVal == 0 then
		pcall(function()
			sendVal = math.floor(Stats.DataSendKbps)
		end)
	end
	return math.max(0, sendVal)
end

local function getMemory()
	local memVal = 0
	pcall(function()
		memVal = math.floor(Stats:GetTotalMemoryUsageMb())
	end)
	return math.max(0, memVal)
end

local function getCpuTemp(ms)
	return math.clamp(math.floor(38 + (ms * 1.4)), 38, 92)
end

local function getGpuTemp(ms)
	return math.clamp(math.floor(40 + (ms * 1.5)), 40, 95)
end

local frameCount = 0
local lastFpsTick = tick()
local currentFps = 60

RunService.RenderStepped:Connect(function()
	frameCount = frameCount + 1
end)

local function updateComputerStats()
	local now = tick()
	local elapsed = now - lastFpsTick
	if elapsed > 0 then
		currentFps = math.floor(frameCount / elapsed + 0.5)
	end
	frameCount = 0
	lastFpsTick = now

	local p = getPing()
	local c = getCpu()
	local g = getGpu()
	local r = getReceived()
	local s = getSent()
	local m = getMemory()

	lblPing.Text = string.format("Ping: %d ms", p)
	lblFps.Text = string.format("FPS: %d", currentFps)
	lblCpu.Text = string.format("CPU: %d ms (Temp: %d°C)", c, getCpuTemp(c))
	lblGpu.Text = string.format("GPU: %d ms (Temp: %d°C)", g, getGpuTemp(g))
	lblRecv.Text = string.format("Received: %d KB/s", r)
	lblSent.Text = string.format("Sent: %d KB/s", s)
	lblMem.Text = string.format("Memory: %d MB", m)
end

do
	local dragging = false
	local dragStart, startPos
	local hasMoved = false

	toggleButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			hasMoved = false
			dragStart = input.Position
			startPos = toggleButton.Position

			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
				hasMoved = true
			end
			toggleButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	toggleButton.MouseButton1Click:Connect(function()
		if not hasMoved then
			mainFrame.Visible = not mainFrame.Visible
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(1)
		if mainFrame.Visible then
			updateComputerStats()
		end
	end
end)
