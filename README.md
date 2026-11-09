# Reference n8n v3.1.0 High-Availability Cluster

Reference production deployment of **n8n (v3.1.0)** with Queue Mode, 2 Workers, and 2 Task Runner sidecars on Dokploy.

---

## 🏗 Architecture Overview

```
                      Internet (HTTPS:443)
                               │
                      Dokploy Nginx / Traefik
                  (n8n.dokploy.standartmaster.ru)
                               │
                       n8n-main (:5678)
                    (Web UI / Webhooks / API)
                               │
           ┌───────────────────┴───────────────────┐
           ▼                                       ▼
      PostgreSQL (16)                          Redis (7)
    (n8n Workflows & Meta)               (Bull Execution Queue)
           ▲                                       ▲
           │                                       │
     ┌─────┴───────────────┐                 ┌─────┴───────────────┐
     │                     │                 │                     │
n8n-worker-1          n8n-worker-2      n8n-worker-1          n8n-worker-2
(Queue Worker)        (Queue Worker)    (Queue Worker)        (Queue Worker)
     │                     │
     ▼                     ▼
n8n-runner-1          n8n-runner-2
(External Task        (External Task
 Runner Sidecar)       Runner Sidecar)
```

---

## 🚀 Key Features

1. **Queue Mode**: All heavy workflows and manual executions (`OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true`) run off Bull queue workers.
2. **External Task Runners (n8n v3.x)**: Each worker runs an isolated sidecar container (`n8nio/runners:3.1.0`) communicating via internal WebSocket RPC (`:5679`) with shared authentication token `N8N_RUNNERS_AUTH_TOKEN`.
3. **No AI Overhead**: No Ollama, no AI Chat, no memory-hungry agents running locally—keeps RAM and CPU utilization strictly bounded.
4. **Direct ClickHouse Integration**: Connected to `dokploy_net`, providing zero-latency internal network access to `dashboard-clickhouse` (`http://dashboard-clickhouse:8123`).
5. **Auto SSL / Reverse Proxy**: Dokploy automates Let's Encrypt certificates and auto-configures virtual host routing for `n8n.dokploy.standartmaster.ru`.
6. **Resource Limits & Anti-Crash Protection**: Strict memory and CPU limits on every service with health checks and `restart: unless-stopped`.

---

## 🔑 Default Credentials

- **Domain**: [https://n8n.dokploy.standartmaster.ru](https://n8n.dokploy.standartmaster.ru)
- **Direct LAN**: `http://<host-ip>:5678`
- **Admin Email**: `admin@standartmaster.ru`
- **Initial Password**: `Cnhtc101%`
- **License**: Community / Sustainable Use License (or input commercial key in Settings > Usage and plan).

---

## 📊 ClickHouse Access

In your n8n workflows (using HTTP Request node or ClickHouse community node):
- **Host**: `dashboard-clickhouse`
- **HTTP Port**: `8123`
- **Native Port**: `9000`
- **Database**: `pyrus`
- **User**: `default`
- **Password**: *(none by default in local cluster)*
