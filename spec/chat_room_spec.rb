require 'chat_room'

describe ChatRoom do
  describe '.subscribe!' do
    it 'requires a well-formed SQS ARN' do
      expect{described_class.subscribe!('some-malformed-arn')}.to raise_error(/malformed/)
    end
  end

  describe '.observe' do
    it 'requires a well-formed SQS URL' do
      expect{described_class.observe('https://some-malformed-url')}.to raise_error(/malformed/)
    end
  end
end