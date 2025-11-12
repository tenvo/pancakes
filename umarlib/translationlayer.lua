local toCamelCase = sharedRequire("utils/toCamelCase.lua")
local umarlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/umarlib/library.lua"))()

local interpeter = {}

function interpeter:Init(silentLaunch)
    print('interpreter init 1.1')
    self = interpeter

    if self.init and (self.init["loaded"]) then
        self.main = umarlib:Window("pancake fan club <3",Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
        self.columns = {}
        self.tabs = {}
        self.flags = {}
    elseif self.init then
        self.init["loaded"] = true
    end

    if not self.init then
        self.columns = {}
        self.tabs = {}
        self.flags = {}
        self.main = umarlib:Window("pancake fan club <3",Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
        self.umarlib = true
        self.init = {}
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

local function getReq(payload,env)
    for i,v in pairs(env) do
        if payload[v] == nil then
            return false
        end
    end

    return true
end



function interpeter:AddTab(name)
    print("made tab")
    self = interpeter
    local Tab = {}
    local thisTab = self.main:Tab(name)

    self.tabs[name] = thisTab

    function Tab:AddColumn()
        self = interpeter
        print('made column',self)
        local Column = {}

        function Column:AddSection(name)
            self = interpeter
            print('made section',name)
            local Section = {}
            Section.Name = name
            thisTab:Label(string.format("<<< %s >>>",name))
            
            function Section:AddButton(payload)
                self = interpeter
                print(Section.Name,"wants to make a Button")
                if not getReq(payload,{"text","callback"}) then return warn("Button didnt get enough args") end
                local flagName = toCamelCase(payload.text)

                thisTab:Button(payload.text,payload.callback)
                
                return Section
            end

            function Section:AddToggle(payload)
                self = interpeter
                print(Section.Name,"wants to make a Toggle")
                if not getReq(payload,{"text","callback"}) then return warn("Toggle didnt get enough args") end
                local flagName = toCamelCase(payload.text)

                self.flags[flagName] = false

                thisTab:Toggle(payload.text,false,function(Value)
                    self.flags[flagName] = Value

                    xpcall(function()
                        payload.callback()
                    end,function(err)
                        print(payload.text .. " element errored, "..err)
                    end)
                end)
                
                return Section
            end

            function Section:AddDivider(name)
                print(Section.Name,"wants to make a Divider")
                thisTab:Label(string.format("-- %s --",name))
            end

            function Section:AddSlider(payload)
                self = interpeter
                print(Section.Name,"wants to make a Slider")
                if not getReq(payload,{"text","min","max"}) then return warn("Slider didnt get enough args") end
                local flagName = toCamelCase(payload.text)
                payload["def"] = (payload["max"]/2)

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
                self = interpeter
                if not getReq(payload,{"text","values"}) then return warn("List didnt get enough args") end
                local flagName = toCamelCase(payload.text)

                local dd = thisTab:Dropdown(payload.text,false,function(Value)
                    self.flags[flagName] = Value
                end)


                dd:SetChoice(payload["values"][1])

                return Section
            end

            function Section:AddBind(payload)
                self = interpeter
                print(Section.Name,"wants to make a Bind")
                if not getReq(payload,{"text","callback"}) then return warn("Toggle didnt get enough args") end

                thisTab:Bind(payload.text,Enum.KeyCode.Unknown,function(Value)
                    if Enum.KeyCode.Unknown == Value then return end

                    xpcall(function()
                        payload.callback()
                    end,function(err)
                        print(payload.text .. " element errored, "..err)
                    end)
                end)
                
                return Section
            end


            return Section
        end

        table.insert(self.columns,thisTab)
        return Column
    end

    return Tab
end


interpeter:Init()
return interpeter