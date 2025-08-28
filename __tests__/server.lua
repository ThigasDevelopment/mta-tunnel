-- interface's
local client = Tunnel.get ('APIClient');

setTimer (
	function ()
		client.get (1, 2, 3):try (
			function (...)
				iprint ('on client try response: ', ...);
			end
		):catch (
			function (error)
				iprint ('on client catch error: ', error);
			end
		);
	end, 1000, 1
);

local server = { };

function server.get (player, ...)
	iprint ('server', player, ...);

	return (math.random (1, 2) == 1), math.random (1, 1000);
end

Tunnel.bind ('APIServer', server);

