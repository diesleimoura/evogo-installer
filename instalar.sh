#!/bin/bash

# ============================================================
#   Evolution GO - Instalador Automático
#   Instala: Evolution Go API + Manager + Portainer
#   Sistema: Ubuntu 22.04 / 24.04
#   Criado por: Dieslei Moura / D2M Digital
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

# Domínios e e-mail
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
echo -e "${YELLOW}[1/6] Atualizando sistema...${NC}"
apt update -qq && apt upgrade -y -qq
apt install -y -qq curl ca-certificates gnupg nginx certbot python3-certbot-nginx git

# ── ETAPA 2: Instalar Docker ──
echo -e "${YELLOW}[2/6] Instalando Docker...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -qq
apt install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

# ── ETAPA 3: Gerar chave de API e criar arquivos ──
echo -e "${YELLOW}[3/6] Gerando chave de API e criando arquivos de configuração...${NC}"
API_KEY=$(openssl rand -hex 32)
mkdir -p /opt/evolution

cat > /opt/evolution/docker-compose.yml <<EOF
version: '3.8'

services:
  evolution-go:
    image: evoapicloud/evolution-go:latest
    container_name: evolution-go
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      SERVER_PORT: 8080
      CLIENT_NAME: "evolution"
      GLOBAL_API_KEY: "${API_KEY}"
      POSTGRES_AUTH_DB: "postgresql://postgres:postgres@postgres:5432/evogo_auth?sslmode=disable"
      POSTGRES_USERS_DB: "postgresql://postgres:postgres@postgres:5432/evogo_users?sslmode=disable"
      DATABASE_SAVE_MESSAGES: "false"
      WADEBUG: "INFO"
      LOGTYPE: "console"
      CONNECT_ON_STARTUP: "true"
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

cat > /opt/evolution/init-db.sql <<EOF
CREATE DATABASE evogo_auth;
CREATE DATABASE evogo_users;
EOF

# ── ETAPA 4: Subir containers + Portainer ──
echo -e "${YELLOW}[4/6] Subindo containers...${NC}"
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

# Configurar usuário admin do Portainer automaticamente
echo -e "${YELLOW}      Configurando Portainer...${NC}"
PORTAINER_PASSWORD=$(openssl rand -base64 12)
sleep 15
until curl -s http://localhost:9000/api/status > /dev/null 2>&1; do
  sleep 2
done
curl -s -X POST http://localhost:9000/api/users/admin/init \
  -H "Content-Type: application/json" \
  -d "{\"Username\":\"admin\",\"Password\":\"${PORTAINER_PASSWORD}\"}" > /dev/null
echo -e "${GREEN}✅ Portainer configurado automaticamente!${NC}"

# Conectar ambiente local no Portainer automaticamente
sleep 3
PORTAINER_TOKEN=$(curl -s -X POST http://localhost:9000/api/auth \
  -H "Content-Type: application/json" \
  -d "{\"Username\":\"admin\",\"Password\":\"${PORTAINER_PASSWORD}\"}" | grep -o '"jwt":"[^"]*"' | cut -d'"' -f4)
curl -s -X POST http://localhost:9000/api/endpoints \
  -H "Authorization: Bearer ${PORTAINER_TOKEN}" \
  -F "Name=local" \
  -F "EndpointCreationType=1" > /dev/null
echo -e "${GREEN}✅ Ambiente local conectado no Portainer!${NC}"

# ── ETAPA 5: Configurar Nginx ──
echo -e "${YELLOW}[5/6] Configurando Nginx...${NC}"
cat > /etc/nginx/sites-available/evolution <<EOF
server {
    listen 80;
    server_name ${DOMAIN_API};
    location / {
        proxy_pass http://localhost:8080;
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
        proxy_pass http://localhost:8080/manager/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
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

# ── ETAPA 6: Gerar certificados SSL ──
echo -e "${YELLOW}[6/6] Gerando certificados HTTPS...${NC}"
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
echo -e "  ⚠️  Portainer — Acesse com as credenciais abaixo:"
echo -e "     Usuário: ${GREEN}admin${NC}"
echo -e "     Senha:   ${GREEN}$PORTAINER_PASSWORD${NC}"
echo -e "     ⚠️  O usuário admin foi criado automaticamente. Troque a senha após o primeiro acesso."
echo -e "${YELLOW}  -----------------------------------------------------------------------${NC}"
echo ""
echo -e "  ⚠️  IMPORTANTE: A API requer ativação de licença no primeiro acesso!"
echo -e "     1. Acesse o Manager: ${CYAN}https://$DOMAIN_MANAGER${NC}"
echo -e "     2. Informe a URL da API e a API Key"
echo -e "     3. Complete o processo de ativação da licença"
echo -e "${YELLOW}  -----------------------------------------------------------------------${NC}"
echo ""

# Salvar credenciais
cat > /opt/evolution/credenciais.txt <<EOF
=== Evolution GO - Credenciais de Acesso ===

API:          https://$DOMAIN_API
Manager:      https://$DOMAIN_MANAGER
Portainer:    https://$DOMAIN_PORTAINER

API Key: $API_KEY

Para o Manager:
  URL da API: https://$DOMAIN_API
  API Key: $API_KEY

Portainer Login:
  Usuario: admin
  Senha: $PORTAINER_PASSWORD

IMPORTANTE: A API requer ativação de licença no primeiro acesso!
  1. Acesse o Manager: https://$DOMAIN_MANAGER
  2. Informe a URL da API e a API Key
  3. Complete o processo de ativação da licença

Gerado em: $(date)
EOF

echo -e "  💾 Credenciais salvas em: ${CYAN}/opt/evolution/credenciais.txt${NC}"
echo -e "  ☕ Se sentir vontade no coração, envia um cafézin no pix@d2mdigital.com.br"
echo ""
