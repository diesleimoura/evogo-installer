#!/bin/bash

# ============================================================
#   Evolution GO - Instalador Automático
#   Instala: Evolution Go API + Manager + Portainer
#   Sistema: Ubuntu 22.04 / 24.04
#   Criado por: Dieslei / D2M Digital
# ============================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem cor

# Banner
clear
echo -e "${CYAN}"
echo "  ██████╗ ██████╗ ███╗   ███╗     ██████╗ ██╗ ██████╗ ██╗████████╗ █████╗ ██╗     "
echo "  ██╔══██╗╚════██╗████╗ ████║     ██╔══██╗██║██╔════╝ ██║╚══██╔══╝██╔══██╗██║     "
echo "  ██║  ██║ █████╔╝██╔████╔██║     ██║  ██║██║██║  ███╗██║   ██║   ███████║██║     "
echo "  ██║  ██║██╔═══╝ ██║╚██╔╝██║     ██║  ██║██║██║   ██║██║   ██║   ██╔══██║██║     "
echo "  ██████╔╝███████╗██║ ╚═╝ ██║     ██████╔╝██║╚██████╔╝██║   ██║   ██║  ██║███████╗"
echo "  ╚═════╝ ╚══════╝╚═╝     ╚═╝     ╚═════╝ ╚═╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝"
echo -e "${NC}"
echo -e "${GREEN}  Instalador Automático — Evolution Go API + Manager + Portainer${NC}"
echo -e "${CYAN}  Desenvolvido por Dieslei Moura | D2M Digital — d2m.digital${NC}"
```

echo -e "${YELLOW}  -----------------------------------------------------------------------${NC}"
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}❌ Execute este script como root: sudo bash instalar.sh${NC}"
  exit 1
fi

# Verificar Ubuntu
if ! grep -qi ubuntu /etc/os-release; then
  echo -e "${RED}❌ Este script é compatível apenas com Ubuntu.${NC}"
  exit 1
fi

echo -e "${BLUE}📋 Antes de começar, vou precisar de algumas informações:${NC}"
echo ""

# Coletar informações
read -p "   🌐 Domínio da API (ex: api.seudominio.com): " DOMAIN_API
read -p "   🖥️  Domínio do Manager (ex: manager.seudominio.com): " DOMAIN_MANAGER
read -p "   🐳 Domínio do Portainer (ex: portainer.seudominio.com): " DOMAIN_PORTAINER
read -p "   📧 Seu e-mail (para certificado SSL): " EMAIL
echo ""

# Confirmação
echo -e "${YELLOW}   -----------------------------------------------------------------------${NC}"
echo -e "   API:       ${GREEN}https://$DOMAIN_API${NC}"
echo -e "   Manager:   ${GREEN}https://$DOMAIN_MANAGER${NC}"
echo -e "   Portainer: ${GREEN}https://$DOMAIN_PORTAINER${NC}"
echo -e "   E-mail:    ${GREEN}$EMAIL${NC}"
echo -e "${YELLOW}   -----------------------------------------------------------------------${NC}"
echo ""
read -p "   ✅ As informações estão corretas? (s/n): " CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" ]]; then
  echo -e "${RED}   Instalação cancelada.${NC}"
  exit 1
fi

echo ""
echo -e "${BLUE}🚀 Iniciando instalação...${NC}"
echo ""

# ── ETAPA 1: Atualizar sistema ──
echo -e "${YELLOW}[1/7] Atualizando sistema...${NC}"
apt update -qq && apt upgrade -y -qq
apt install -y -qq curl ca-certificates gnupg nginx certbot python3-certbot-nginx

# ── ETAPA 2: Instalar Docker ──
echo -e "${YELLOW}[2/7] Instalando Docker...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -qq
apt install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

# ── ETAPA 3: Gerar chave de API ──
echo -e "${YELLOW}[3/7] Gerando chave de API segura...${NC}"
API_KEY=$(openssl rand -hex 32)

# ── ETAPA 4: Criar arquivos do projeto ──
echo -e "${YELLOW}[4/7] Criando arquivos de configuração...${NC}"
mkdir -p /opt/evolution

# docker-compose.yml
cat > /opt/evolution/docker-compose.yml <<EOF
version: '3.8'

services:
  evolution-go:
    image: evoapicloud/evolution-go:latest
    container_name: evolution-go
    restart: unless-stopped
    ports:
      - "4000:4000"
    environment:
      SERVER_PORT: 4000
      CLIENT_NAME: "evolution"
      GLOBAL_API_KEY: "${API_KEY}"
      POSTGRES_AUTH_DB: "postgresql://postgres:postgres@postgres:5432/evogo_auth?sslmode=disable"
      POSTGRES_USERS_DB: "postgresql://postgres:postgres@postgres:5432/evogo_users?sslmode=disable"
      DATABASE_SAVE_MESSAGES: "false"
      WADEBUG: "INFO"
      LOGTYPE: "console"
      LOG_DIRECTORY: "/app/logs"
      LOG_MAX_SIZE: "100"
      LOG_MAX_BACKUPS: "5"
      LOG_MAX_AGE: "30"
      LOG_COMPRESS: "true"
      CONNECT_ON_STARTUP: "false"
      WEBHOOKFILES: "true"
      OS_NAME: "Linux"
      WEBHOOK_URL: ""
      AMQP_URL: ""
      AMQP_GLOBAL_ENABLED: "false"
      NATS_URL: ""
      NATS_GLOBAL_ENABLED: "false"
      MINIO_ENABLED: "false"
      EVENT_IGNORE_GROUP: "false"
      EVENT_IGNORE_STATUS: "true"
      QRCODE_MAX_COUNT: "5"
    volumes:
      - evolution_data:/app/dbdata
      - evolution_logs:/app/logs
    networks:
      - evolution_network
    depends_on:
      - postgres

  evolution-manager:
    image: evoapicloud/evolution-go-manager:latest
    container_name: evolution-manager
    restart: unless-stopped
    ports:
      - "5174:80"
    networks:
      - evolution_network
    depends_on:
      - evolution-go

  postgres:
    image: postgres:15-alpine
    container_name: evolution-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - evolution_network

volumes:
  evolution_data:
  evolution_logs:
  postgres_data:

networks:
  evolution_network:
    driver: bridge
EOF

# init-db.sql
cat > /opt/evolution/init-db.sql <<EOF
CREATE DATABASE evogo_auth;
CREATE DATABASE evogo_users;
EOF

# ── ETAPA 5: Subir containers ──
echo -e "${YELLOW}[5/7] Subindo containers (pode demorar alguns minutos)...${NC}"
cd /opt/evolution
docker compose up -d

# Instalar Portainer
docker volume create portainer_data > /dev/null 2>&1
docker run -d \
  -p 9000:9000 \
  --name portainer \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest > /dev/null 2>&1

# ── ETAPA 6: Configurar Nginx ──
echo -e "${YELLOW}[6/7] Configurando Nginx...${NC}"
cat > /etc/nginx/sites-available/evolution <<EOF
server {
    listen 80;
    server_name ${DOMAIN_API};
    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name ${DOMAIN_MANAGER};
    location / {
        proxy_pass http://localhost:5174;
        proxy_set_header Host \$host;
    }
}

server {
    listen 80;
    server_name ${DOMAIN_PORTAINER};
    location / {
        proxy_pass http://localhost:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
    }
}
EOF

ln -sf /etc/nginx/sites-available/evolution /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# ── ETAPA 7: Gerar certificados SSL ──
echo -e "${YELLOW}[7/7] Gerando certificados HTTPS...${NC}"
certbot --nginx \
  -d "$DOMAIN_API" \
  -d "$DOMAIN_MANAGER" \
  -d "$DOMAIN_PORTAINER" \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL" \
  --redirect

# ── Concluído ──
clear
echo -e "${GREEN}"
echo "  ✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo -e "${NC}"
echo -e "${YELLOW}  -----------------------------------------------------------------------${NC}"
echo -e "  🌐 API:          ${CYAN}https://$DOMAIN_API${NC}"
echo -e "  🖥️  Manager:      ${CYAN}https://$DOMAIN_MANAGER${NC}"
echo -e "  🐳 Portainer:    ${CYAN}https://$DOMAIN_PORTAINER${NC}"
echo -e "${YELLOW}  -----------------------------------------------------------------------${NC}"
echo ""
echo -e "  🔑 Sua API Key (guarde em local seguro!):"
echo -e "  ${GREEN}$API_KEY${NC}"
echo ""
echo -e "  📋 Para acessar o Manager:"
echo -e "     URL da API: ${CYAN}https://$DOMAIN_API${NC}"
echo -e "     API Key:    ${GREEN}$API_KEY${NC}"
echo ""
echo -e "  ⚠️  No primeiro acesso ao Portainer, crie seu usuário administrador."
echo -e "${YELLOW}  -----------------------------------------------------------------------${NC}"
echo ""

# Salvar informações em arquivo
cat > /opt/evolution/credenciais.txt <<EOF
=== Evolution GO - Credenciais de Acesso ===

API:          https://$DOMAIN_API
Manager:      https://$DOMAIN_MANAGER
Portainer:    https://$DOMAIN_PORTAINER

API Key: $API_KEY

Para o Manager:
  URL da API: https://$DOMAIN_API
  API Key: $API_KEY

Gerado em: $(date)
EOF

echo -e "  💾 Credenciais salvas em: ${CYAN}/opt/evolution/credenciais.txt${NC}"
echo ""
