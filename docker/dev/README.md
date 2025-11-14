# AskII Development Environment Guide

Этот гайд поможет вам запустить **AskII** (Chatwoot fork) в режиме разработки с использованием Docker.

## 📋 Содержание

- [Требования](#требования)
- [Быстрый старт](#быстрый-старт)
- [Структура файлов](#структура-файлов)
- [Подробная настройка](#подробная-настройка)
- [Полезные команды](#полезные-команды)
- [Работа с кодом](#работа-с-кодом)
- [Отладка](#отладка)
- [Решение проблем](#решение-проблем)
- [Production vs Development](#production-vs-development)

---

## 🔧 Требования

Перед началом работы убедитесь, что у вас установлено:

- **Docker** (версия 20.10+)
- **Docker Compose** (версия 2.0+)
- **Git**
- Минимум **8 GB RAM**
- Минимум **20 GB** свободного места на диске

Проверить версии:
```bash
docker --version
docker compose version
```

---

## 🚀 Быстрый старт

### 1. Перейдите в папку dev
```bash
cd docker/dev
```

### 2. Скопируйте и настройте .env файл
```bash
cp .env.dev .env.dev.local
# Отредактируйте .env.dev.local при необходимости
```

### 3. Запустите контейнеры
```bash
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

### 4. Создайте базу данных
```bash
# Дождитесь запуска всех контейнеров (30-60 секунд)
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:create
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:schema:load
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:seed
```

### 5. Откройте приложение
- **Frontend**: http://localhost:3000
- **Mailhog** (email): http://localhost:8025
- **Ollama API**: http://localhost:11434

**Данные для входа по умолчанию:**
- Email: `admin@example.com`
- Password: `password` (или проверьте вывод команды seed)

---

## 📁 Структура файлов

```
docker/dev/
├── docker-compose.dev.yml    # Docker Compose конфигурация для dev
├── Dockerfile.dev             # Dockerfile для dev окружения
├── .env.dev                   # Шаблон переменных окружения
├── .env.dev.local             # Ваш локальный .env (не коммитится)
└── README.md                  # Этот файл
```

---

## ⚙️ Подробная настройка

### Переменные окружения (.env.dev)

Основные переменные, которые вы можете изменить:

```bash
# URLs
FRONTEND_URL=http://localhost:3000
ACTION_CABLE_FRONTEND_URL=ws://localhost:3000/cable

# База данных
POSTGRES_HOST=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DATABASE=chatwoot_dev

# Redis
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=redis_dev_password

# AI (Ollama)
OPENAI_API_BASE=http://ollama:11434
OPENAI_GPT_MODEL=qwen2.5:3b
```

### Настройка Ollama

После запуска контейнеров нужно загрузить модель:

```bash
# Загрузить модель qwen2.5:3b
docker compose -f docker-compose.dev.yml exec ollama ollama pull qwen2.5:3b

# Проверить список моделей
docker compose -f docker-compose.dev.yml exec ollama ollama list

# Опционально: загрузить другую модель
docker compose -f docker-compose.dev.yml exec ollama ollama pull llama2:7b
```

---

## 🛠️ Полезные команды

### Управление контейнерами

```bash
# Запустить все сервисы
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d

# Остановить все сервисы
docker compose -f docker-compose.dev.yml down

# Перезапустить конкретный сервис
docker compose -f docker-compose.dev.yml restart rails

# Посмотреть логи
docker compose -f docker-compose.dev.yml logs -f rails
docker compose -f docker-compose.dev.yml logs -f sidekiq
docker compose -f docker-compose.dev.yml logs -f vite

# Посмотреть статус сервисов
docker compose -f docker-compose.dev.yml ps
```

### Работа с базой данных

```bash
# Создать БД
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:create

# Запустить миграции
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:migrate

# Откатить миграцию
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:rollback

# Сбросить БД (удалит все данные!)
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:reset

# Зайти в консоль БД
docker compose -f docker-compose.dev.yml exec postgres psql -U postgres -d chatwoot_dev

# Создать бэкап БД
docker compose -f docker-compose.dev.yml exec postgres pg_dump -U postgres chatwoot_dev > backup.sql

# Восстановить из бэкапа
docker compose -f docker-compose.dev.yml exec -T postgres psql -U postgres chatwoot_dev < backup.sql
```

### Rails консоль и задачи

```bash
# Rails консоль
docker compose -f docker-compose.dev.yml exec rails bundle exec rails console

# Rails dbconsole
docker compose -f docker-compose.dev.yml exec rails bundle exec rails dbconsole

# Запустить rake задачу
docker compose -f docker-compose.dev.yml exec rails bundle exec rake task_name

# Создать нового пользователя-администратора
docker compose -f docker-compose.dev.yml exec rails bundle exec rails runner "User.create!(email: 'admin@test.com', password: 'password123', name: 'Admin', role: :administrator)"
```

### Работа с зависимостями

```bash
# Установить новый gem
docker compose -f docker-compose.dev.yml exec rails bundle add gem_name

# Обновить gems
docker compose -f docker-compose.dev.yml exec rails bundle update

# Установить новый npm пакет
docker compose -f docker-compose.dev.yml exec rails pnpm add package_name

# Обновить npm пакеты
docker compose -f docker-compose.dev.yml exec rails pnpm update

# Пересобрать образ после изменения зависимостей
docker compose -f docker-compose.dev.yml build rails
```

### Тестирование

```bash
# Запустить Ruby тесты (RSpec)
docker compose -f docker-compose.dev.yml exec rails bundle exec rspec

# Запустить конкретный тест
docker compose -f docker-compose.dev.yml exec rails bundle exec rspec spec/models/user_spec.rb

# Запустить JS тесты
docker compose -f docker-compose.dev.yml exec rails pnpm test

# Запустить тесты в watch режиме
docker compose -f docker-compose.dev.yml exec rails pnpm test:watch
```

### Линтинг и форматирование

```bash
# Проверить Ruby код (RuboCop)
docker compose -f docker-compose.dev.yml exec rails bundle exec rubocop

# Исправить Ruby код автоматически
docker compose -f docker-compose.dev.yml exec rails bundle exec rubocop -a

# Проверить JS/Vue код (ESLint)
docker compose -f docker-compose.dev.yml exec rails pnpm eslint

# Исправить JS/Vue код автоматически
docker compose -f docker-compose.dev.yml exec rails pnpm eslint:fix
```

---

## 💻 Работа с кодом

### Hot Reload

В dev режиме изменения кода применяются автоматически:

- **Backend (Ruby)**: Rails перезагружает классы автоматически
- **Frontend (Vue)**: Vite обновляет страницу при изменениях

### Редактирование кода

Код приложения монтируется как volume из корня проекта `../../` в `/app` внутри контейнера. Вы можете редактировать файлы на хосте, и изменения будут сразу видны в контейнере.

### Структура проекта

```
AskII/
├── app/                    # Rails приложение
│   ├── controllers/
│   ├── models/
│   ├── views/
│   ├── javascript/         # Frontend код (Vue)
│   └── services/
├── config/                 # Конфигурация
├── db/                     # Миграции и схема БД
├── docker/                 # Docker конфигурация
│   ├── dev/               # Dev окружение
│   └── Dockerfile         # Production Dockerfile
├── spec/                   # Тесты (RSpec)
├── public/                 # Статические файлы
└── storage/               # Загруженные файлы
```

---

## 🐛 Отладка

### Использование binding.pry (Ruby debugger)

1. Добавьте `binding.pry` в код:
```ruby
def some_method
  binding.pry  # Выполнение остановится здесь
  # ... ваш код
end
```

2. Подключитесь к контейнеру:
```bash
docker attach $(docker compose -f docker-compose.dev.yml ps -q rails)
```

3. Отключиться: нажмите `Ctrl+P` затем `Ctrl+Q`

### Просмотр логов

```bash
# Все логи
docker compose -f docker-compose.dev.yml logs -f

# Только Rails
docker compose -f docker-compose.dev.yml logs -f rails

# Только Sidekiq (фоновые задачи)
docker compose -f docker-compose.dev.yml logs -f sidekiq

# Только Vite (frontend)
docker compose -f docker-compose.dev.yml logs -f vite
```

### Доступ к контейнеру

```bash
# Открыть bash в Rails контейнере
docker compose -f docker-compose.dev.yml exec rails sh

# Открыть bash в postgres контейнере
docker compose -f docker-compose.dev.yml exec postgres sh
```

---

## ❗ Решение проблем

### Контейнеры не запускаются

```bash
# Проверить статус
docker compose -f docker-compose.dev.yml ps

# Посмотреть логи ошибок
docker compose -f docker-compose.dev.yml logs

# Полностью пересобрать
docker compose -f docker-compose.dev.yml down -v
docker compose -f docker-compose.dev.yml build --no-cache
docker compose -f docker-compose.dev.yml up -d
```

### Ошибки БД

```bash
# Пересоздать БД
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:drop db:create db:schema:load db:seed

# Если БД заблокирована
docker compose -f docker-compose.dev.yml restart postgres
sleep 5
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:migrate
```

### Ошибки bundler/gems

```bash
# Переустановить gems
docker compose -f docker-compose.dev.yml exec rails bundle install

# Если это не помогло, пересоберите образ
docker compose -f docker-compose.dev.yml build --no-cache rails
```

### Ошибки npm/pnpm

```bash
# Переустановить пакеты
docker compose -f docker-compose.dev.yml exec rails pnpm install

# Очистить кэш
docker compose -f docker-compose.dev.yml exec rails pnpm store prune

# Удалить node_modules и переустановить
docker compose -f docker-compose.dev.yml exec rails rm -rf node_modules
docker compose -f docker-compose.dev.yml exec rails pnpm install
```

### Порты заняты

Если порты 3000, 5432, 6379, 8025 уже используются:

```bash
# Найти процесс на порту 3000
lsof -i :3000

# Убить процесс
kill -9 PID

# Или измените порты в docker-compose.dev.yml:
# "3001:3000" вместо "3000:3000"
```

### Ollama не отвечает

```bash
# Перезапустить Ollama
docker compose -f docker-compose.dev.yml restart ollama

# Проверить модели
docker compose -f docker-compose.dev.yml exec ollama ollama list

# Загрузить модель заново
docker compose -f docker-compose.dev.yml exec ollama ollama pull qwen2.5:3b
```

### Медленная работа Docker на Mac/Windows

Если вы используете Mac или Windows и Docker работает медленно:

1. Увеличьте ресурсы Docker:
   - Docker Desktop → Settings → Resources
   - CPU: минимум 4 cores
   - Memory: минимум 8GB
   - Swap: 2GB

2. Используйте именованные volumes вместо bind mounts (уже настроено в docker-compose.dev.yml)

### Полная очистка и перезапуск

```bash
# Остановить и удалить все
docker compose -f docker-compose.dev.yml down -v

# Удалить образы
docker rmi chatwoot:dev

# Очистить Docker кэш
docker system prune -a

# Запустить заново
docker compose -f docker-compose.dev.yml build
docker compose -f docker-compose.dev.yml up -d
docker compose -f docker-compose.dev.yml exec rails bundle exec rails db:create db:schema:load db:seed
```

---

## 🔄 Production vs Development

### Основные отличия

| Параметр | Development | Production |
|----------|-------------|------------|
| **RAILS_ENV** | development | production |
| **Code reload** | ✅ Автоматически | ❌ Нет |
| **Static files** | ❌ Через Vite | ✅ Precompiled |
| **Volumes** | ✅ Код монтируется | ❌ Копируется в образ |
| **Debug logs** | ✅ Подробные | ❌ Минимальные |
| **Asset compilation** | ❌ On-demand | ✅ Precompiled |
| **Bundle gems** | Все (dev+test) | Только production |
| **Image size** | ~2-3 GB | ~1-1.5 GB |

### Переключение между окружениями

**Для development:**
```bash
cd docker/dev
docker compose -f docker-compose.dev.yml --env-file .env.dev up -d
```

**Для production:**
```bash
cd ../../  # корень проекта
docker compose -f docker-compose.yaml up -d
```

---

## 📚 Дополнительные ресурсы

- [Chatwoot Documentation](https://www.chatwoot.com/docs)
- [Rails Guides](https://guides.rubyonrails.org/)
- [Vue.js Documentation](https://vuejs.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Ollama Documentation](https://ollama.ai/docs)

---

## 🎯 Чеклист для начала работы

- [ ] Docker и Docker Compose установлены
- [ ] Клонирован репозиторий
- [ ] Создан файл `.env.dev.local` в `docker/dev/`
- [ ] Запущены контейнеры
- [ ] База данных создана и заполнена seed данными
- [ ] Ollama модель загружена
- [ ] Открыт http://localhost:3000 в браузере
- [ ] Успешный вход в систему
- [ ] Mailhog доступен на http://localhost:8025

---

## 💡 Советы

1. **Используйте алиасы** для частых команд:
```bash
# Добавьте в ~/.bashrc или ~/.zshrc
alias dc-dev='docker compose -f docker/dev/docker-compose.dev.yml'
alias dc-rails='docker compose -f docker/dev/docker-compose.dev.yml exec rails'

# Теперь можно использовать:
dc-dev up -d
dc-rails bundle exec rails console
```

2. **VS Code Dev Containers**: Для еще более удобной разработки можно использовать VS Code с расширением "Remote - Containers"

3. **Мониторинг ресурсов**:
```bash
docker stats
```

4. **Регулярно обновляйте образы**:
```bash
docker compose -f docker-compose.dev.yml pull
docker compose -f docker-compose.dev.yml build --no-cache
```

---

**Удачной разработки! 🚀**

Если возникли проблемы, проверьте раздел [Решение проблем](#решение-проблем) или создайте issue в репозитории.
