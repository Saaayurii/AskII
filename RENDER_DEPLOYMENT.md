# Развертывание Chatwoot на Render

Это руководство поможет вам развернуть Chatwoot на платформе Render.

## Предварительные требования

1. **Аккаунт Render**: Зарегистрируйтесь на [render.com](https://render.com)
2. **Репозиторий Git**: Ваш код должен быть в GitHub, GitLab или Bitbucket
3. **Базовое понимание**: Знание основ Docker и переменных окружения

## Пошаговая инструкция

### Шаг 1: Подготовка репозитория

1. Убедитесь, что файлы `render.yaml` и `Dockerfile.render` находятся в корне проекта
2. Закоммитьте и запушьте изменения в ваш репозиторий:

```bash
git add render.yaml Dockerfile.render .env.render
git commit -m "Add Render deployment configuration"
git push origin main
```

### Шаг 2: Создание сервисов в Render

#### Вариант A: Используя Blueprint (рекомендуется)

1. Войдите в [Render Dashboard](https://dashboard.render.com)
2. Нажмите **"New"** → **"Blueprint"**
3. Подключите ваш Git репозиторий
4. Render автоматически обнаружит `render.yaml` и создаст все необходимые сервисы

#### Вариант B: Ручное создание сервисов

Если Blueprint не работает, создайте сервисы вручную:

1. **PostgreSQL Database**:
   - Нажмите "New" → "PostgreSQL"
   - Name: `chatwoot-postgres`
   - Database Name: `chatwoot`
   - User: `chatwoot`
   - Region: `Frankfurt` (или ближайший к вам)
   - Plan: `Free`

2. **Redis**:
   - Нажмите "New" → "Redis"
   - Name: `chatwoot-redis`
   - Region: `Frankfurt`
   - Plan: `Free`

3. **Web Service**:
   - Нажмите "New" → "Web Service"
   - Подключите ваш репозиторий
   - Name: `chatwoot-web`
   - Environment: `Docker`
   - Dockerfile Path: `./Dockerfile.render`
   - Region: `Frankfurt`
   - Plan: `Free` (или `Starter` для лучшей производительности)

### Шаг 3: Настройка переменных окружения

В настройках Web Service добавьте следующие переменные:

#### Обязательные переменные:
```
RAILS_ENV=production
SECRET_KEY_BASE=[сгенерируется автоматически]
FRONTEND_URL=https://your-app-name.onrender.com
ENABLE_ACCOUNT_SIGNUP=false
FORCE_SSL=true
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
PORT=3000
```

#### Переменные базы данных:
```
POSTGRES_HOST=[из настроек PostgreSQL сервиса]
POSTGRES_USERNAME=[из настроек PostgreSQL сервиса]
POSTGRES_PASSWORD=[из настроек PostgreSQL сервиса]
POSTGRES_DATABASE=[из настроек PostgreSQL сервиса]
DATABASE_URL=[из настроек PostgreSQL сервиса]
```

#### Переменные Redis:
```
REDIS_URL=[из настроек Redis сервиса]
```

#### Оптимизация производительности:
```
RAILS_MAX_THREADS=3
WEB_CONCURRENCY=1
SIDEKIQ_CONCURRENCY=3
```

### Шаг 4: Деплой

1. После настройки всех переменных нажмите **"Create Web Service"**
2. Render начнет процесс сборки и развертывания
3. Первый деплой может занять 10-15 минут
4. Следите за логами в реальном времени в Render Dashboard

### Шаг 5: Первоначальная настройка

После успешного деплоя:

1. Откройте ваше приложение по URL: `https://your-app-name.onrender.com`
2. Создайте администраторский аккаунт
3. Настройте базовые параметры Chatwoot

## Важные моменты

### Ограничения бесплатного плана Render:

- **Sleep mode**: Приложение "засыпает" после 15 минут бездействия
- **CPU/Memory**: Ограниченные ресурсы
- **База данных**: 1GB PostgreSQL, 25MB Redis
- **Bandwidth**: 100GB/месяц

### Рекомендации для продакшена:

1. **Обновитесь до Starter плана** ($7/месяц) для:
   - Отсутствия sleep mode
   - Больше ресурсов CPU/памяти
   - Custom domains

2. **Настройте email**:
   - Добавьте SMTP настройки для уведомлений
   - Используйте Gmail, SendGrid или другой SMTP провайдер

3. **Мониторинг**:
   - Настройте Sentry для отслеживания ошибок
   - Используйте Health Checks

## Troubleshooting

### Проблема: Приложение не запускается

**Решение**:
1. Проверьте логи в Render Dashboard
2. Убедитесь, что все переменные окружения установлены
3. Проверьте подключение к базе данных

### Проблема: База данных не подключается

**Решение**:
1. Убедитесь, что PostgreSQL сервис запущен
2. Проверьте правильность DATABASE_URL
3. Убедитесь, что все сервисы в одном регионе

### Проблема: Медленная работа

**Решение**:
1. Обновитесь до Starter плана
2. Оптимизируйте переменные RAILS_MAX_THREADS и WEB_CONCURRENCY
3. Используйте CDN для статических файлов

## Обновление приложения

1. Внесите изменения в код
2. Закоммитьте и запушьте в репозиторий
3. Render автоматически пересоберет и развернет приложение
4. Или запустите ручной деплой в Dashboard

## Поддержка

- [Render Documentation](https://render.com/docs)
- [Chatwoot Documentation](https://www.chatwoot.com/docs)
- [Community Support](https://discord.gg/cJXdrwS)

---

**Примечание**: Этот гайд создан для базового развертывания. Для продакшен-среды рекомендуется дополнительная настройка безопасности, мониторинга и резервного копирования.