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

## Логин по умолчанию
- Email: admin@example.com
- Password: Password123!