# arkheion_api

Rails 8 API para o Arkheion — gerenciamento de fichas de personagem Tormenta20.

## Requisitos

- Ruby 3.4.1
- PostgreSQL 16
- [Docker + Docker Compose](https://docs.docker.com/engine/install/)
- [direnv](https://direnv.net/#basic-installation)

## Configuração

### Variáveis de ambiente

Adicione o hook do direnv ao seu shell:

```bash
# bash (~/.bashrc)
eval "$(direnv hook bash)"

# zsh (~/.zshrc)
eval "$(direnv hook zsh)"
```

Copie e preencha o `.envrc`:

```bash
cp .envrc.sample .envrc
direnv allow
```

Valores necessários:
- `RAILS_MASTER_KEY` → `cat config/master.key`
- `KAMAL_REGISTRY_PASSWORD` → token gerado em **hub.docker.com → Account Settings → Personal access tokens**
- `ALLOWED_ORIGINS` → URL do frontend (ex: `https://app.exemplo.com`)

## Desenvolvimento

### Rodar com Docker Compose

```bash
docker compose up --build
```

O serviço `api` sobe na porta `80`. O banco PostgreSQL é provisionado automaticamente.

### Rodar localmente

```bash
bundle install
./bin/rails db:create db:migrate
./bin/rails s
```

### Testes

```bash
rails test
```

## Deploy com Kamal

O deploy é feito via [Kamal](https://kamal-deploy.org/) para um único droplet (app + PostgreSQL no mesmo servidor).

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) instalado localmente
- Conta no [Docker Hub](https://hub.docker.com/) com um token de acesso
- Acesso SSH ao droplet (chave pública configurada)

### Configuração inicial

**1. Copiar e preencher o deploy.yml**

```bash
cp config/deploy.yml.sample config/deploy.yml
```

Substituir no `config/deploy.yml`:
- `seu-usuario-dockerhub` → seu usuário do Docker Hub
- `0.0.0.0` → IP público do droplet

**2.** Preencher o `.envrc` conforme a seção [Variáveis de ambiente](#variáveis-de-ambiente) acima.

### Primeiro deploy

```bash
bundle install

kamal setup   # instala Docker no servidor e sobe o PostgreSQL
kamal deploy  # faz o build, push e deploy da aplicação
```

`kamal setup` só precisa ser rodado uma vez.

### Deploys subsequentes

```bash
kamal deploy
```

### Comandos úteis

```bash
kamal logs          # logs da aplicação em tempo real
kamal console       # rails console remoto
kamal exec -i bash  # shell no container
kamal app restart   # reiniciar a aplicação
```
