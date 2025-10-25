shared.aztuppy = { -- this my config table pls dont use it
  payload = {
    Init = false, -- dont touch this
    root = nil, --[[ (OPTIONAL) change this var to your github/website file hoster, you can call on files using
        local SomeData = sharedRequire("AztupHubUITemplate.lua"), 
    
        this should be done for tables of data you want to keep seperate in your scripts or OOP programming
    ]]--
  }
}

inject = function() -- preferably dont change the function name here, if you do got to change it for the mt code below
-- you can either indent the code here or keep in as if its a empty script
--Game Start

print("Game Started!")

--Game End    
end


local mt = {
    __call = function(table,c)
        if c then
            setmetatable(shared.aztuppy.payload,nil)
            shared.aztuppy.payload = nil
        elseif not shared.aztuppy.payload.Init then
            shared.aztuppy.payload.Init = true
            inject()
        end
    end
} -- the metatable responds to when we call payload(), payload(true) is to terminate and calling it empty activates it which is needed when GAMES_SETUP is called

setmetatable(shared.aztuppy.payload,mt) -- apply what we did above
loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/script-loader.lua"))() -- run aztup hub as normal
