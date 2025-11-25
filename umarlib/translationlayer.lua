local toCamelCase = sharedRequire("utils/toCamelCase.lua")
local Maid = sharedRequire("utils/Maid.lua")
local Signal = sharedRequire("utils/Signal.lua")
local umarlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/umarlib/library.lua"))()

local interpeter = {}

function interpeter:Settings(win)
	self = interpeter

	local s, res = pcall(function()
		local HttpService = game:GetService("HttpService")
		local settings = win:Tab("UI Settings")
		self.settingsTab = settings

		local folderName = "Aztup Hub V3/umarlib"
		local fileName = "None"
		local dataTable = _G.UISettings

		function ReadConfig()
			local fileData = readfile("/" .. folderName .. "/" .. fileName)
			local data = HttpService:JSONDecode(fileData)

			return data
		end

		function AppendConfig()
			pcall(function()
				local data = HttpService:JSONEncode(dataTable)
				writefile("/" .. folderName .. "/" .. fileName, data)
			end)
		end

		function Save()
			for index, element in pairs(_G.UISettings.ElementCache) do
				local newtable = element

				element.Element:SaveConfig()
				task.wait()
			end

			pcall(function()
				writefile("/" .. folderName .. "/" .. fileName, HttpService:JSONEncode(_G.UISettings))
			end)
		end

		function Load()
			local fileData = ReadConfig()

			for index, element in pairs(fileData.ElementCache) do
				for index2, element2 in pairs(_G.UISettings.ElementCache) do
					if element2.Name == element.Name and element2.Type == element.Type then
						local newtable = element

						if element.Value ~= nil then
							newtable.Value = element.Value
							task.wait()
						else
							newtable.Value = element2.Value
							task.wait()
						end

						element2.Element:LoadConfig(newtable)
					end
				end
			end

			local dataTable = _G.UISettings.UIConfig

			for i, v in pairs(fileData.UIConfig) do
				if typeof(v) ~= "table" then
					dataTable[i] = v
				else
					for i2, v2 in pairs(data[i]) do
						if tonumber(i2) then
							dataTable[i] = v
						else
							dataTable[i][i2] = v2
						end
					end
				end
			end
		end

		local folder

		pcall(function()
			folder = isfolder("/" .. folderName)
		end)

		if not folder then
			pcall(function()
				makefolder("/" .. folderName)
			end)
		end

		local hideuibind
		hideuibind = settings:Bind("Hide GUI", Enum.KeyCode.RightAlt, function()
			win.ToggleVisiblity()
		end)

		local fileLabel = settings:Label("File: None")

		settings:Textbox("Config File Name", function(txt)
			fileName = txt .. "_" .. game.PlaceId .. ".json"
			fileLabel:SetText(
				"Current File Selected: "
					.. fileName:gsub("_" .. game.PlaceId, "")
					.. " | Exists?:"
					.. tostring(isfile("/" .. folderName .. "/" .. fileName))
			)
		end)

		settings:Button("Load Config", function()
			if fileName == "" then
				return
			end
			Load()
			fileLabel:SetText("File " .. fileName:gsub("_" .. game.PlaceId, "") .. " Loaded!")
			task.wait(1)
			fileLabel:SetText(
				"Current File Selected: "
					.. fileName:gsub("_" .. game.PlaceId, "")
					.. " | Exists?:"
					.. tostring(isfile("/" .. folderName .. "/" .. fileName))
			)
		end)

		settings:Button("Save Config", function()
			if fileName == "" then
				return
			end
			Save()
			fileLabel:SetText("File " .. fileName:gsub("_" .. game.PlaceId, "") .. " Saved!")
			task.wait(1)
			fileLabel:SetText(
				"Current File Selected: "
					.. fileName:gsub("_" .. game.PlaceId, "")
					.. " | Exists?:"
					.. tostring(isfile("/" .. folderName .. "/" .. fileName))
			)
		end)

		settings:Label("-- Credits: --")
		settings:Label("t3nvo - UI")
		settings:Label("Umar OGs:")
		settings:Label("sweety, L, Kiro, Dohm, Akinxs")
		return true
	end)

	return (s and res)
end

local function getReq(payload, env)
	for i, v in pairs(env) do
		if payload[v] == nil then
			return false
		end
	end

	return true
