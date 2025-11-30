# LPM Server

Servidor HTTP para gerenciamento de pacotes do LPM (Lua Package Manager).

## Descrição

O `lpm-server` é um servidor HTTP que atua como repositório central de pacotes Lua. Ele fornece uma API RESTful para upload, download e listagem de pacotes, além de suporte para autenticação JWT e armazenamento persistente.

## Funcionalidades

- **API RESTful**: Endpoints para gerenciamento de pacotes
- **Autenticação JWT**: Suporte a autenticação e autorização via tokens
- **Armazenamento**: Armazenamento persistente de pacotes em disco
- **Logs**: Sistema de logs configurável
- **Roteamento**: Sistema de roteamento flexível
- **CORS**: Suporte a requisições cross-origin

## Instalação

```bash
# Clone o repositório
git clone https://github.com/4nild0/lpm-server.git
cd lpm-server

# Execute os testes
lua tests/test_server.lua
```

## Iniciando o Servidor

```bash
# Iniciar o servidor
lua main.lua

# O servidor estará disponível em http://localhost:8080 (porta padrão)
```

## Configuração

Crie um arquivo `.env` na raiz do projeto com as seguintes variáveis:

```env
HOST=0.0.0.0              # Endereço do servidor (padrão: 0.0.0.0)
PORT=8080                 # Porta do servidor (padrão: 8080)
STORAGE_PATH=./packages   # Diretório de armazenamento de pacotes
LOG_LEVEL=info            # Nível de log (debug, info, warn, error)
JWT_SECRET=sua_chave_secreta  # Chave secreta para JWT
DEBUG=false               # Modo debug (true/false)
```

## API Endpoints

### Listar Pacotes

```
GET /packages
```

Retorna uma lista de todos os pacotes disponíveis no formato `nome@versao`.

**Resposta:**
```
package1@1.0.0
package2@2.1.0
```

### Download de Pacote

```
GET /packages/:name/:version
```

Baixa um pacote específico.

**Parâmetros:**
- `name`: Nome do pacote
- `version`: Versão do pacote

**Resposta:** Arquivo ZIP do pacote

### Upload de Pacote

```
POST /packages/:name/:version
Authorization: Bearer <token>
Content-Type: application/zip
```

Faz upload de um novo pacote. Requer autenticação.

**Parâmetros:**
- `name`: Nome do pacote
- `version`: Versão do pacote

**Body:** Dados binários do arquivo ZIP do pacote

**Resposta:**
```json
{"status": "Package uploaded"}
```

### Arquivos Estáticos

```
GET /*
```

Serve arquivos estáticos (se configurado).

### CORS Preflight

```
OPTIONS *
```

Suporte a requisições CORS preflight.

## Estrutura do Projeto

```
lpm-server/
├── src/
│   ├── auth.lua         # Autenticação e autorização JWT
│   ├── http.lua         # Servidor HTTP básico
│   ├── logger.lua       # Sistema de logs
│   ├── router.lua       # Roteamento de requisições
│   ├── routes/          # Definição das rotas
│   │   ├── packages.lua # Rotas de gerenciamento de pacotes
│   │   └── static.lua   # Rotas para arquivos estáticos
│   ├── server.lua       # Configuração do servidor HTTP
│   ├── server_init.lua  # Inicialização do servidor
│   └── storage.lua      # Armazenamento de pacotes
├── packages/            # Diretório de armazenamento (criado automaticamente)
│   └── nome-pacote/
│       └── versao/
│           ├── package.toml    # Manifesto
│           └── archive.zip     # Arquivo do pacote
├── tests/               # Testes unitários
│   ├── test_http.lua
│   ├── test_server.lua
│   └── test_storage.lua
├── main.lua             # Ponto de entrada
└── project.toml         # Manifesto do projeto
```

## Formato de Armazenamento

Os pacotes são armazenados na seguinte estrutura:

```
packages/
└── nome-pacote/
    └── versao/
        ├── package.toml    # Manifesto do pacote
        └── archive.zip     # Arquivo compactado do pacote
```

## Dependências

- **lpm-core**: Biblioteca central do LPM (instalada automaticamente)

## Testes

Os testes utilizam o framework de testes do LPM:

```bash
lua tests/test_server.lua
```

## Desenvolvimento

Para contribuir com o desenvolvimento:

1. Faça um fork do repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Faça commit das suas alterações (`git commit -am 'Adiciona nova funcionalidade'`)
4. Faça push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

MIT License
