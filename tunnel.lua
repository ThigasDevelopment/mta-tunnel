-- class's resource's
Tunnel = { };
Tunnel.middleware = { };

-- callback's resource's
local callbacks, callbacksId = { }, 0;

-- middleware's resource's
setmetatable (Tunnel.middleware, {
	__call = function (self, func)
		local funcType = type (func);
		if (funcType ~= 'function') then
			return false;
		end

		self[#self + 1] = func;
		return true;
	end
});

local function runMiddlewares (func, args, player)
	local items = Tunnel.middleware;
	if (#items < 1) then
		return true, args;
	end

	for _, middleware in pairs (items) do
		local status, message, new = middleware (func, args, player);
		if (not status) then
			return false, message;
		end

		if (new) then
			args = new;
		end
	end
	return true, args;
end

-- method's resource's
function Tunnel.get (name, target)
	return setmetatable ({ }, {
		__index = function (_, func)
			return function (...)
				callbacksId = (callbacksId + 1);
				local reqId = callbacksId;

				local promise = { };
				promise.try = function (self, fn) promise._try = fn return promise end
				promise.catch = function (self, fn) promise._catch = fn return promise end
				promise.timeout = function (self, ms) setTimer (function () if (isTimer (sourceTimer)) then killTimer (sourceTimer) end if (not callbacks[reqId]) then return false end if (type (promise._catch) == 'function') then promise._catch ('timeout') end callbacks[reqId] = nil return true end, ms, 1) return promise end

				callbacks[reqId] = function (status, ...)
					local args = { ... };
					
					local argType = type (args[1]);
					if (argType == 'nil') or (argType == 'boolean') then
						table.remove (args, 1);
					end

					if (status) and (type (promise._try) == 'function') then
						return promise._try (unpack (args));
					end

					if (not status) and (type (promise._catch) == 'function') then
						return promise._catch (unpack (args));
					end
					return false;
				end

				if (isElement (localPlayer)) then
					triggerServerEvent ('__tunnel:' .. name, resourceRoot, func, { ... }, reqId);
				else
					triggerClientEvent ((target or root), '__tunnel:' .. name, resourceRoot, func, { ... }, reqId);
				end

				return promise;
			end
		end,
	});
end

function Tunnel.bind (name, interface)
	local eventName = '__tunnel:' .. name;

	addEvent (eventName, true);
	addEventHandler (eventName, resourceRoot,
		function (func, args, reqId)
			if (not interface[func]) then
				return false;
			end

			if (reqId) then
				local isClient = isElement (localPlayer);
				if (isClient) then
					local result = { interface[func] (unpack (args)) };
					return triggerServerEvent ('__tunnel:callback', resourceRoot, reqId, result);
				end

				if (not isElement (client)) then
					return false;
				end

				local status, message = runMiddlewares (func, args, client);
				if (not status) then
					return triggerClientEvent (client, '__tunnel:callback', resourceRoot, reqId, { false, message });
				end

				local result = { interface[func] (client, unpack (message)) };
				return triggerClientEvent (client, '__tunnel:callback', resourceRoot, reqId, result);
			end
			return false;
		end
	);

	return true;
end

-- custom's event's resource's
addEvent ('__tunnel:callback', true);
addEventHandler ('__tunnel:callback', resourceRoot,
	function (reqId, result)
		local resultType = type (result[1]);
		if (not callbacks[reqId]) then
			return false;
		end

		local status = (result[1] ~= false) and (resultType ~= 'nil');
		callbacks[reqId] (status, unpack (result));
		callbacks[reqId] = nil;

		collectgarbage ();
		return true;
	end
);