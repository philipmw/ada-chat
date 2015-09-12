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
3. Set permission on the queue allowing principal `101804781795`
   (Philip's AWS account which owns the SNS topic) to `SendMessage`.
   (This allows the shared SNS topic to push chat messages to you.)
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

## Keep in mind

1. SQS is "at-least-once" delivery.  You may receive the same message more than once.
   This means that SQS is suited only for idempotent messages.
   ("Balance is now $10" as opposed to "Subtract $3 from balance".)
2. Messages are not guaranteed to be delivered in order.  If ordering is important,
   your application must reorder them using business logic.