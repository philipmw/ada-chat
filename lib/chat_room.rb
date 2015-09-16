require 'aws-sdk-resources'
require 'json'

class ChatRoom
  ADA_CHAT_TOPIC_ARN='arn:aws:sns:us-west-2:101804781795:ada-chat'

  def self.subscribe!(queue_arn)
    raise 'Your chat SQS ARN is malformed' unless queue_arn.start_with?('arn:aws:sqs')
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
  end

  def self.observe(queue_url)
    raise 'Your chat SQS URL is malformed' unless queue_url.start_with?('https://sqs.us-west-2.amazonaws.com/')
    puts "Observing chat SQS ARN #{queue_url}.\n\n"

    sqs = Aws::SQS::QueuePoller.new(queue_url)
    sqs.poll do |msg_resp|
      msg_hash = JSON.parse(JSON.parse(msg_resp.body)['Message'])
      sent_ts = DateTime.strptime(msg_hash['ts'], '%FT%T%z')
      puts "[#{sent_ts.strftime('%T')}] #{'%10s' % msg_hash['sent_by']}> #{msg_hash['msg']}"
    end
  end

  def self.chat
    begin
      print "What's your name?> "
      name = STDIN.readline.strip
    end while name.length < 1

    puts "Initializing SNS client..."
    sns = Aws::SNS::Client.new

    puts "Ready to chat.  Send EOF (Ctrl-D on Mac, Ctrl-Z on Windows) to finish."

    print "#{name}> "
    STDIN.each_line do |line|
      msg = JSON.dump({
        ts: Time.now.strftime('%FT%T%:z'),
        sent_by: name,
        msg: line.strip,
      })

      msg_id = sns.publish({
        topic_arn: ADA_CHAT_TOPIC_ARN,
        message: msg,
      })
      print "#{name}> "
    end
  end
end