require 'aws-sdk-core'

ADA_CHAT_TOPIC_ARN='arn:aws:sns:us-west-2:101804781795:ada-chat'

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