end

function interpeter:Close()
	if self.main ~= nil then
		self.main.ToggleVisiblity()
	end
end

function interpeter:AddTab(tabname)
	self = interpeter
	local Tab = {}
	local thisTab = self.main:Tab(tabname)

	--self.tabs[tabname] = thisTab

	function Tab:AddColumn()
		self = interpeter
		local Column = {}

		function Column:AddSection(sectionname)
			self = interpeter

			local Section = {}
			Section.Name = sectionname
			Section.options = {}
			Section.init = false

			setmetatable(Section, {
				__call = function(tbl, args)
					if Section.init then
						return
					end

					thisTab:Label(string.format("<<< %s >>>", Section.Name))
					Section.init = true
				end,
			})

			function Section:AddButton(payload)
				self = interpeter
				Section()

				if not getReq(payload, { "text", "callback" }) then
					return warn("Button didnt get enough args")
				end

				local flagName = toCamelCase((payload["flag"] or payload.text))

				local button = thisTab:Button(payload.text, payload.callback)

				local properties = {
					type = "button",
					flag = flagName,
					text = payload.text,
					SetText = button.SetText,
				}

				Section.options[flagName] = properties
				self.options[flagName] = properties
			end

			function Section:AddToggle(payload)
				self = interpeter
				Section()

				if not getReq(payload, { "text" }) then
					return warn("Toggle didnt get enough args")
				end

				local flagName = toCamelCase((payload["flag"] or payload.text))

				self.flags[flagName] = false

				local toggle = thisTab:Toggle(payload.text, false, function(Value)
					self.flags[flagName] = Value

					if payload["callback"] then
						xpcall(function()
							payload.callback(Value)
						end, function(err)
							warn(payload.text .. " element errored, " .. err)
						end)
					end
				end)

				local properties = {
					type = "toggle",
					flag = flagName,
					SetState = toggle.SetState,
				}

				Section.options[flagName] = properties
				self.options[flagName] = properties

				return Section
			end

			function Section:AddDivider(name)
				Section()

				thisTab:Label(string.format("-- %s --", name))
			end

			function Section:AddLabel(name)
				Section()
				local Label = {}
				Label.x = thisTab:Label(name)
				setmetatable(Label, {
					__newindex = function(tbl, key, value)
						if key == "Text" and typeof(value) == "string" then
							Label.x:SetText(value)
						end
					end,
				})

				return Label
			end

			function Section:AddSlider(payload)
				self = interpeter
				Section()

				if not getReq(payload, { "text", "min", "max" }) then
					return warn("Slider didnt get enough args")
				end

				table.insert(Section.options, toCamelCase(payload.text))
				table.insert(self.options, toCamelCase(payload.text))

				local flagName = toCamelCase((payload["flag"] or payload.text))
				payload["def"] = (payload["value"] or (payload["max"] / 2))

				if payload["suffix"] then
					payload.text = payload.text .. " " .. payload["suffix"]
				end

				local slider = thisTab:Slider(
					payload.text,
					{ def = payload["def"], max = payload["max"], min = payload["min"] },
					function(Value)
						self.flags[flagName] = Value
					end
				)

				self.flags[flagName] = payload["def"]

				return Section
			end

			function Section:AddList(payload)
				self = interpeter
				Section()
				if not getReq(payload, { "text", "values" }) then
					return warn("List didnt get enough args")
				end

				local flagName = toCamelCase((payload["flag"] or payload.text))
				local properties

				local dd = thisTab:Dropdown(payload.text, payload.values, function(Value)
					self.flags[flagName] = Value

					if payload["callback"] then
						payload.callback(Value)
					end
				end)

				dd:SetChoice(payload["values"][1])

				properties = {
					type = "list",
					values = payload.values,
					flag = flagName,
					AddValue = function(x)
						local newValues = payload.values
						local oldChoice = dd:GetChoice()
						local oldChoiceIndex = table.find(newValues, oldChoice)

						if table.find(newValues, x) then
							return
						end

						table.insert(newValues, x)

						properties.values = newValues
						Section.options[flagName] = properties
						self.options[flagName] = properties

						dd:SetOptions(newValues)
						if oldChoiceIndex ~= nil and not table.find(newValues, oldChoice) then
							if oldChoiceIndex > 1 then
								dd:SetChoice(properties.values[oldChoiceIndex - 1])
							else
								dd:SetChoice(properties.values[1])
							end
						end
					end, --// Create These
					RemoveValue = function(x)
						local newValues = payload.values
						local IndexOfRemoving = table.find(newValues, x)
						local oldChoice = dd:GetChoice()
						local oldChoiceIndex = table.find(newValues, oldChoice)

						if not IndexOfRemoving then
							return
						end

						table.remove(newValues, IndexOfRemoving)

						properties.values = newValues
						Section.options[flagName] = properties
						self.options[flagName] = properties

						dd:SetOptions(newValues)
						if oldChoiceIndex ~= nil and not table.find(newValues, oldChoice) then
							if oldChoiceIndex > 1 then
								dd:SetChoice(properties.values[oldChoiceIndex - 1])
							else
								dd:SetChoice(properties.values[1])
							end
						end
					end,
				}

				Section.options[flagName] = properties
				self.options[flagName] = properties

				return Section
			end

			function Section:AddBind(payload)
				self = interpeter
				Section()
				if not getReq(payload, { "text", "callback" }) then
					return warn("Bind didnt get enough args")
				end

				local bind = thisTab:Bind(payload.text, Enum.KeyCode.Unknown, function(Value)
					if Enum.KeyCode.Unknown == Value then
						return
					end

					xpcall(function()
						payload.callback()
					end, function(err)
						warn(payload.text .. " element errored, " .. err)
					end)
				end)

				return Section
			end

			function Section:AddBox(payload)
				self = interpeter
				Section()
				if not getReq(payload, { "text", "callback" }) then
					return warn("Textbox didnt get enough args")
				end

				local box = thisTab:Textbox(payload.text, payload.callback)
			end

			table.insert(self.sections, Section)

			return Section
		end

		table.insert(self.columns, thisTab)
		return Column
	end

	return Tab
