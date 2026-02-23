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

**Instalador Automático do Evolution Go API + Manager + Portainer**

![Shell](https://img.shields.io/badge/Shell-100%25-brightgreen)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-orange)
![License](https://img.shields.io/badge/License-MIT-blue)
![Desenvolvido por](https://img.shields.io/badge/Desenvolvido%20por-D2M%20Digital-cyan)

</div>

---

## 🚀 Instalação em um comando

```bash
bash <(curl -sSL setup.aoopa.com.br)
```

> ⚠️ Execute em uma **VPS zerada** com Ubuntu 22.04 ou 24.04.

---

## 📋 O que este instalador faz?

Com um único comando, ele instala e configura automaticamente:

| Serviço | Descrição |
|---|---|
| **Evolution Go API** | API WhatsApp de alta performance em Go |
| **Evolution Go Manager** | Interface web para gerenciar instâncias |
| **Portainer** | Painel visual para gerenciar containers Docker |
| **Nginx** | Proxy reverso para todos os serviços |
| **Certbot** | Certificados SSL/HTTPS automáticos |
| **Docker** | Engine de containers |
| **PostgreSQL** | Banco de dados da API |

---

## ✅ Pré-requisitos

Antes de executar o instalador, certifique-se de ter:

- **VPS zerada** com Ubuntu 22.04 ou 24.04
- **Acesso root** ao servidor
- **3 subdomínios** criados e apontando para o IP da VPS:
  - `api.seudominio.com`
  - `manager.seudominio.com`
  - `portainer.seudominio.com`
- **Conta ativa** no repositório oficial: [git.evoai.app](https://git.evoai.app)
- **E-mail** para geração dos certificados SSL

> 💡 Recomendamos usar DNS com proxy **desativado** durante a instalação. Após concluir, você pode ativar normalmente.

---

## 🔄 Passo a passo

**1.** Execute o comando de instalação:
```bash
bash <(curl -sSL setup.aoopa.com.br)
```

**2.** Informe suas credenciais do **git.evoai.app** (usuário e senha):
```
👤 Usuário do git.evoai.app: seu@email.com
🔑 Senha do git.evoai.app: ********
```

**3.** Informe os domínios e e-mail:
```
🌐 Domínio da API: api.seudominio.com
🖥️  Domínio do Manager: manager.seudominio.com
🐳 Domínio do Portainer: portainer.seudominio.com
📧 E-mail para SSL: seu@email.com
```

**4.** Confirme as informações e aguarde a instalação concluir automaticamente.

**5.** Ao finalizar, todas as credenciais serão exibidas na tela e salvas em:
```
/opt/evolution/credenciais.txt
```

---

## 📦 O que é instalado automaticamente?

```
✅ Docker + Docker Compose
✅ Nginx
✅ Certbot (SSL/HTTPS)
✅ PostgreSQL
✅ Evolution Go API
✅ Evolution Go Manager
✅ Portainer (com usuário admin configurado)
```

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
| SO | Ubuntu 22.04 | Ubuntu 22.04 / 24.04 |

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
