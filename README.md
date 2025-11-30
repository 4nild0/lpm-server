# LPM Server

Servidor backend para o ecossistema LPM (Lua Package Manager).

## Funcionalidades

- **Armazenamento de Pacotes**: Armazena e recupera pacotes Lua
- **Gerenciamento de Versões**: Múltiplas versões por pacote
- **API RESTful**: Endpoints HTTP baseados em JSON
- **Suporte a CORS**: Requisições cross-origin habilitadas
- **Puro Lua**: Sem dependências externas (usa extensão de socket personalizada)
- **Autenticação**: Suporte a autenticação de usuários
- **Logs**: Sistema de logs para monitoramento

## Instalação

```bash
# Clone o repositório
git clone https://github.com/4nild0/lpm-server.git
cd lpm-server

# Execute os testes
lua tests.lua
```

## Iniciando o Servidor

```bash
# A partir do diretório raiz do lpm
lua start_backend.lua

# O servidor será iniciado na porta 4040
```

## Configuração

Crie um arquivo `.env` na raiz do projeto para configurar:

```
PORT=4040
STORAGE_PATH=./storage
LOG_LEVEL=info
JWT_SECRET=sua_chave_secreta_aqui
```

## Estrutura do Projeto

```
lpm-server/
├── src/
│   ├── auth.lua       # Autenticação e autorização
│   ├── http.lua       # Servidor HTTP
│   ├── logger.lua     # Sistema de logs
│   ├── router.lua     # Roteamento de requisições
│   ├── server.lua     # Configuração do servidor
│   └── storage.lua    # Armazenamento de pacotes
├── tests/             # Testes unitários
│   ├── test_http.lua
│   ├── test_server.lua
│   └── test_storage.lua
└── main.lua           # Ponto de entrada
```

## Endpoints da API

### GET /projects

Lista todos os pacotes disponíveis.

**Resposta:**
```json
["pacote-a", "pacote-b"]
```

### GET /projects/:name

Obtém detalhes e versões de um pacote.

**Resposta:**
```json
{
  "name": "package-name",
  "versions": ["1.0.0", "1.1.0"]
}
```

### POST /packages?name=:name&version=:version

Upload a new package version.

**Request Body:** Raw package archive data

**Response:**
```json
{"status": "Uploaded"}
```

### GET /stats

Get repository statistics.

**Response:**
```json
{"packages": 10}
```

### OPTIONS *

CORS preflight support.

## Project Structure

```
lpm-server/
├── src/
│   ├── http.lua       # HTTP request/response handling
│   ├── server.lua     # Main server logic and routing
│   └── storage.lua    # Package storage management
├── tests/
│   ├── test_http.lua
│   ├── test_server.lua
│   └── test_storage.lua
├── server.lua         # Entry point
└── project.toml       # Project manifest
```

## Testing

Uses the [lpm-test](https://github.com/4nild0/lpm-test) framework.

```bash
lua tests.lua
```

## Storage Format

Packages are stored in the following structure:

```
packages/
└── package-name/
    └── version/
        ├── package.toml    # Manifest
        └── archive.zip     # Package archive
```

## License

MIT