end

function interpeter:Create(class, properties) --// Straight ripped out of UILibrary.lua
	self = interpeter
	properties = properties or {}
	if not class then
		return
	end
	local a = class == "Square"
		or class == "Line"
		or class == "Text"
		or class == "Quad"
		or class == "Circle"
		or class == "Triangle"
	local t = a and Drawing or Instance
	local inst = t.new(class)
	for property, value in next, properties do
		inst[property] = value
	end
	table.insert(self.instances, { object = inst, method = a })
	return inst
end

function interpeter:Init(silentLaunch)
	print("interpreter init 5")
	self = interpeter

	local function freshUI()
		self.columns = {}
		self.instances = {}
		self.settingsTab = nil
		self.flags = {}
		self.sections = {}
		self.umarlib = true
		self.configVars = {}
		self.init = {}
		self.options = {}
		self.unloadMaid = Maid.new()
		self.OnLoad = Signal.new()
	end

	if self.init and self.init["loaded"] then
		self.unloadMaid:Destroy()
		self.main.ToggleVisiblity(false)
		task.wait()
		self.main = umarlib:Window(
			"pancake fan club <3",
			Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		)
		freshUI()

		return
	elseif self.init then
		print("UI LOADED")
		self.init["loaded"] = true

		self.OnLoad:Fire()
		self.OnLoad:Destroy()
		self.OnLoad = nil

		if silentLaunch and self.init then
			self.main.ToggleVisiblity(true)
			self.main.Notify({
				Title = "Loaded in silentLaunch",
				Text = "Toggle key is RightAlt",
			})
		end

		print("RUNNING SETTING INIT")
		self.init()
		return
	end

	if not self.init then
		self.main = umarlib:Window(
			"pancake fan club <3",
			Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		)
		if silentLaunch then
			self.main.ToggleVisiblity(false)
		end
		freshUI()

		setmetatable(self.init, {
			__call = function()
				if self.settingsTab == nil then
					local success = self:Settings(self.main)

					if not success then
						return warn("Something went wrong while initializing settings, umarlib")
					end

					for _, v in next, self.sections do
						setmetatable(v, nil)
					end

					setmetatable(self.init, nil)
				end
			end,
		})
	end
end

interpeter:Init()
return interpeter
