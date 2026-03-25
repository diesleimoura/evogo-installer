# D2M Digital — EvoGO Installer

<div align="center">

```
  ██████╗ ██████╗ ███╗   ███╗     ██████╗ ██╗ ██████╗ ██╗████████╗ █████╗ ██╗     
  ██╔══██╗╚════██╗████╗ ████║     ██╔══██╗██║██╔════╝ ██║╚══██╔══╝██╔══██╗██║     
  ██║  ██║ █████╔╝██╔████╔██║     ██║  ██║██║██║  ███╗██║   ██║   ███████║██║     
  ██║  ██║██╔═══╝ ██║╚██╔╝██║     ██║  ██║██║██║   ██║██║   ██║   ██╔══██║██║     
  ██████╔╝███████╗██║ ╚═╝ ██║     ██████╔╝██║╚██████╔╝██║   ██║   ██║  ██║███████╗
  ╚═════╝ ╚══════╝╚═╝     ╚═╝     ╚═════╝ ╚═╝ ╚═════╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
```

**Instalador Automático do Evolution Go API + Manager + Portainer + n8n**

![Shell](https://img.shields.io/badge/Shell-100%25-brightgreen)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-orange)
![Debian](https://img.shields.io/badge/Debian-11%20%7C%2012-red)
![License](https://img.shields.io/badge/License-MIT-blue)
![Desenvolvido por](https://img.shields.io/badge/Desenvolvido%20por-D2M%20Digital-cyan)

</div>

---

## 🚀 Instalação em um comando

```bash
bash <(curl -sSL setup.aoopa.com.br)
```

> ⚠️ Execute em uma **VPS zerada** com Ubuntu 22.04/24.04 ou Debian 11/12.

---

## 📋 O que este instalador faz?

Com um único comando, ele instala e configura automaticamente:

| Serviço | Descrição | Opcional |
|---|---|---|
| **Evolution Go API** | API WhatsApp de alta performance em Go | ✅ Sempre |
| **Evolution Go Manager** | Interface web para gerenciar instâncias (embutida na API) | ✅ Sempre |
| **Portainer** | Painel visual para gerenciar containers Docker | ✅ Sempre |
| **Nginx** | Proxy reverso para todos os serviços | ✅ Sempre |
| **Certbot** | Certificados SSL/HTTPS automáticos | ✅ Sempre |
| **Docker** | Engine de containers | ✅ Sempre |
| **PostgreSQL** | Banco de dados da API | ✅ Sempre |
| **n8n** | Plataforma de automação de workflows | ⚙️ Opcional |

---

## ✅ Pré-requisitos

Antes de executar o instalador, certifique-se de ter:

- **VPS zerada** com Ubuntu 22.04/24.04 ou Debian 11/12
- **Acesso root** ao servidor
- **3 subdomínios** (ou 4 se instalar o n8n) criados e apontando para o IP da VPS:
  - `api.seudominio.com`
  - `manager.seudominio.com`
  - `portainer.seudominio.com`
  - `n8n.seudominio.com` *(opcional)*
- **E-mail** para geração dos certificados SSL

> 💡 Recomendamos usar DNS com proxy **desativado** durante a instalação. Após concluir, você pode ativar normalmente.

---

## 🔄 Passo a passo

**1.** Execute o comando de instalação:
```bash
bash <(curl -sSL setup.aoopa.com.br)
```

**2.** Informe os domínios e e-mail:
```
🌐 Domínio da API: api.seudominio.com
🖥️  Domínio do Manager: manager.seudominio.com
🐳 Domínio do Portainer: portainer.seudominio.com
📧 E-mail para SSL: seu@email.com
```

**3.** Escolha se deseja instalar o n8n:
```
🔧 Deseja instalar o n8n também? (s/n): s
🔗 Domínio do n8n: n8n.seudominio.com
```

**4.** Confirme as informações e aguarde a instalação concluir automaticamente.

**5.** Ao finalizar, todas as credenciais serão exibidas na tela e salvas em:
```
/opt/evolution/credenciais.txt
```

**6.** ⚠️ **Importante:** Acesse o Manager e complete a ativação da licença no primeiro acesso.

---

## 📦 O que é instalado automaticamente?

```
✅ Docker + Docker Compose
✅ Nginx
✅ Certbot (SSL/HTTPS)
✅ PostgreSQL
✅ Evolution Go API
✅ Evolution Go Manager (embutido na API)
✅ Portainer (com usuário admin configurado automaticamente)
⚙️ n8n (se solicitado durante a instalação)
```

---

## ⚠️ Ativação de Licença

O Evolution Go requer ativação de licença no primeiro acesso:

1. Acesse o Manager: `https://manager.seudominio.com`
2. Informe a URL da API e a API Key gerada
3. Complete o processo de ativação da licença
4. Após ativado, a API estará totalmente operacional

---

## 🔐 Segurança

- A **API Key** é gerada automaticamente com `openssl rand -hex 32`
- A **senha do Portainer** é gerada automaticamente
- Todas as credenciais são salvas localmente em `/opt/evolution/credenciais.txt`
- Nenhuma informação é enviada para servidores externos

---

## 🖥️ Requisitos mínimos de servidor

| Recurso | Mínimo | Recomendado |
|---|---|---|
| CPU | 2 vCPUs | 4 vCPUs |
| RAM | 2 GB | 4 GB |
| Disco | 20 GB | 40 GB |
| SO | Ubuntu 22.04 / Debian 11 | Ubuntu 22.04/24.04 / Debian 11/12 |

> 💡 Se for instalar o n8n também, recomendamos no mínimo **4GB de RAM**.

---

## ❓ Dúvidas e Suporte

- 🌐 Site: [d2m.digital](https://d2m.digital)
- ☕ Gostou? Manda um cafézinho: **pix@d2mdigital.com.br**

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

<div align="center">
  Desenvolvido com ❤️ por <a href="https://d2m.digital">Dieslei Moura | D2M Digital</a>
</div>
