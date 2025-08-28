-- interface's
local server = Tunnel.get ('APIServer');

setTimer (
	function ()
		server.get (1, 2, 3):try (
			function (...)
				iprint ('on server try response: ', ...);
			end
		):catch (
			function (error)
				iprint ('on server catch error: ', error);
			end
		);
	end, 1000, 1
);

local client = { };

function client.get (...)
	iprint ('client', ...);

	return (math.random (1, 2) == 2), math.random (1, 1000);
end

Tunnel.bind ('APIClient', client);