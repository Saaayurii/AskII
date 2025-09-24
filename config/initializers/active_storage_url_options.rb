# Configure Active Storage URL options based on current request
Rails.application.config.middleware.use(Class.new do
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    # Set URL options based on request host and port
    if request.host && request.port
      host_with_port = request.port == 80 || request.port == 443 ?
        request.host :
        "#{request.host}:#{request.port}"

      protocol = request.ssl? ? 'https' : 'http'

      ActiveStorage::Current.url_options = {
        protocol: protocol,
        host: host_with_port
      }
    end

    @app.call(env)
  end
end)