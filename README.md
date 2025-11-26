# LPM Server

Backend server for the LPM (Lua Package Manager) ecosystem.

## Features

- **Package Storage**: Store and retrieve Lua packages
- **Version Management**: Multiple versions per package
- **RESTful API**: JSON-based HTTP endpoints
- **CORS Support**: Cross-origin requests enabled
- **Pure Lua**: No external dependencies (uses custom socket extension)

## Installation

```bash
# Clone the repository
git clone https://github.com/4nild0/lpm-server.git
cd lpm-server

# Run tests
lua tests.lua
```

## Running the Server

```bash
# From the parent lpm directory
lua start_backend.lua

# Server will start on port 4040
```

## API Endpoints

### GET /projects

List all available packages.

**Response:**
```json
["package-a", "package-b"]
```

### GET /projects/:name

Get package details and versions.

**Response:**
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
