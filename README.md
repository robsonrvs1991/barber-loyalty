# Correção: helpers de autenticação

Este patch expõe os métodos `logged_in?`, `barber?`, `customer?`, `current_user` e `current_barbershop` para as views.

Aplicar na raiz do projeto:

```bash
cd ~/barber-loyalty
unzip fix_auth_helpers.zip -d /tmp/fix_auth_helpers
cp -r /tmp/fix_auth_helpers/* .
bundle exec rails server
```
