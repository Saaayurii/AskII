class Llm::BaseOpenAiService
  DEFAULT_MODEL = 'qwen2.5:14b'.freeze

  def initialize
    @client = OpenAI::Client.new(
      access_token: InstallationConfig.find_by!(name: 'CAPTAIN_OPEN_AI_API_KEY').value,
      uri_base: uri_base,
      log_errors: Rails.env.development?
    )
    setup_model
  rescue StandardError => e
    raise "Failed to initialize OpenAI client: #{e.message}"
  end

  private

  def uri_base
    endpoint = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value
    endpoint.presence || ENV.fetch('OPENAI_API_BASE', 'http://ollama:11434')
  end

  def setup_model
    config_value = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value
    @model = (config_value.presence || DEFAULT_MODEL)
  end
end
