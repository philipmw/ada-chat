require 'aws-sdk-core'

ADA_CHAT_TOPIC_ARN='arn:aws:sns:us-west-2:101804781795:ada-chat'

queue_arn = ARGV[0]
if !queue_arn || !queue_arn.start_with?('arn:aws:sqs')
  raise 'Pass your chat SQS ARN as the command-line argument.'
end
puts "Your chat SQS queue ARN is #{queue_arn}."

puts "Initializing SNS client..."
sns = Aws::SNS::Client.new

puts "Requesting subscription to Ada chat topic..."
subscription_arn = sns.subscribe({
  topic_arn: ADA_CHAT_TOPIC_ARN,
  protocol: 'sqs',
  endpoint: queue_arn,
}).subscription_arn
puts "Success.  Subscription ARN: #{subscription_arn}"
