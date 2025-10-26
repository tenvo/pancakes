if not shared.aztuppy then shared.aztuppy = {} end
if shared.aztuppy["payload"] then shared.aztuppy.payload(true) end

shared.aztuppy.payload = {
    Init = false, -- dont touch this
    title = nil, -- (OPTIONAL) add a title for main tab (in aztup its usually game name), it will auto set as game name if not picked
    root = nil, --[[ (OPTIONAL) change this var to your github/website file hoster, you can call on files using
        local SomeData = sharedRequire("AztupHubUITemplate.lua"), 
    
        this should be done for tables of data you want to keep seperate in your scripts or OOP programming
    ]]--
}

inject = function() -- preferably dont change the function name here, if you do got to change it for the mt code below
-- you can either indent the code here or keep in as if its a empty script
--Game Start

print("Game Started!")

--Game End    
end


local mt = setmetatable(shared.aztuppy.payload,{
    __call = function(table,c)
        if not checkcaller() then return end

        if c then
            setmetatable(shared.aztuppy.payload,nil)
            shared.aztuppy.payload = nil
            inject = nil
        elseif not shared.aztuppy.payload.Init then
            shared.aztuppy.payload.Init = true
            inject()
        end
    end
}) -- the metatable responds to when we call payload(), payload(true) is to terminate and calling it empty activates it which is needed when GAMES_SETUP is called

loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/script-loader.lua"))() -- run aztup hub as normal
