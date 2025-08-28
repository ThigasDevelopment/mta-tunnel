-- interface's
local server = { };

function server.get (player, ...)
	iprint (player, ...);

	return false, math.random (1, 1000);
end

Tunnel.bind ('APIServer', server);