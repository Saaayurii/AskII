# 🚀 Quick Start - AskII Development

Быстрая шпаргалка по командам для разработки.

## Первый запуск

```bash
cd docker/dev
cp .env.dev .env.dev.local
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:create db:schema:load db:seed
docker compose -f docker-compose.dev.yml exec ollama ollama pull qwen2.5:3b
```

Готово! Открывайте http://localhost:3000

---

## Ежедневные команды

### Запуск/Остановка
```bash
# Запустить
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d

# Остановить
docker compose -f docker-compose.dev.yml down

# Перезапустить
docker compose -f docker-compose.dev.yml restart
```

### Логи
```bash
# Все логи
docker compose -f docker-compose.dev.yml logs -f

# Rails
docker compose -f docker-compose.dev.yml logs -f rails

# Sidekiq
docker compose -f docker-compose.dev.yml logs -f sidekiq
```

### Rails консоль
```bash
docker compose -f docker-compose.dev.yml exec rails bundle exec rails console
```

### База данных
```bash
# Миграции
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:migrate

# Откат
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:rollback

# Сброс БД
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:reset
```

### Тесты
```bash
# Ruby тесты
docker compose -f docker-compose.dev.yml exec rails bundle exec rspec

# JS тесты
docker compose -f docker-compose.dev.yml exec rails pnpm test
```

### Линтинг
```bash
# Ruby
docker compose -f docker-compose.dev.yml exec rails bundle exec rubocop -a

# JS/Vue
docker compose -f docker-compose.dev.yml exec rails pnpm eslint:fix
```

---

## Полезные алиасы

Добавьте в `~/.bashrc` или `~/.zshrc`:

```bash
alias dc='docker compose -f docker/dev/docker-compose.dev.yml'
alias dcr='docker compose -f docker/dev/docker-compose.dev.yml exec rails'

# Теперь можно:
dc up -d
dc logs -f rails
dcr bundle exec rails console
dcr bundle exec rspec
```

---

## Проблемы?

### Пересборка
```bash
docker compose -f docker-compose.dev.yml down -v
docker compose -f docker-compose.dev.yml build --no-cache
docker compose -f docker-compose.dev.yml up -d
```

### Очистка
```bash
docker system prune -a
docker volume prune
```

Подробная документация → [README.md](README.md)
