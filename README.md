# MTA Tunnel Events (HTTP)

Este recurso implementa um sistema de comunicação assíncrona entre cliente e servidor no Multi Theft Auto (MTA) usando eventos customizados, inspirado em promessas (Promises) e callbacks, facilitando integrações HTTP-like.

## 🚀 Principais Funcionalidades

- **Tunnel.get(name, target):**  
  Cria uma interface para enviar chamadas remotas, retornando uma promessa para tratar respostas de sucesso (`try`) ou erro (`catch`).

- **Tunnel.bind(name, interface):**  
  Associa funções locais a eventos remotos, permitindo que clientes ou servidores chamem métodos de forma transparente.

- **Callback Automático:**  
  O sistema gerencia IDs de requisição e callbacks, garantindo que cada resposta seja entregue ao solicitante correto.

## 🛠️ Como Usar

### 1. Enviando uma chamada remota

```lua
local api = Tunnel.get ('api');

api.someFunction (100):try (
	function (...)
		iprint ('success', ...);
	end
):catch (
	function (error)
		print ('Error: ' .. tostring (error));
	end
);
```

### 2. Bind de funções para serem chamadas remotamente

```lua
local interface = { };

function interface.someFunction (player, num)
    -- lógica aqui
    return true, 'OK';
end

Tunnel.bind ('api', interface);
```

## 🔄 Fluxo de Comunicação

1. O cliente chama uma função via `Tunnel.get`.
2. Um evento é disparado para o servidor (`triggerServerEvent`).
3. O servidor executa a função associada via `Tunnel.bind`.
4. O resultado é enviado de volta ao cliente, que resolve a promessa (`try` ou `catch`).

## 📦 Instalação

1. Coloque o recurso na pasta `resources` do seu servidor MTA.
2. Adicione ao `meta.xml`:
    ```xml
    <script src="tunnel.lua" type="shared" cache="false"/>
    ```
3. Inicie o recurso via console ou `mtaserver.conf`.

## 💡 Exemplos Interativos

- **Sucesso:**  
  O callback `try` é chamado quando a função retorna um valor válido.
- **Erro:**  
  O callback `catch` é chamado quando ocorre falha ou retorno inválido.

- **Timeout:**  
  Exemplo de uso do método `timeout` na promise:

```lua
local api = Tunnel.get ('api');

api.someFunction (100):try (
	function (...)
		iprint ('success', ...);
	end
):catch (
	function (error)
		print ('Error: ' .. tostring (error));
	end
):timeout (1000);
```
Esse exemplo utiliza o método `timeout` para tratar situações em que não há resposta dentro do tempo limite definido (em milissegundos), caso não tenha uma resposta no tempo determinado o `error` vem como `timeout`.

- **Middleware nativo:**
  Exemplo de como registrar e usar middlewares com o Tunnel:

```lua
-- Middleware de autenticação
Tunnel.middleware (
	function (func, args, player)
		if (not isPlayerAuthorized (player)) then
			return false, 'Acesso negado!';
		end

		return true;
	end
);

-- Middleware de logging
Tunnel.middleware (
	function (func, args, player)
		outputServerLog (('Tunnel: %s chamado por %s'):format (func, getPlayerName (player)));
		return true;
	end
);

-- Middleware para modificar argumentos
Tunnel.middleware (
	function (func, args, player)
		if (func == 'someFunction') then
			args[1] = 999;
		end
		
		return true, args;
	end
);

local interface = { };

function interface.someFunction (player, num)
	print ('numero: ' .. tostring (num));
    return true, 'OK';
end

Tunnel.bind ('api', interface);
```
No exemplo acima, todos os middlewares registrados em `Tunnel.middleware` serão executados em ordem antes da função principal. Se algum retornar `false`, a execução é interrompida e o erro é enviado ao cliente. Se retornar novos argumentos, eles serão usados na chamada da função.

## 📝 Observações

- O sistema não faz requisições HTTP externas, mas sim simula o padrão de requisições/respostas usando eventos do MTA.
- Ideal para integração entre diferentes recursos ou módulos.

## ❓ Dúvidas

Abra uma issue ou contribua via [GitHub](https://github.com/ThigasDevelopment/mta-tunnel).

---

## 🤝 Contribua

Pull requests, sugestões e melhorias são bem-vindas! Sinta-se livre para abrir issues ou enviar PRs.

---

## 📄 Licença

MIT. Sinta-se livre para contribuir!