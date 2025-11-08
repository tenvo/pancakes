if not shared.aztuppy then shared.aztuppy = {} end
if shared.aztuppy["payload"] then shared.aztuppy.payload(true) end

shared.aztuppy.payload = {
    _init = false,
    _maid = nil,
    _title = nil, 
    _root = nil,
}
inject = function()

print("Game Started!")

end

local a=setmetatable(shared.aztuppy.payload,{__call=function(b,c)if not checkcaller()then return end;if c then if shared.aztuppy.payload._maid then shared.aztuppy.payload._maid:Destroy()end;setmetatable(shared.aztuppy.payload,nil)shared.aztuppy.payload=nil;inject=nil elseif not shared.aztuppy.payload._init then shared.aztuppy.payload._init=true;xpcall(inject,warn)end end})
loadstring(game:HttpGet("https://raw.githubusercontent.com/tenvo/pancakes/main/aztup/script-loader.lua"))()
