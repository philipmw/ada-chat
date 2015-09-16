require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

require_relative 'lib/chat_room'

task :subscribe do
  raise 'Pass your chat SQS ARN as command-line argument' unless ARGV[1]
  ChatRoom.subscribe!(ARGV[1])
end

task :observe do
  raise 'Pass your chat SQS URL as the command-line argument.' unless ARGV[1]
  ChatRoom.observe(ARGV[1])
end

task :chat do
  ChatRoom.chat
end