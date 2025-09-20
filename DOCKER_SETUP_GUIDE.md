# Руководство по запуску Chatwoot в Docker

## Проблемы и решения при установке

### 1. Проблема с правами Docker
**Ошибка:** `permission denied while trying to connect to the Docker daemon socket`

**Решение:**
```bash
# Добавить пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker
# или перезагрузить систему
```

### 2. Проблема с установкой Docker
**Ошибка:** `Unit docker.service not found`

**Решение:**
```bash
# Установка Docker Engine
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Добавление ключа GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавление репозитория Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker Engine
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Запуск и включение Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 3. Ошибки миграций базы данных
**Ошибка:** `uninitialized constant ActsAsTaggableOn::Taggable::Cache`

**Решение:**
```bash
# Полный сброс базы данных
docker compose down -v
docker compose up -d
docker compose exec rails bundle exec rails db:create db:schema:load db:seed
```

### 4. Проблема с паролями базы данных
**Ошибка:** `There is an issue connecting to your database with your username/password`

**Решение:** Обновить пароли в `.env` и `docker-compose.yaml`

### 5. Проблема с SDK файлом виджета
**Ошибка:** `No route matches [GET] "/packs/js/sdk.js"`

**Решение:**
```bash
# Сборка ассетов
sudo docker compose exec rails bundle exec rails assets:precompile
```

### 6. Проблема с перерендером виджета
**Ошибка:** Бесконечная перезагрузка виджета

**Решение:** Использовать простой HTTP сервер вместо Live Server

## Пошаговая инструкция

### 1. Подготовка окружения
```bash
# Клонирование репозитория
git clone https://github.com/chatwoot/chatwoot.git
cd chatwoot

# Создание .env файла
cp .env.example .env
```

### 2. Настройка .env файла
```env
SECRET_KEY_BASE=a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
FRONTEND_URL=http://localhost:3000
ENABLE_ACCOUNT_SIGNUP=false
REDIS_URL=redis://redis:6379
REDIS_PASSWORD=redis_password
POSTGRES_HOST=postgres
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=chatwoot_password
RAILS_ENV=development
```

### 3. Настройка docker-compose.yaml
Обновить пароль PostgreSQL:
```yaml
environment:
  - POSTGRES_DB=chatwoot
  - POSTGRES_USER=postgres
  - POSTGRES_PASSWORD=chatwoot_password
```

### 4. Запуск Docker
```bash
# Сборка образов
docker compose build base
docker compose build rails vite sidekiq

# Запуск контейнеров
docker compose up -d

# Создание базы данных
docker compose exec rails bundle exec rails db:create db:schema:load db:seed

# Сборка ассетов
docker compose exec rails bundle exec rails assets:precompile
```

### 5. Создание администратора
```bash
# Вход в Rails консоль
docker compose exec rails bundle exec rails console

# Создание аккаунта и пользователя
account = Account.create!(name: 'My Company')
user = User.create!(name: 'Admin User', email: 'admin@example.com', password: 'Password123!', password_confirmation: 'Password123!')
AccountUser.create!(account: account, user: user, role: 'administrator')

# Подтверждение пользователя
user.confirm
exit
```

### 6. Тестирование виджета
```bash
# Создание простого HTTP сервера
python3 -m http.server 8080
```

HTML файл для тестирования:
```html
<!DOCTYPE html>
<html>
<head>
    <title>Test Chatwoot Widget</title>
</head>
<body>
    <h1>Test Page</h1>
    <script>
    (function(d,t) {
      var BASE_URL="http://localhost:3000";
      var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
      g.src=BASE_URL+"/packs/js/sdk.js";
      g.async = true;
      s.parentNode.insertBefore(g,s);
      g.onload=function(){
        window.chatwootSDK.run({
          websiteToken: 'YOUR_WEBSITE_TOKEN',
          baseUrl: BASE_URL
        })
      }
    })(document,"script");
    </script>
</body>
</html>
```

## Доступные сервисы

- **Chatwoot Admin**: http://localhost:3000
- **MailHog**: http://localhost:8025
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## Удаленный доступ

### Через ngrok
```bash
# Установка ngrok
sudo snap install ngrok

# Создание туннеля
ngrok http 3000

# Обновление FRONTEND_URL в .env
FRONTEND_URL=https://abc123.ngrok.io
```

### Через локальную сеть
```bash
# Узнать IP адрес
ip addr show | grep 'inet ' | grep -v 127.0.0.1

