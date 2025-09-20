#!/usr/bin/env ruby

puts '=== Creating InstallationConfig records ==='

configs = {
  'CAPTAIN_OPEN_AI_API_KEY' => 'ollama-local-key',
  'CAPTAIN_OPEN_AI_ENDPOINT' => 'http://ollama:11434',
  'CAPTAIN_OPEN_AI_MODEL' => 'qwen2.5:14b'
}

configs.each do |key, value|
  config = InstallationConfig.find_by(name: key)
  if config
    puts "#{key}: #{config.value}"
    if config.value != value
      config.update!(value: value)
      puts "#{key}: Updated to #{value}"
    end
  else
    puts "#{key}: NOT FOUND - Creating..."
    InstallationConfig.create!(name: key, value: value)
    puts "#{key}: Created with value #{value}"
  end
end

puts ''
puts '=== Checking OpenAI Integration Hooks ==='
begin
  if defined?(Integrations::Hook)
    hooks = Integrations::Hook.where(app_id: 'openai')
  else
    hooks = []
  end

  if hooks.any?
    hooks.each do |hook|
      puts "Hook ID: #{hook.id}"
      puts "Settings: #{hook.settings}"
      puts "Status: #{hook.status}"
    end
  else
    puts 'No OpenAI hooks found - you need to configure AI integration in admin panel'
  end
rescue => e
  puts "Could not check hooks: #{e.message}"
  puts 'You may need to configure AI integration in admin panel'
end

puts ''
puts '=== Verification ==='
puts "CAPTAIN_OPEN_AI_API_KEY: #{InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value}"
puts "CAPTAIN_OPEN_AI_ENDPOINT: #{InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value}"
puts "CAPTAIN_OPEN_AI_MODEL: #{InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_MODEL')&.value}"