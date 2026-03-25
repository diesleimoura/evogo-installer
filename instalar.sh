#!/bin/bash

# ============================================================
#   Evolution GO - Instalador Automático
#   Instala: Evolution Go API + Manager + Portainer + n8n (opcional)
#   Sistema: Ubuntu 22.04 / 24.04 | Debian 11 / 12
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

# Verificar Ubuntu ou Debian
if ! grep -qiE "ubuntu|debian" /etc/os-release; then
  echo -e "${RED}❌ Este script é compatível apenas com Ubuntu 22.04/24.04 ou Debian 11/12.${NC}"
  exit 1
fi

# Detectar distribuição
DISTRO=$(grep -i "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
echo -e "${GREEN}✅ Sistema detectado: ${DISTRO}${NC}"
echo 

echo -e "${BLUE}📋 Antes de começar, vou precisar de algumas informações:${NC}"
echo ""

# Domínios e e-mail
read -p "   🌐 Domínio da API (ex: api.seudominio.com): " DOMAIN_API
read -p "   🖥️  Domínio do Manager (ex: manager.seudominio.com): " DOMAIN_MANAGER
read -p "   🐳 Domínio do Portainer (ex: portainer.seudominio.com): " DOMAIN_PORTAINER
read -p "   📧 Seu e-mail (para certificado SSL): " EMAIL
echo ""

# Pergunta sobre n8n
read -p "   🔧 Deseja instalar o n8n também? (s/n): " INSTALL_N8N
if [[ "$INSTALL_N8N" == "s" || "$INSTALL_N8N" == "S" ]]; then
  read -p "   🔗 Domínio do n8n (ex: n8n.seudominio.com): " DOMAIN_N8N
  INSTALL_N8N=true
else
  INSTALL_N8N=false
fi
echo ""

# Confirmação
echo -e "${YELLOW}   -----------------------------------------------------------------------${NC}"
echo -e "   API:       ${GREEN}https://$DOMAIN_API${NC}"
echo -e "   Manager:   ${GREEN}https://$DOMAIN_MANAGER${NC}"
echo -e "   Portainer: ${GREEN}https://$DOMAIN_PORTAINER${NC}"
if [ "$INSTALL_N8N" = true ]; then
  echo -e "   n8n:       ${GREEN}https://$DOMAIN_N8N${NC}"
fi
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

# ── Verificar instalação anterior ──
INSTALACAO_ANTERIOR=false
if docker ps -a 2>/dev/null | grep -qE "evolution-go|evolution-postgres|portainer|n8n"; then
  INSTALACAO_ANTERIOR=true
fi
if [ -d "/opt/evolution" ] || [ -f "/etc/nginx/sites-available/evolution" ]; then
  INSTALACAO_ANTERIOR=true
fi

if [ "$INSTALACAO_ANTERIOR" = true ]; then
  echo -e "${RED}  ⚠️  Detectamos uma instalação anterior nesta VPS!${NC}"
  echo -e "${YELLOW}  Para continuar, os seguintes dados serão apagados:${NC}"
  echo -e "${YELLOW}     - Containers Docker (Evolution Go, Postgres, Portainer, n8n)${NC}"
  echo -e "${YELLOW}     - Volumes e dados armazenados${NC}"
  echo -e "${YELLOW}     - Configurações do Nginx${NC}"
  echo -e "${YELLOW}     - Certificados SSL${NC}"
  echo ""
  echo -e "${RED}  ⚠️  ATENÇÃO: Esta ação é IRREVERSÍVEL!${NC}"
  echo ""
  read -p "   Deseja apagar tudo e continuar com a instalação? (s/n): " LIMPAR
  if [[ "$LIMPAR" != "s" && "$LIMPAR" != "S" ]]; then
    echo -e "${RED}   Instalação cancelada.${NC}"
    exit 1
  fi
  echo ""
  echo -e "${YELLOW}  🧹 Limpando instalação anterior...${NC}"

  # Parar e remover todos os containers e volumes Docker
  docker stop $(docker ps -aq) 2>/dev/null || true
  docker rm $(docker ps -aq) 2>/dev/null || true
  docker volume rm $(docker volume ls -q) 2>/dev/null || true
  docker network prune -f 2>/dev/null || true

  # Remover arquivos de instalação
  rm -rf /opt/evolution /opt/n8n /var/www/evolution-manager

  # Remover TODAS as configurações do Nginx
  rm -f /etc/nginx/sites-enabled/*
  rm -f /etc/nginx/sites-available/*

  # Garantir que sites-enabled está completamente vazio
  rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true

  # Remover TODOS os certificados SSL
  for cert in $(certbot certificates 2>/dev/null | grep "Certificate Name" | awk '{print $3}'); do
    certbot delete --cert-name "$cert" --non-interactive 2>/dev/null || true
  done

  systemctl reload nginx 2>/dev/null || true
  echo -e "${GREEN}  ✅ Limpeza concluída! Iniciando instalação...${NC}"
  echo ""
fi

# ── ETAPA 1: Atualizar sistema ──
echo -e "${YELLOW}[1/6] Atualizando sistema...${NC}"
apt update -qq && apt upgrade -y -qq
apt install -y -qq curl ca-certificates gnupg nginx certbot python3-certbot-nginx git

# ── ETAPA 2: Instalar Docker ──
echo -e "${YELLOW}[2/6] Instalando Docker...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/${DISTRO}/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${DISTRO} $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -qq
apt install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin

# ── ETAPA 3: Gerar chave de API e criar arquivos ──
echo -e "${YELLOW}[3/6] Gerando chave de API e criando arquivos de configuração...${NC}"
API_KEY=$(openssl rand -hex 32)
mkdir -p /opt/evolution

cat > /opt/evolution/docker-compose.yml <<EOF
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

# Instalar n8n (opcional)
if [ "$INSTALL_N8N" = true ]; then
  echo -e "${YELLOW}      Instalando n8n...${NC}"
  mkdir -p /opt/n8n
  N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

  cat > /opt/n8n/docker-compose.yml <<EOF
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      GENERIC_TIMEZONE: "America/Sao_Paulo"
      TZ: "America/Sao_Paulo"
      N8N_ENCRYPTION_KEY: "${N8N_ENCRYPTION_KEY}"
      WEBHOOK_URL: "https://${DOMAIN_N8N}"
      N8N_HOST: "${DOMAIN_N8N}"
      N8N_PROTOCOL: "https"
      N8N_SECURE_COOKIE: "false"
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
EOF

  cd /opt/n8n
  docker compose up -d
  echo -e "${GREEN}✅ n8n instalado com sucesso!${NC}"
fi

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

# Adicionar bloco do n8n no Nginx se solicitado
if [ "$INSTALL_N8N" = true ]; then
  cat >> /etc/nginx/sites-available/evolution <<EOF

server {
    listen 80;
    server_name ${DOMAIN_N8N};
    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
fi

ln -sf /etc/nginx/sites-available/evolution /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# ── ETAPA 6: Gerar certificados SSL ──
echo -e "${YELLOW}[6/6] Gerando certificados HTTPS...${NC}"

CERTBOT_DOMAINS="-d $DOMAIN_API -d $DOMAIN_MANAGER -d $DOMAIN_PORTAINER"
if [ "$INSTALL_N8N" = true ]; then
  CERTBOT_DOMAINS="$CERTBOT_DOMAINS -d $DOMAIN_N8N"
fi

certbot --nginx \
  $CERTBOT_DOMAINS \
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
if [ "$INSTALL_N8N" = true ]; then
  echo -e "  🔧 n8n:          ${CYAN}https://$DOMAIN_N8N${NC}"
fi
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
EOF

if [ "$INSTALL_N8N" = true ]; then
  cat >> /opt/evolution/credenciais.txt <<EOF
n8n:          https://$DOMAIN_N8N
EOF
fi

cat >> /opt/evolution/credenciais.txt <<EOF

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
