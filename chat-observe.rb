require 'aws-sdk-resources'
require 'json'

queue_url = ARGV[0]
if !queue_url || !queue_url.start_with?('https://sqs.us-west-2.amazonaws.com/')
  raise 'Pass your chat SQS URL as the command-line argument.'
end

puts "Observing chat SQS ARN #{queue_url}.\n\n"

sqs = Aws::SQS::QueuePoller.new(queue_url)
sqs.poll do |msg_resp|
  msg_hash = JSON.parse(JSON.parse(msg_resp.body)['Message'])
  sent_ts = DateTime.strptime(msg_hash['ts'], '%FT%T%z')
  puts "[#{sent_ts.strftime('%T')}] #{'%10s' % msg_hash['sent_by']}> #{msg_hash['msg']}"
end
