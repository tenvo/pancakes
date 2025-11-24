SX_VM_CNONE()
local Services = {}
local vim = getvirtualinputmanager and getvirtualinputmanager()

function Services:Get(...)
	local allServices = {}

	for _, service in next, { ... } do
		table.insert(allServices, self[service])
	end

	return unpack(allServices)
end

setmetatable(Services, {
	__index = function(self, p)
		if p == "VirtualInputManager" and vim then
			return vim
		end

		local service = pcall(cloneref, game:FindService(p)) and cloneref(game:GetService(p))
			or cloneref(Instance.new(p)) --// Skidded from afy B)

		-- local service = game:GetService(p);
		-- if (p == 'VirtualInputManager') then
		--     service.Name = getServerConstant('VirtualInputManager ');
		-- end;

		rawset(self, p, service)
		return rawget(self, p)
	end,
})

return Services
