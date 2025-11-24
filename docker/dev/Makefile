# Makefile for AskII Development Environment
# Usage: make <command>

.PHONY: help up down restart build logs shell console db-create db-migrate db-seed db-reset test lint clean

# Default command
help:
	@echo "AskII Development Commands:"
	@echo ""
	@echo "  Setup:"
	@echo "  make init         - Первоначальная настройка (up + db + ollama + admin)"
	@echo "  make up           - Запустить все сервисы"
	@echo "  make down         - Остановить все сервисы"
	@echo "  make restart      - Перезапустить все сервисы"
	@echo "  make build        - Пересобрать образы"
	@echo ""
	@echo "  Development:"
	@echo "  make logs         - Показать логи (Ctrl+C для выхода)"
	@echo "  make logs-rails   - Показать логи Rails"
	@echo "  make shell        - Открыть shell в Rails контейнере"
	@echo "  make console      - Открыть Rails консоль"
	@echo ""
	@echo "  Database:"
	@echo "  make db-create    - Создать БД"
	@echo "  make db-migrate   - Запустить миграции"
	@echo "  make db-seed      - Заполнить БД тестовыми данными"
	@echo "  make db-reset     - Сбросить БД (удалит все данные!)"
	@echo ""
	@echo "  Admin & Widget:"
	@echo "  make admin-create - Создать нового администратора"
	@echo "  make widget-code  - Получить код виджета для сайта"
	@echo "  make widget-test  - Создать тестовую HTML страницу с виджетом"
	@echo ""
	@echo "  Testing:"
	@echo "  make test         - Запустить тесты"
	@echo "  make lint         - Проверить код (RuboCop + ESLint)"
	@echo "  make lint-fix     - Исправить код автоматически"
	@echo ""
	@echo "  Maintenance:"
	@echo "  make clean        - Удалить все контейнеры и volumes"
	@echo "  make rebuild      - Полная пересборка (clean + build + up)"
	@echo "  make ollama-pull  - Загрузить Ollama модель"
	@echo ""

# Docker Compose command
DC = docker compose -f docker-compose.dev.yml --env-file .env.dev

# Start services
up:
	$(DC) up -d
	@echo "✅ Сервисы запущены!"
	@echo "📱 Frontend: http://localhost:3000"
	@echo "📧 Mailhog: http://localhost:8025"
	@echo "🤖 Ollama: http://localhost:11434"

# Stop services
down:
	$(DC) down
	@echo "✅ Сервисы остановлены"

# Restart services
restart:
	$(DC) restart
	@echo "✅ Сервисы перезапущены"

# Build images
build:
	$(DC) build
	@echo "✅ Образы собраны"

# Show logs
logs:
	$(DC) logs -f

# Show Rails logs only
logs-rails:
	$(DC) logs -f rails

# Show Sidekiq logs
logs-sidekiq:
	$(DC) logs -f sidekiq

# Show Vite logs
logs-vite:
	$(DC) logs -f vite

# Open shell in Rails container
shell:
	$(DC) exec rails sh

# Open Rails console
console:
	$(DC) exec rails bundle exec rails console

# Database: Create
db-create:
	$(DC) exec rails bundle exec rails db:create
	@echo "✅ База данных создана"

# Database: Run migrations
db-migrate:
	$(DC) exec rails bundle exec rails db:migrate
	@echo "✅ Миграции выполнены"

# Database: Seed
db-seed:
	$(DC) exec rails bundle exec rails db:seed
	@echo "✅ Данные добавлены"

# Database: Reset
db-reset:
	@echo "⚠️  ВНИМАНИЕ: Все данные будут удалены!"
	@read -p "Продолжить? [y/N]: " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DC) exec rails bundle exec rails db:reset; \
		echo "✅ База данных сброшена"; \
	else \
		echo "❌ Отменено"; \
	fi

# Database: Setup (create + schema + seed)
db-setup:
	$(DC) exec rails bundle exec rails db:create db:schema:load db:seed
	@echo "✅ База данных настроена"

# Run tests
test:
	$(DC) exec rails bundle exec rspec

# Run JS tests
test-js:
	$(DC) exec rails pnpm test

# Lint code
lint:
	@echo "🔍 Проверка Ruby кода..."
	$(DC) exec rails bundle exec rubocop
	@echo "🔍 Проверка JS/Vue кода..."
	$(DC) exec rails pnpm eslint

# Lint and auto-fix
lint-fix:
	@echo "🔧 Исправление Ruby кода..."
	$(DC) exec rails bundle exec rubocop -a
	@echo "🔧 Исправление JS/Vue кода..."
	$(DC) exec rails pnpm eslint:fix
	@echo "✅ Код исправлен"

