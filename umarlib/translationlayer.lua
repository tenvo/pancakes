local toCamelCase = sharedRequire("utils/toCamelCase.lua")
local umarlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/umarlib/library.lua"))()

local interpeter = {}

function interpeter:Init(silentLaunch)
    print('interpreter init 1.05')
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
            thisTab:Label(string.format("-- %s --",name))
            
            function Section:AddButton(payload)
                print(Section.Name,"wants to make a button")
                print("Payload:")
                for i,v in pairs(payload) do
                    print(i,v)
                end
                print(" ")
            end

            function Section:AddToggle(payload)
                print(Section.Name,"wants to make a Toggle")
                print("Payload:")
                for i,v in pairs(payload) do
                    print(i,v)
                end
                print(" ")
            end

            function Section:AddDivider(name)
                print(Section.Name,"wants to make a Divider")
                print(name)
                print(" ")
            end

            function Section:AddSlider(payload)
                print(Section.Name,"wants to make a Slider")
                print("Payload:")
                for i,v in pairs(payload) do
                    print(i,v)
                end
                print(" ")
            end

            function Section:AddList(payload)
                print(Section.Name,"wants to make a List")
                print("Payload:")
                for i,v in pairs(payload) do
                    print(i,v)
                end
                print(" ")
            end

            function Section:AddBind(payload)
                print(Section.Name,"wants to make a Bind")
                print("Payload:")
                for i,v in pairs(payload) do
                    print(i,v)
                end
                print(" ")
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