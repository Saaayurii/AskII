#!/bin/bash

set -e

echo "🚂 Chatwoot Railway Setup Script"
echo "================================="

# Проверяем, что мы в правильной директории
if [ ! -f "package.json" ] || ! grep -q "chatwoot" package.json; then
    echo "❌ Error: Run this script from the chatwoot repository root"
    exit 1
fi

# Проверяем установку Railway CLI
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
    echo "✅ Railway CLI installed"
fi

# Генерируем SECRET_KEY_BASE
echo "🔑 Generating SECRET_KEY_BASE..."
SECRET_KEY=$(openssl rand -hex 64)

# Логин в Railway
echo "🔐 Please login to Railway..."
railway login

# Создаем новый проект
echo "📁 Creating new Railway project..."
railway new

# Добавляем PostgreSQL
echo "🐘 Adding PostgreSQL database..."
railway add -d postgres

# Добавляем Redis
echo "🔴 Adding Redis cache..."
railway add -d redis

# Устанавливаем переменные окружения
echo "⚙️  Setting up environment variables..."

railway variables --set "SECRET_KEY_BASE=$SECRET_KEY"
railway variables --set "RAILS_ENV=production"
railway variables --set "ENABLE_ACCOUNT_SIGNUP=false"
railway variables --set "FORCE_SSL=true"
railway variables --set "RAILS_MAX_THREADS=3"
railway variables --set "WEB_CONCURRENCY=1"
railway variables --set "SIDEKIQ_CONCURRENCY=3"
railway variables --set "RAILS_SERVE_STATIC_FILES=true"
railway variables --set "RAILS_LOG_TO_STDOUT=true"
railway variables --set "PORT=3000"

echo "✅ Environment variables set"

# Создаем .gitignore для Railway файлов
cat >> .gitignore << 'EOF'

# Railway
.railway/
.env.railway
railway-*.log
EOF

echo "📝 Updated .gitignore"

# Коммитим изменения
echo "💾 Committing Railway configuration..."
git add railway.toml Dockerfile.railway .env.railway setup-railway.sh
git commit -m "feat: Add Railway deployment configuration

- Add railway.toml for service configuration
- Add optimized Dockerfile for Railway
- Add environment template
- Configure for free tier resource limits"

# Пушим в GitHub
echo "📤 Pushing to GitHub..."
git push origin main

# Деплоим на Railway
echo "🚀 Deploying to Railway..."
railway up --detach

# Получаем URL приложения
echo "🌐 Getting application URL..."
sleep 10
APP_URL=$(railway status --json | grep -o '"url":"[^"]*' | cut -d'"' -f4)

echo ""
echo "🎉 Deployment completed!"
echo "================================="
echo "📱 Your Chatwoot URL: $APP_URL"
echo "🔧 Railway Dashboard: https://railway.app/dashboard"
echo ""
echo "📝 Next steps:"
echo "1. Wait 5-10 minutes for full deployment"
echo "2. Visit your app URL"
echo "3. Create admin account"
echo "4. Set up your first website inbox"
echo "5. Get widget code for your Next.js app"
echo ""
echo "⚡ Useful Railway commands:"
echo "  railway logs           # View logs"
echo "  railway status         # Check status"
echo "  railway open           # Open in browser"
echo "  railway variables      # Manage variables"

# Показываем логи в реальном времени
echo ""
read -p "Show live logs? (y/n): " show_logs
if [ "$show_logs" = "y" ]; then
    echo "📊 Live logs (Ctrl+C to exit):"
    railway logs --follow
fi