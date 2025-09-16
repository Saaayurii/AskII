#!/bin/bash

# setup-render.sh
# Скрипт автоматической подготовки для деплоя на Render

set -e

echo "🚀 Подготовка Chatwoot для деплоя на Render..."

# Проверяем, что мы в правильной директории
if [ ! -f "Gemfile" ] || [ ! -f "package.json" ]; then
    echo "❌ Ошибка: Запустите скрипт из корневой директории Chatwoot"
    exit 1
fi

# Проверяем наличие необходимых файлов
echo "📁 Проверка конфигурационных файлов..."

required_files=("render.yaml" "Dockerfile.render" ".env.render")
missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -ne 0 ]; then
    echo "❌ Отсутствуют файлы: ${missing_files[*]}"
    echo "💡 Убедитесь, что все конфигурационные файлы созданы"
    exit 1
fi

echo "✅ Все конфигурационные файлы найдены"

# Проверяем .gitignore
echo "🔍 Проверка .gitignore..."

gitignore_entries=(".env.render" "*.env" ".env.*")
for entry in "${gitignore_entries[@]}"; do
    if ! grep -q "$entry" .gitignore 2>/dev/null; then
        echo "➕ Добавляем $entry в .gitignore"
        echo "$entry" >> .gitignore
    fi
done

# Создаем резервную копию существующих env файлов
echo "💾 Создание резервных копий..."

if [ -f ".env" ]; then
    cp .env .env.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Создана резервная копия .env"
fi

# Генерируем SECRET_KEY_BASE если его нет
echo "🔐 Проверка SECRET_KEY_BASE..."

if command -v openssl >/dev/null 2>&1; then
    secret_key=$(openssl rand -hex 64)
    echo "✅ Сгенерирован новый SECRET_KEY_BASE"
    echo "🔒 SECRET_KEY_BASE: $secret_key"
    echo ""
    echo "📝 Сохраните этот ключ - он понадобится при настройке Render!"
    echo ""
else
    echo "⚠️  OpenSSL не найден. Сгенерируйте SECRET_KEY_BASE вручную:"
    echo "   openssl rand -hex 64"
fi

# Проверяем Docker
echo "🐳 Проверка Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "✅ Docker найден"

    # Тестируем сборку Dockerfile.render (опционально)
    read -p "🔨 Хотите протестировать сборку Docker образа? (y/n): " test_build

    if [ "$test_build" = "y" ] || [ "$test_build" = "Y" ]; then
        echo "🔨 Тестируем сборку Docker образа..."
        if docker build -f Dockerfile.render -t chatwoot-render-test .; then
            echo "✅ Docker образ собран успешно"
            docker rmi chatwoot-render-test 2>/dev/null || true
        else
            echo "❌ Ошибка при сборке Docker образа"
            echo "💡 Проверьте Dockerfile.render и повторите попытку"
        fi
    fi
else
    echo "⚠️  Docker не найден. Установите Docker для локального тестирования"
fi

# Проверяем Git статус
echo "📊 Проверка Git статуса..."

if git status --porcelain | grep -q .; then
    echo "📝 Есть незакоммиченные изменения:"
    git status --short
    echo ""
    echo "💡 Рекомендуется закоммитить изменения перед деплоем:"
    echo "   git add ."
    echo "   git commit -m 'Add Render deployment configuration'"
    echo "   git push origin main"
else
    echo "✅ Рабочая директория чистая"
fi

# Выводим следующие шаги
echo ""
echo "🎉 Подготовка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. 📤 Закоммитьте и запушьте изменения в Git"
echo "2. 🌐 Откройте https://dashboard.render.com"
echo "3. ➕ Создайте новый Blueprint или Web Service"
echo "4. 🔗 Подключите ваш Git репозиторий"
echo "5. 📖 Следуйте инструкциям в RENDER_DEPLOYMENT.md"
echo ""
echo "📚 Полная документация: ./RENDER_DEPLOYMENT.md"
echo ""
echo "🔧 Команды для коммита:"
echo "   git add render.yaml Dockerfile.render .env.render RENDER_DEPLOYMENT.md setup-render.sh"
echo "   git commit -m 'feat: Add Render deployment configuration'"
echo "   git push origin main"
echo ""
echo "✨ Удачного деплоя!"