local toCamelCase = sharedRequire("utils/toCamelCase.lua")
local ToastNotif = sharedRequire('classes/ToastNotif.lua');
local umarlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/umarlib/library.lua"))()

local interpeter = {}

function interpeter:Settings(win)
    self = interpeter

    local s,res = pcall(function()
        local HttpService = game:GetService("HttpService")
        local settings = win:Tab("UI Settings")
        self.settingsTab = settings

        local folderName = "Aztup Hub V3/umarlib"
        local fileName = "None"
        local dataTable = _G.UISettings

        local function ReadConfig()
            local fileData = readfile("/"..folderName.."/"..fileName)
            local data = HttpService:JSONDecode(fileData)
            
            return data
        end

        local function AppendConfig()
            pcall(function()
                local data = HttpService:JSONEncode(dataTable)
                writefile("/"..folderName.."/"..fileName,data)
            end)
        end

        local function Save()
            for index,element in pairs(_G.UISettings.ElementCache) do
            local newtable = element
            
            element.Element:SaveConfig()
            task.wait()
            end    
                    
            pcall(function()
                writefile("/"..folderName.."/"..fileName,HttpService:JSONEncode(_G.UISettings))
            end)
        end

        local function Load()
            local fileData = ReadConfig()
                    
            for index,element in pairs(fileData.ElementCache) do
                for index2,element2 in pairs(_G.UISettings.ElementCache) do
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
            
            for i,v in pairs(fileData.UIConfig) do
                if typeof(v) ~= "table" then
                    dataTable[i] = v
                else
                    for i2,v2 in pairs(data[i]) do
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
            folder = isfolder("/"..folderName)
        end)

        if not folder then
            pcall(function()
                makefolder("/"..folderName) 
            end)
        end

        settings:Bind("Hide GUI",Enum.KeyCode.RightAlt,function()
            win.ToggleVisiblity()
        end)

        local fileLabel = settings:Label("File: None")

        settings:Textbox("Config File Name",function(txt)
            fileName = txt.."_"..game.PlaceId..".json"
            fileLabel:SetText("Current File Selected: "..fileName:gsub("_"..game.PlaceId,"").." | Exists?:"..tostring(isfile("/"..folderName.."/"..fileName)))
        end)

        settings:Button("Load Config",function()
            if fileName == "" then return end
            Load()
            fileLabel:SetText("File "..fileName:gsub("_"..game.PlaceId,"").." Loaded!")
            task.wait(1)
            fileLabel:SetText("Current File Selected: "..fileName:gsub("_"..game.PlaceId,"").." | Exists?:"..tostring(isfile("/"..folderName.."/"..fileName)))
        end)

        settings:Button("Save Config",function()
            if fileName == "" then return end
            Save()
            fileLabel:SetText("File "..fileName:gsub("_"..game.PlaceId,"").." Saved!")
            task.wait(1)
            fileLabel:SetText("Current File Selected: "..fileName:gsub("_"..game.PlaceId,"").." | Exists?:"..tostring(isfile("/"..folderName.."/"..fileName)))
        end)

        return true
    end)

    return (s and res)
end

local function getReq(payload,env)
    for i,v in pairs(env) do
        if payload[v] == nil then
            return false
        end
    end

    return true
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
            Section.init = false

            setmetatable(Section,{
                __call = function(tbl,args)
                    if Section.init then return end

                    thisTab:Label(string.format("<<< %s >>>",Section.Name))
                    Section.init = true
                end
            })
            
            function Section:AddButton(payload)
                self = interpeter Section()


                if not getReq(payload,{"text","callback"}) then return warn("Button didnt get enough args") end
                local flagName = toCamelCase((payload["flag"] or payload.text))

                thisTab:Button(payload.text,payload.callback)
            end

            function Section:AddToggle(payload)
                self = interpeter Section()

                if not getReq(payload,{"text","callback"}) then return warn("Toggle didnt get enough args") end
                local flagName = toCamelCase((payload["flag"] or payload.text))

                self.flags[flagName] = false

                thisTab:Toggle(payload.text,false,function(Value)
                    self.flags[flagName] = Value

                    xpcall(function()
                        payload.callback(Value)
                    end,function(err)
                        warn(payload.text .. " element errored, "..err)
                    end)
                end)
                
                return Section
            end

            function Section:AddDivider(name)
                Section()
            
                thisTab:Label(string.format("<- %s ->",name))
            end

            function Section:AddSlider(payload)
                self = interpeter Section()

                if not getReq(payload,{"text","min","max"}) then return warn("Slider didnt get enough args") end
                local flagName = toCamelCase((payload["flag"] or payload.text))
                payload["def"] = (payload["value"] or (payload["max"]/2))

                if payload["suffix"] then
                    payload.text = payload.text .." ".. payload["suffix"]
                end

                thisTab:Slider(payload.text,{def = payload["def"],max = payload["max"],min = payload["min"]},function(Value)
                    self.flags[flagName] = Value
                end)

                self.flags[flagName] = payload["def"]
                
                return Section
            end

            function Section:AddList(payload)
                self = interpeter Section()
                if not getReq(payload,{"text","values"}) then return warn("List didnt get enough args") end
                local flagName = toCamelCase((payload["flag"] or payload.text))

                local dd = thisTab:Dropdown(payload.text,false,function(Value)
                    self.flags[flagName] = Value

                    if payload["callback"] then
                        payload.callback(Value)
                    end
                end)


                dd:SetChoice(payload["values"][1])

                return Section
            end

            function Section:AddBind(payload)
                self = interpeter Section()
                if not getReq(payload,{"text","callback"}) then return warn("Toggle didnt get enough args") end

                thisTab:Bind(payload.text,Enum.KeyCode.Unknown,function(Value)
                    if Enum.KeyCode.Unknown == Value then return end

                    xpcall(function()
                        payload.callback()
                    end,function(err)
                        warn(payload.text .. " element errored, "..err)
                    end)
                end)
                
                return Section
            end

            function Section:AddBox(payload)
                self = interpeter Section()
                if not getReq(payload,{"text","callback"}) then return warn("Toggle didnt get enough args") end

                thisTab:Textbox(payload.text,payload.callback)
            end
            
            table.insert(self.sections,Section)

            return Section
        end

        table.insert(self.columns,thisTab)
        return Column
    end

    return Tab
end

function interpeter:Init(silentLaunch)
    print('interpreter init 2')
    self = interpeter

    if self.init and (self.init["loaded"]) then
        self.main = umarlib:Window("pancake fan club <3",Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
        self.columns = {}
        self.settingsTab = nil
        self.flags = {}
        self.sections = {}
    elseif self.init then
        self.init["loaded"] = true
    end

    if not self.init then
        self.columns = {}
        self.settingsTab = nil
        self.sections = {}
        self.flags = {}
        self.main = umarlib:Window("pancake fan club <3",Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
        self.umarlib = true
        self.init = {}

        setmetatable(self.init,{
            __call = function()
                if self.settingsTab == nil then
                    local success = self:Settings(self.main)

                    if not success then
                        return warn("Something went wrong while initializing settings, umarlib")
                    end

                    for _,v in next, self.sections do
                        setmetatable(v,nil)
                    end

                    setmetatable(self.init,nil)
                end
            end
        })
    end

    if silentLaunch and self.init then
        self.main.ToggleVisiblity()
        self.main.Notify({
            Title = "Loaded in silentLaunch",
            Text = "Toggle key is RightAlt"
        })
    end

    --// add metatable to init settings/config
end

interpeter:Init()
return interpeter