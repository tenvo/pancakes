if not shared.aztuppy then shared.aztuppy = {} end
if shared.aztuppy["payload"] then shared.aztuppy.payload(true) end


shared.aztuppy.payload = {
    Init = false, 
    title = "PoopGame", 
    root = "https://raw.githubusercontent.com/tenvo/pancakes/main/payloads/Example/",
}

inject = function()

print("Game Started!")


local Services = sharedRequire('utils/Services.lua');
local library = sharedRequire('UILibrary.lua');
local Maid = sharedRequire('utils/Maid.lua');
local prettyPrint = sharedRequire('utils/prettyPrint.lua');
local ToastNotif = sharedRequire('classes/ToastNotif.lua')

local SunTzuQuotes = sharedRequire('data/ExampleData.lua')
local theNumber = [math.random(1,#SunTzuQuotes)]
local randomQuote = SunTzuQuotes[theNumber]
print(randomQuote) -- print it

ToastNotif.new({
    text = 'the number was '..tostring(theNumber)
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

local Main = column1:AddSection('Main');
local Some = column1:AddSection('Some');
local Misc = column2:AddSection('Misc');
local Other = column2:AddSection('Other');
local Things = column2:AddSection('Things');


Main:AddToggle({
    text = 'Example Toggle Cool', 
    callback = function(toggle)
        print(toggle)
    end,
})

local BB = Main:AddToggle({
    text = 'Big Brother',
    tip = 'dont mess with me!'
    callback = function(toggle)
        print(toggle)
    end,
})

BB:AddSlider({
    text = 'Lil Bro\'s temper',
    flag = 'Lil Bro Temper' 
    tip = 'dont mess with my big bro!',
    min = 0,
    max = 100,
    float = 0.1,
    value = 100
})


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


Misc:AddColor({
    text = 'Favorite Color',
})


Main:AddBind({
    text = 'Example Keybind'
});

ManaViewer:AddBox({
    text = 'Favorite Food', 
    callback = function(input,enter)
        print(input,enter)
    end,
});



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



local a=setmetatable(shared.aztuppy.payload,{__call=function(b,c)if not checkcaller()then return end;if c then setmetatable(shared.aztuppy.payload,nil)shared.aztuppy.payload=nil;inject=nil elseif not shared.aztuppy.payload.Init then shared.aztuppy.payload.Init=true;inject()end end})
loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/script-loader.lua"))()
