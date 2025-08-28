-- interface's
local server = Tunnel.get ('APIServer');

server.get (1, 2, 3):try (
	function (...)
		iprint ('try response: ', ...);
	end
):catch (
	function (error)
		iprint ('catch error: ', error);
	end
);