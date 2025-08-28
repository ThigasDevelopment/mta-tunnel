-- class's resource's
Tunnel = { };

-- callback's resource's
local callbacks, callbacksId = { }, 0;

-- method's resource's
function Tunnel.get (name, target)
	local obj = { };

	setmetatable (obj, {
		__index = function (_, func)
			return function (...)
				callbacksId = (callbacksId + 1);
				local reqId = callbacksId;

				local promise = { };
				promise.try = function (self, fn) promise._try = fn return promise end
				promise.catch = function (self, fn) promise._catch = fn return promise end

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

	return obj;
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

				local result = { interface[func] (client, unpack (args)) };
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