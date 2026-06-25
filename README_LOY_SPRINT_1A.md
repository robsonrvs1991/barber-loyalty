# Loy Sprint 1A - Painel Owner + SaaS inicial

Objetivo: permitir testar hoje:

- Seu painel `/owner`
- Cadastro de empresas
- Responsável da empresa
- Assinatura com trial, free, bloqueio e valor R$ 19,90
- Envio de e-mail com login/senha/link para cliente
- Separação básica entre Owner, Empresa e Cliente

## Aplicar

Na raiz do projeto:

```bash
cd ~/barber-loyalty
unzip loy_sprint_1a_owner_panel.zip -d /tmp/loy_sprint_1a
cp -r /tmp/loy_sprint_1a/* .
bundle exec rails db:migrate
```

## Criar seu usuário Owner

```bash
bundle exec rails console
```

```ruby
User.create!(
  name: "Robson",
  email: "SEU_EMAIL_AQUI",
  role: "owner",
  password: "123456"
)
```

Depois acesse:

```text
/login
```

Ao logar como `owner`, você vai para:

```text
/owner
```

## Subir

```bash
git add .
git commit -m "Sprint 1A painel owner Loy"
git push
```

No Render, aguarde o deploy.
