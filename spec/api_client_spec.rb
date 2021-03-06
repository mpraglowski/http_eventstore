require 'spec_helper'

module HttpEventstore
  module Api
    describe Client do

      let(:client)      { Client.new('localhost', 2113, 20) }
      let(:stream_name) { 'streamname' }

      specify '#append_to_stream' do
        event = Event.new('event_type', {data: 1})
        expect(client).to receive(:make_request).with(:post, '/streams/streamname', {data: 1}, {'ES-EventType' => 'event_type', 'ES-EventId' => event.event_id})
        client.append_to_stream(stream_name, event)
        expect(client).to receive(:make_request).with(:post, '/streams/streamname', {data: 1}, {'ES-EventType' => 'event_type', 'ES-EventId' => event.event_id, 'ES-ExpectedVersion' => '1'})
        client.append_to_stream(stream_name, event, 1)
      end

      specify '#delete_stream' do
        expect(client).to receive(:make_request).with(:delete, '/streams/streamname', {}, {'ES-HardDelete' => 'false'})
        client.delete_stream(stream_name, false)
        expect(client).to receive(:make_request).with(:delete, '/streams/streamname', {}, {'ES-HardDelete' => 'true'})
        client.delete_stream(stream_name, true)
      end

      specify '#read_stream_backward' do
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/backward/20')
        client.read_stream_backward(stream_name, 0, 20)
      end

      specify '#read_stream_forward' do
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {})
        client.read_stream_forward(stream_name, 0, 20, 0)
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20', {}, {'ES-LongPoll' => '10'})
        client.read_stream_forward(stream_name, 0, 20, 10)
      end

      specify '#read_stream_page' do
        expect(client).to receive(:make_request).with(:get, '/streams/streamname/0/forward/20')
        client.read_stream_page('/streams/streamname/0/forward/20')
      end
    end
  end
end

