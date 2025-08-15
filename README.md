# kube-forward

A smart Kubernetes port forwarding tool that creates and manages jumpbox pods to make any service accessible from within your Kubernetes cluster available on localhost.

## Features

- 🚀 **Smart jumpbox management** - Automatically creates and reuses jumpbox pods
- 🔄 **Configuration detection** - Only recreates pods when forwarding rules change
- 🔗 **Multi-port support** - Forward multiple ports simultaneously
- 🎯 **Context-aware** - Works with multiple Kubernetes contexts
- 💾 **Resource efficient** - Minimal resource consumption (64Mi memory, 50m CPU)

## Installation

### Quick Install

Run this command in your terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vklimontovich/kube-forward/main/install.sh)"
```

This will:
- Download the latest version of kube-forward
- Install it to `/usr/local/bin/kube-forward`
- Make it executable
- Verify the installation

### Manual Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/vklimontovich/kube-forward/main/kube-forward
```

2. Make it executable:
```bash
chmod +x kube-forward
```

3. Move to your PATH:
```bash
sudo mv kube-forward /usr/local/bin/
```

## Usage

### Basic Usage

Forward a single port:
```bash
kube-forward --forward 5432:database.example.com:5432
```

### Multiple Ports

Forward multiple services:
```bash
kube-forward \
  --forward 5432:database.example.com:5432 \
  --forward 6379:redis.example.com:6379 \
  --forward 9200:elasticsearch.example.com:9200
```

### Custom Namespace

Use a specific namespace:
```bash
kube-forward --namespace production --forward 5432:db.prod.svc:5432
```

### Specific Context

Work with a specific Kubernetes context:
```bash
kube-forward --context staging --forward 8080:api.staging.svc:8080
```

### Options

- `--namespace <name>` - Kubernetes namespace (default: current username)
- `--forward <spec>` - Port forward specification: `dest_port:source_host:source_port`
- `--pod-name <name>` - Name of the jumpbox pod (default: jumpbox)
- `--context <name>` - Kubernetes context to use (default: current context)
- `--help, -h` - Show help message

## How It Works

1. **Connection Check**: Verifies connectivity to your Kubernetes cluster
2. **Smart Pod Management**: 
   - Checks if a jumpbox pod exists with the required configuration
   - Reuses existing pods when possible
   - Recreates pods only when forwarding rules change
3. **Socat Setup**: Uses socat inside an Alpine container for reliable TCP forwarding
4. **Port Forwarding**: Establishes kubectl port-forward to the jumpbox pod

## Requirements

- `kubectl` configured with access to your Kubernetes cluster
- Permissions to create pods in the target namespace

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.