# Открыть порты в docker-compose.yaml
ports:
  - "0.0.0.0:3000:3000"
```

## Полезные команды

```bash
# Просмотр логов
docker compose logs rails -f

# Перезапуск сервисов
docker compose restart

# Остановка всех контейнеров
docker compose down

# Полная очистка (с удалением данных)
docker compose down -v

# Проверка статуса контейнеров
docker compose ps
```

## Настройка AI (Qwen2.5:14b через Ollama)

### 1. Добавление Ollama в docker-compose.yaml
Ollama уже включен в docker-compose.yaml:
```yaml
ollama:
  image: ollama/ollama:latest
  ports:
    - "11434:11434"
  volumes:
    - ollama_data:/root/.ollama
  environment:
    - OLLAMA_HOST=0.0.0.0:11434
  restart: unless-stopped
```

### 2. Установка модели Qwen2.5:14b
```bash
# Скачать модель Qwen2.5:14b (9.0 GB)
docker exec chatwoot-ollama-1 ollama pull qwen2.5:14b

# Проверить установленные модели
docker exec chatwoot-ollama-1 ollama list
```

### 3. Настройка AI конфигурации
```bash
# Запустить скрипт настройки
docker-compose exec rails bundle exec rails runner setup_ai_config.rb
```

Этот скрипт создаст следующие настройки:
- `CAPTAIN_OPEN_AI_API_KEY`: `ollama-local-key`
- `CAPTAIN_OPEN_AI_ENDPOINT`: `http://ollama:11434`
- `CAPTAIN_OPEN_AI_MODEL`: `qwen2.5:14b`

### 4. Настройка OpenAI интеграции в админке
1. Перейдите в **Settings** → **Integrations** → **OpenAI**
2. Введите API Key: `ollama-local-key`
3. Включите **Show label suggestions** (опционально)
4. Сохраните настройки

### 5. Переменные окружения в docker-compose.yaml
Убедитесь что в `docker-compose.yaml` установлены правильные переменные:
```yaml
environment:
  - OPENAI_API_KEY=ollama
  - OPENAI_API_BASE=http://ollama:11434
  - OPENAI_GPT_MODEL=qwen2.5:14b
```

### 6. Перезапуск для применения изменений
```bash
# Перезапустить все контейнеры
docker-compose down && docker-compose up -d

# Или только Rails сервисы
docker-compose restart rails sidekiq
```

### 7. Тестирование AI функций
В любом разговоре попробуйте:
- **Expand** - развернуть ответ
- **Summarize** - создать краткое изложение
- **Rephrase** - переформулировать
- **Fix spelling** - исправить грамматику
- **Make friendly/formal** - изменить тон

### 8. Создание кастомной модели (опционально)
Для лучшей работы на русском языке можно создать кастомную модель:

1. Создайте файл `qwen-russian.modelfile`:
```
# Qwen настроенный для русского языка
FROM qwen2.5:14b

# Системный промпт для лучшей работы на русском
SYSTEM """Ты - опытный помощник службы поддержки, который отвечает клиентам на русском языке.

Твои основные принципы:
- Всегда отвечай на русском языке
- Будь вежливым и профессиональным
- Давай краткие, но полные ответы
- Используй простой и понятный язык
- Проявляй эмпатию к проблемам клиентов
"""

# Параметры для лучшей генерации
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER top_k 40
```

2. Создайте модель:
```bash
# Скопировать файл в контейнер
docker cp qwen-russian.modelfile chatwoot-ollama-1:/tmp/

# Создать кастомную модель
docker exec chatwoot-ollama-1 ollama create qwen-russian -f /tmp/qwen-russian.modelfile

# Обновить конфигурацию на новую модель
# В setup_ai_config.rb замените 'qwen2.5:14b' на 'qwen-russian'
```

### Устранение неполадок AI

**Ошибка: "model not found"**
```bash
# Проверить доступные модели
docker exec chatwoot-ollama-1 ollama list

# Перезапустить Ollama
docker-compose restart ollama
```

**Ошибка: "Net::ReadTimeout"**
- Таймаут уже увеличен до 120 секунд
- Модель Qwen2.5:14b требует времени для генерации

**Ошибка: "connection refused"**
```bash
# Проверить что Ollama запущен
docker-compose ps ollama

# Проверить логи Ollama
docker-compose logs ollama
```

## Логин по умолчанию
- Email: admin@example.com
- Password: Password123!