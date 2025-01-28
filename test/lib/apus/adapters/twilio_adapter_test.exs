defmodule Apus.TwilioAdapterTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]

  alias Apus.Message
  alias Apus.TwilioAdapter

  describe "message delivery" do
    test "deliver/2 should deliver a message" do
      config = %{
        account_sid: "fake-account-sid",
        auth_token: "fake-auth-token"
      }

      message =
        Message.new(
          from: "+15551234567",
          to: "+15557654321",
          body: "Hello there",
          provider: nil,
          message_id: nil,
          tags: %{tag1: "value1", tag2: "value2"},
          status_callback: "https://valid_url.com"
        )

      use_cassette "twilio_sms_from_success", match_requests_on: [:request_body] do
        {:ok, %{} = tw_message} = TwilioAdapter.deliver(message, config)

        assert tw_message.from == "+15551234567"
        assert tw_message.to == "+15557654321"
        assert tw_message.body == "Hello there"
        assert tw_message.message_id == "SM123"
        assert tw_message.provider == "twilio"
        assert tw_message.tags == %{"tag1" => "value1", "tag2" => "value2"}
      end
    end

    test "deliver/2 passes request_options to hackney" do
      config = %{
        request_options: [recv_timeout: 0],
        account_sid: "fake-account-sid",
        auth_token: "fake-auth-token"
      }

      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      assert {:error, :timeout} == TwilioAdapter.deliver(message, config)
    end

    test "deliver/2 should deliver a message with the messaging service sid set" do
      config = %{
        account_sid: "fake-account-sid",
        auth_token: "fake-auth-token",
        messaging_service_sid: "fake-mssid"
      }

      message = Message.new(to: "+15557654321", body: "Hello there")

      use_cassette "twilio_sms_mssid_success", match_requests_on: [:request_body] do
        {:ok, %{} = tw_message} = TwilioAdapter.deliver(message, config)

        assert tw_message.from == nil
        assert tw_message.to == "+15557654321"
        assert tw_message.body == "Hello there"
      end
    end

    test "deliver/2 should override messaging service sid if from is set" do
      config = %{
        account_sid: "fake-account-sid",
        auth_token: "fake-auth-token",
        messaging_service_sid: "fake-mssid"
      }

      message =
        Message.new(
          from: "+15551234567",
          to: "+15557654321",
          body: "Hello there",
          tags: %{tag1: "value1", tag2: "value2"},
          status_callback: "https://valid_url.com"
        )

      use_cassette "twilio_sms_from_success", match_requests_on: [:request_body] do
        {:ok, %{} = tw_message} = TwilioAdapter.deliver(message, config)

        assert tw_message.from == "+15551234567"
        assert tw_message.to == "+15557654321"
        assert tw_message.body == "Hello there"
      end
    end

    test "deliver/2 should deliver a whatsapp message with a content sid and content variables" do
      config = %{
        account_sid: "fake-account-sid",
        auth_token: "fake-auth-token",
        messaging_service_sid: "fake-mssid"
      }

      message =
        Message.new(
          to: "whatsapp:+445557654321",
          content_sid: "fake-content-sid",
          content_variables: %{"1" => "1234"}
        )

      use_cassette "twilio_whatsapp_message_success", match_requests_on: [:request_body] do
        {:ok, %{} = tw_message} = TwilioAdapter.deliver(message, config)
        assert tw_message.to == "whatsapp:+445557654321"
      end
    end

    test "deliver/2 should return the twilio error message" do
      config = %{
        account_sid: "fake-account-sid",
        auth_token: "fake-auth-token"
      }

      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      use_cassette "twilio_sms_failure", match_requests_on: [:request_body] do
        {:error, message} = TwilioAdapter.deliver(message, config)

        assert message == "Some server error occurred"
      end
    end
  end
end
