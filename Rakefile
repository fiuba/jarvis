require 'bundler/setup'
JARVIS_ENV  = ENV['JARVIS_ENV'] ||= 'test'

puts "JARVIS_ENV: #{JARVIS_ENV}"
if ['development', 'test', 'travis'].include?(JARVIS_ENV)

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = "./spec/*_spec.rb"
    t.rspec_opts = %w(-fs --color)
  end

	task :default => [:spec]
end
