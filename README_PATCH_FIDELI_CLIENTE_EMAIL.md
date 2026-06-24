# Patch Fideli: Portal do cliente e e-mail de recompensa

Este patch ajusta:

- Portal do cliente com menos itens administrativos.
- Cartão fidelidade mais direto.
- Serviços participantes.
- Histórico do cliente.
- Recompensas do cliente.
- Mailer para e-mail de recompensa.

## Aplicação

Na raiz do projeto:

```bash
cd ~/barber-loyalty
unzip fideli_client_portal_reward_patch.zip -d /tmp/fideli_patch
cp -r /tmp/fideli_patch/* .
```

Depois:

```bash
git add .
git commit -m "Ajusta portal do cliente e email de recompensa"
git push
```

## Variáveis de ambiente para e-mail

O envio só acontece se `SMTP_ADDRESS` estiver configurado.

Exemplo no Render:

```text
APP_URL=https://barber-loyalty.onrender.com
MAIL_FROM=no-reply@seudominio.com.br
SMTP_ADDRESS=smtp.seudominio.com.br
SMTP_PORT=587
SMTP_DOMAIN=seudominio.com.br
SMTP_USER_NAME=usuario
SMTP_PASSWORD=senha
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

Também será necessário configurar `config.action_mailer.smtp_settings` no ambiente de produção, caso ainda não exista.
