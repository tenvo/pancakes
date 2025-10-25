shared.aztuppy = {
  payload = {
    Init = false, 
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
}

setmetatable(shared.aztuppy.payload,mt)
