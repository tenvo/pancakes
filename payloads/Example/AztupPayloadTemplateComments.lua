--[[
The Loadstring Example:

getgenv().silentLaunch = false
loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/payloads/Example/AztupPayloadTemplateComments.lua"))()

]]--

if not shared.aztuppy then shared.aztuppy = {} end
if shared.aztuppy["payload"] then shared.aztuppy.payload(true) end


shared.aztuppy.payload = {
    Init = false, -- <= (required) status of payload, does nothing atm. dont remove it
    title = "PoopGame", -- <= (optional) changes title of main tab, if nil it uses the game name
    root = "https://raw.githubusercontent.com/tenvo/pancakes/main/payloads/Example/", -- <= (optional) uses github url/web host to access a directory and files through sharedRequire()
}

inject = function() --// example of aztup hub UI but theres alot of stuff besides what seen

print("Game Started!")

--// Can use modules that aztup has!
local Services = sharedRequire('utils/Services.lua');
local library = sharedRequire('UILibrary.lua');
local Maid = sharedRequire('utils/Maid.lua');
local prettyPrint = sharedRequire('utils/prettyPrint.lua');
local ToastNotif = sharedRequire('classes/ToastNotif.lua')

local SunTzuQuotes = sharedRequire('data/ExampleData.lua') --// We call the directory thats in the root variable above
local theNumber = [math.random(1,#SunTzuQuotes)]
local randomQuote = SunTzuQuotes[theNumber] -- random value
print(randomQuote) -- print it

ToastNotif.new({
    text = 'the number was '..tostring(theNumber) -- send ToastNotif of the numebr
});

local column1, column2 = unpack(library.columns);

local Players, ReplicatedStorage, HttpService, PathfindingService, RunService, TweenService = Services:Get(
    'Players',
    'ReplicatedStorage',
    'HttpService',
    'PathfindingService',
    'RunService',
    'TweenService'
);

--[[ UI example of the tabs made in source.lua:

window = library:AddTab(gameName);
column1 = window:AddColumn();
column2 = window:AddColumn();

library.columns = {
    column1,
    column2
};

library.gameName = gameName;
library.window = window;

]]--


local Main = column1:AddSection('Main');
local Some = column1:AddSection('Some');
local Misc = column2:AddSection('Misc');
local Other = column2:AddSection('Other');
local Things = column2:AddSection('Things');

--// library.flags.exampleToggleCool
Main:AddToggle({
    text = 'Example Toggle Cool', 
    callback = function(toggle)
        print(toggle)
    end,
})

--// library.flags.bigBrother
local BB = Main:AddToggle({
    text = 'Big Brother',
    tip = 'dont mess with me!'
    callback = function(toggle)
        print(toggle)
    end,
})

--// library.flags.lilBroTemper (this is a sub option certain types of element support certain things)
BB:AddSlider({
    text = 'Lil Bro\'s temper',
    flag = 'Lil Bro Temper' 
    tip = 'dont mess with my big bro!',
    min = 0,
    max = 100,
    float = 0.1, -- notice how the float on the slide below is 1 but this .1 and they scale differently
    value = 100
})


--// library.flags.luckyMeter
Misc:AddSlider({
    text = 'LuckyMeter',
    tip = 'Just Pick a Range',
    suffix = '%',
    min = 0,
    max = 100,
    float = 1,
    value = 100
});

Misc:AddDivider('Check Here!');

local oldText,running = nil,false
local ShowButton = Misc:AddButton({
    text = 'Show What You Have', 
    callback = function()
        if running then return end
        running = true

        ShowButton:SetText(tostring(library.flags.luckyMeter))
        task.wait(1)
        ShowButton:SetText(oldText)
        
        running = false
    end,
});

oldText = ShowButton.text

-- library.flags.favoriteColor
Misc:AddColor({
    text = 'Favorite Color',
})

-- library.flags.exampleKeybind
Main:AddBind({
    text = 'Example Keybind'
});

ManaViewer:AddBox({
    text = 'Favorite Food', 
    callback = function(input,enter)
        print(input,enter)
    end,
});


--// library.flags.libraryFlags
Main:AddLabel("If you still confused about the flags, here:")

local readable = {}

for i,v in pairs(library.flags) do
    table.insert(readable,tostring("library.flags."i))
end

Main:AddList({
    text = 'Library Flags', 
    flag = 'Library Flags',
    values = readable,
    callback = function(flag)
        print(flag)
    end,
})

end


--// dont change below, its just a metatable that can be called with payload(), and payload(true) to remove 
local a=setmetatable(shared.aztuppy.payload,{__call=function(b,c)if not checkcaller()then return end;if c then setmetatable(shared.aztuppy.payload,nil)shared.aztuppy.payload=nil;inject=nil elseif not shared.aztuppy.payload.Init then shared.aztuppy.payload.Init=true;inject()end end})
loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/script-loader.lua"))()
