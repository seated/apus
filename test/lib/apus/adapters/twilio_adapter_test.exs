defmodule Apus.TwilioAdapterTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]

  alias Apus.Message
  alias Apus.TwilioAdapter

  describe "message delivery" do
    test "deliver/2 should deliver a message" do
      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      use_cassette "twilio_sms_from_success", match_requests_on: [:request_body] do
        {:ok, %ExTwilio.Message{} = tw_message} = TwilioAdapter.deliver(message, %{})

        assert tw_message.from == "+15551234567"
        assert tw_message.to == "+15557654321"
        assert tw_message.body == "Hello there"
      end
    end

    test "deliver/2 should deliver a message with the messaging service sid set" do
      config = %{
        messaging_service_sid: "fake-mssid"
      }

      message = Message.new(to: "+15557654321", body: "Hello there")

      use_cassette "twilio_sms_mssid_success", match_requests_on: [:request_body] do
        {:ok, %ExTwilio.Message{} = tw_message} = TwilioAdapter.deliver(message, config)

        assert tw_message.from == nil
        assert tw_message.to == "+15557654321"
        assert tw_message.body == "Hello there"
      end
    end

    test "deliver/2 should override messaging service sid if from is set" do
      config = %{
        messaging_service_sid: "fake-mssid"
      }

      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      use_cassette "twilio_sms_from_success", match_requests_on: [:request_body] do
        {:ok, %ExTwilio.Message{} = tw_message} = TwilioAdapter.deliver(message, config)

        assert tw_message.from == "+15551234567"
        assert tw_message.to == "+15557654321"
        assert tw_message.body == "Hello there"
      end
    end
  end
end