# Clean everything
clean:
	@echo "⚠️  ВНИМАНИЕ: Все контейнеры и данные будут удалены!"
	@read -p "Продолжить? [y/N]: " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DC) down -v; \
		docker system prune -f; \
		echo "✅ Очистка завершена"; \
	else \
		echo "❌ Отменено"; \
	fi

# Rebuild everything
rebuild: clean build up db-setup
	@echo "✅ Полная пересборка завершена!"

# Install dependencies
install:
	$(DC) exec rails bundle install
	$(DC) exec rails pnpm install
	@echo "✅ Зависимости установлены"

# Pull Ollama model
ollama-pull:
	$(DC) exec ollama ollama pull qwen2.5:3b
	@echo "✅ Ollama модель загружена"

# List Ollama models
ollama-list:
	$(DC) exec ollama ollama list

# Check status
status:
	$(DC) ps

# Create admin user
admin-create:
	@echo "🔐 Создание администратора..."
	@read -p "Email [admin@example.com]: " email; \
	email=$${email:-admin@example.com}; \
	read -p "Пароль [SecurePassword123]: " password; \
	password=$${password:-SecurePassword123}; \
	read -p "Имя [Администратор]: " name; \
	name=$${name:-Администратор}; \
	$(DC) exec rails bundle exec rails runner " \
	account = Account.find_or_create_by!(name: 'Моя компания'); \
	user = User.find_or_create_by!(email: '$${email}') do |u| \
	  u.password = '$${password}'; \
	  u.password_confirmation = '$${password}'; \
	  u.name = '$${name}'; \
	  u.account = account; \
	end; \
	AccountUser.find_or_create_by!(account: account, user: user, role: :administrator); \
	puts '✅ Администратор создан:'; \
	puts 'Email: $${email}'; \
	puts 'Password: $${password}'; \
	"

# Get widget code
widget-code:
	@echo "📱 Получение кода виджета..."
	$(DC) exec rails bundle exec rails runner " \
	inbox = Inbox.first; \
	if inbox.nil?; \
	  puts '❌ Inbox не найден. Создайте inbox в админ-панели.'; \
	  exit 1; \
	end; \
	token = inbox.channel.website_token; \
	puts ''; \
	puts '=== КОД ВИДЖЕТА ==='; \
	puts '<script>'; \
	puts '(function(d,t) {'; \
	puts '  var BASE_URL=\"http://localhost:3000\";'; \
	puts '  var g=d.createElement(t),s=d.getElementsByTagName(t)[0];'; \
	puts '  g.src=BASE_URL+\"/packs/js/sdk.js\";'; \
	puts '  g.defer = true;'; \
	puts '  g.async = true;'; \
	puts '  s.parentNode.insertBefore(g,s);'; \
	puts '  g.onload=function(){'; \
	puts '    window.chatwootSDK.run({'; \
	puts '      websiteToken: \"' + token + '\",'; \
	puts '      baseUrl: BASE_URL'; \
	puts '    })'; \
	puts '  }'; \
	puts '})(document,\"script\");'; \
	puts '</script>'; \
	puts ''; \
	"

# Create test widget HTML file
widget-test:
	@echo "📝 Создание тестовой страницы виджета..."
	$(DC) exec rails bundle exec rails runner " \
	inbox = Inbox.first; \
	if inbox.nil?; \
	  puts '❌ Inbox не найден. Создайте inbox в админ-панели.'; \
	  exit 1; \
	end; \
	token = inbox.channel.website_token; \
	File.write('test-widget.html', <<~HTML); \
	  <!DOCTYPE html>; \
	  <html lang=\"ru\">; \
	  <head>; \
	      <meta charset=\"UTF-8\">; \
	      <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">; \
	      <title>Тест виджета Chatwoot</title>; \
	  </head>; \
	  <body>; \
	      <h1>Тестовая страница виджета</h1>; \
	      <p>Виджет должен появиться в правом нижнем углу</p>; \
	      <script>; \
	      (function(d,t) {; \
	        var BASE_URL=\"http://localhost:3000\";; \
	        var g=d.createElement(t),s=d.getElementsByTagName(t)[0];; \
	        g.src=BASE_URL+\"/packs/js/sdk.js\";; \
	        g.defer = true;; \
	        g.async = true;; \
	        s.parentNode.insertBefore(g,s);; \
	        g.onload=function(){; \
	          window.chatwootSDK.run({; \
	            websiteToken: '#{token}',; \
	            baseUrl: BASE_URL; \
	          }); \
	        }; \
	      })(document,\"script\");; \
	      </script>; \
	  </body>; \
	  </html>; \
	HTML; \
	puts '✅ Файл test-widget.html создан'; \
	"
	@echo "🌐 Откройте test-widget.html в браузере"

# First time setup
init: up db-setup ollama-pull admin-create
	@echo ""
	@echo "✅ Инициализация завершена!"
	@echo "📱 Frontend: http://localhost:3000"
	@echo "📧 Mailhog: http://localhost:8025"
	@echo ""
