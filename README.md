# `kube-forward`

If any service is available on your k8s cluster, you can make it accessible from your local machine using `kube-forward`. 

```shell
kube-forward --forward 5432:database.example.com:5432
```

## Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vklimontovich/kube-forward/main/install.sh)"
```

Or install manually: by downloading the script from [GitHub](https://raw.githubusercontent.com/vklimontovich/kube-forward/main/kube-forward) and placing it in your PATH.

## Features

- 🚀 **Smart jumpbox management** - Automatically creates and reuses jumpbox pods
- 🔄 **Configuration detection** - Only recreates pods when forwarding rules change
- 🔗 **Multi-port support** - Forward multiple ports simultaneously
- 🎯 **Context-aware** - Works with multiple Kubernetes contexts
- 💾 **Resource efficient** - Minimal resource consumption (64Mi memory, 50m CPU)

## Installation

### Quick Install

Run this command in your terminal (requires `sudo`):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vklimontovich/kube-forward/main/install.sh)"
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

The script creates a pod in that proxies the port with `socat`
and then runs `kubectl port-forward` to forward the port from the jumpbox pod to your local machine.

The pod name is `jumpbox`, and it will be placed in namespace with the same name as your current username, unless specified otherwise by the `--namespace` option.
It will also try to reuse existing pod if port configuration is the same, or recreate it only if the forwarding rules change.
