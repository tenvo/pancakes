if not shared.aztuppy then shared.aztuppy = {} end
if shared.aztuppy["payload"] then shared.aztuppy.payload(true) end

shared.aztuppy.payload = {
    Init = false, 
    title = nil, 
    root = nil,
}

inject = function()

print("Game Started!")

end

local a=setmetatable(shared.aztuppy.payload,{__call=function(b,c)if not checkcaller()then return end;if c then setmetatable(shared.aztuppy.payload,nil)shared.aztuppy.payload=nil;inject=nil elseif not shared.aztuppy.payload.Init then shared.aztuppy.payload.Init=true;inject()end end})
loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/script-loader.lua"))()
