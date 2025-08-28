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

function interface.someFunction (num)
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