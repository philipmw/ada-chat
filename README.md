<div style="float:right"><a href="https://flattr.com/submit/auto?user_id=philip4g&url=https%3A%2F%2Fgithub.com%2Fphilipmw%2Fada-chat" target="_blank"><img src="//button.flattr.com/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a></div>

# SNS demo for Ada Developers Academy

## Overview

SNS + SQS allows us to have one-to-many and many-to-many messaging.

This project demonstrates this by creating a chat room using SNS + SQS.
The chat room maintains history of unread messages and allows all students
to talk to all other students.

Here's how:

1. Using their own AWS account, each student creates their own SQS queue that
    holds your copy of everyone's chat messages.
2. Each student subscribes their queue to a single shared SNS topic, owned
    by Philip's AWS account.
3. Each student observes the "chat room" by polling their own SQS queue for messages.
4. Each student talks in the chat room by publishing a message to the shared SNS topic.

Data flow:

```
[ Cheri ]--------{{C}}--------------> /--------\
   ^                                  |        |
   \-- [Cheri's queue] <---{{C,D}}--- | Shared |
                                      |  SNS   |
[ Daphne ] ------{{D}}--------------> | topic  |
   ^                                  |        |
   \-- [Daphne's queue] <---{{C,D}}-- \--------/
```

## Prepare your own resources

1. Log in to your AWS console.
2. Create an SQS queue.  Note its ARN and URL.
3. Set permission on the queue allowing the shared SNS topic to push chat messages to you:
    1. Effect: Allow
    2. Principal: "Everybody (*)"
    3. Actions: `SendMessage`
    4. Conditions: `ArnEquals arn:SourceArn = arn:aws:sns:us-west-2:101804781795:ada-chat`
4. Create an IAM user for reading chat messages from your queue.
    Note its access and secret keys.
5. Create a policy allowing `ReceiveMessage`, `DeleteMessage`, and
    `DeleteMessageBatch` on your queue's ARN.
    Bind the policy to your new IAM user.

## Subscribing your queue

This is a one-time operation to join yourself to the chat.

Get from Philip the AWS access and secret keys for the user that's allowed
to subscribe resources to the shared SNS topic.

```
export AWS_REGION=us-west-2
export AWS_ACCESS_KEY_ID=<get from Philip>
export AWS_SECRET_ACCESS_KEY=<get from Philip>

ruby chat-subscribe.rb <ARN of your own queue>
```

## Observe chat

```
export AWS_REGION=us-west-2
export AWS_ACCESS_KEY_ID=<your IAM user>
export AWS_SECRET_ACCESS_KEY=<your IAM user>

ruby chat-observe.rb <URL of your own queue>
```

## Chat to others!

In a separate terminal from the observation program, do this:

```
export AWS_REGION=us-west-2
export AWS_ACCESS_KEY_ID=<get from Philip>
export AWS_SECRET_ACCESS_KEY=<get from Philip>

ruby chat.rb
```

## Try

Close your observer for a while.  Send some messages to the chat room.
Reopen the observer.  You'll receive the chat history containing all messages
since the moment you left.

## Keep in mind

1. SQS is "at-least-once" delivery.  You may receive the same message more than once.
    This means that SQS is suited only for idempotent messages.
    ("At {timestamp}, balance is $10" as opposed to "Subtract $3 from balance".)
2. Messages are not guaranteed to be delivered in order.  If ordering is important,
    your application must reorder them using business logic.

## Cost

There are two technologies in play here: SNS and SQS.  Further, costs are divided
between the SNS topic owner and each chat participant.

Let's assume the chat room receives:
* one message per 5 seconds for 8 hours a day (business hours) on weekdays,
* one message per 5 minutes for 16 hours a day on weekends,
* one message per hour the rest of the time.

There are 365.25 days in a year, with 5/7 of those being weekday and 2/7 being weekend.

* Weekdays: 261 days/year × 8 hours/day × 1 msg/5 sec = 125,229 msg/month
* Weekends: 104 days/year × 16 hours/day × 1 msg/5 min = 1,670 msg/month
* Remainder: ((weekdays × 16 hours/day) + (weekends × 8 hours/day)) × 1 msg/hour = 418 msg/month

The sum of the above is 127,317 messages per month.

Let's further assume that an average message is 300 bytes.  (There's data overhead
added by SNS.)  That's 38.2 MB/month.

### Cost to SNS topic owner

* Publishing: first 1M requests/month are free.  Our 127,317 requests/month are free.
* Notification deliveries: all deliveries to SQS are free.
* Data transfer in: free.

Grand total: free.

### Cost to each chat participant

There are three requests involved for each message: enqueuing it from SNS,
receiving (dequeuing, reading) it, and deleting it.

* Requests: first 1M requests are free.  3 × 127,317 requests/month are free.
* Data transfer in: free.
* Data transfer out: first 1 GB/month is free.  Our 39 MB/month is free.

Grand total: free.

## Create your own SNS topic

This demo uses an existing SNS topic in Philip's AWS account, but here's how to
set up your own.

1. Log in to the AWS Console and go to its *SNS* section.
2. Create Topic.  Give it a name such as "ada-chat".  Note its ARN.
3. Update `ADA_CHAT_TOPIC_ARN` constant of `chat.rb` and `chat-subscribe.rb` with the ARN from step 2.
4. Go to the *IAM* section of AWS Console.
5. Create a new policy; use the Policy Generator.
    1. Effect: Allow
    2. AWS Service: AWS SNS
    3. Actions: `Publish` and `Subscribe`.
    4. ARN: the ARN of your new SNS topic from step 2.
6. Create a new user; write down its access and secret keys, and set them in your environment variables.
7. Attach the policy from step 5 to the new user.

Now anyone who has your new user's access and secret keys can use `chat-subscribe.rb`
and `chat.rb` to connect their SQS queue to your topic, then to post messages to
your topic.

(Warning: this new user can incur costs to your AWS account.  Always be careful
about sharing your IAM users' credentials.)

## References

* [Documentation for associating an SQS queue with an SNS topic](http://docs.aws.amazon.com/sns/latest/dg/SendMessageToSQS.html)
* [AWS SDK for Ruby](https://aws.amazon.com/sdk-for-ruby/)
* [AWS SDK for Ruby - SQS client API](http://docs.aws.amazon.com/sdkforruby/api/Aws/SQS.html)
* [AWS SNS Pricing](https://aws.amazon.com/sns/pricing/)
* [AWS SQS Pricing](https://aws.amazon.com/sqs/pricing/)
* [AWS Simple Monthly Calculator](http://calculator.s3.amazonaws.com/index.html)
