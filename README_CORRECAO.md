# Correção Barber Loyalty

Copie as pastas `db` e `app` deste ZIP para dentro do projeto `~/barber-loyalty`, substituindo os arquivos existentes.

Depois rode:

```bash
cd ~/barber-loyalty
bundle exec rails db:drop
bundle exec rails db:create
bundle exec rails db:migrate
```

Se o `db:drop` reclamar de conexão ativa, pare o servidor Rails com `Ctrl + C` e rode de novo.
