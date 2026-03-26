# arkheion_api

Rails 8 API para o Arkheion — gerenciamento de fichas de personagem Tormenta20.

## Requisitos

- Ruby 3.4.1
- PostgreSQL 16
- Docker + Docker Compose (para rodar via container)

### Instalar Docker Compose

```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Verificar
docker compose version
```

## Rodar com Docker Compose

```bash
# Copiar variáveis de ambiente
cp .env.example .env
# Preencher RAILS_MASTER_KEY em .env

# Subir
docker compose up --build

# Rodar migrations na primeira vez
docker compose exec api ./bin/rails db:migrate

# Derrubar
docker compose down
```

O serviço `api` sobe na porta `80`. O banco PostgreSQL é provisionado automaticamente.

## Desenvolvimento local

```bash
bundle install
cp .env.example .env
./bin/rails db:create db:migrate
./bin/rails s
```

## Testes

```bash
rails test
```
