defmodule Apus.TwilioAdapterTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]

  alias Apus.Message
  alias Apus.CiscoAdapter

  describe "message delivery" do
    test "deliver/2 should deliver a message" do
      config = %{
       service_key: "fake_service_key"
      }

      message =
        Message.new(
          from: "88979",
          to: "+15557654321",
          body: "Hello there",
          provider: nil,
          message_id: nil
        )

      use_cassette "cisco_sms_success", match_requests_on: [:request_body] do
        {:ok, %{} = cisco_message} = CiscoAdapter.deliver(message, config)

        assert cisco_message.from == "88979"
        assert cisco_message.to == "+15557654321"
        assert cisco_message.body == "Hello there"
        assert cisco_message.message_id == "fake_message_id"
        assert cisco_message.provider == "cisco"
      end
    end

    test "deliver/2 should return the cisco error message when the body is invalid" do
      config = %{
        service_key: "fake_service_key"
      }

      message = Message.new(from: "88979", to: "123", body: "Hello there")

      use_cassette "cisco_sms_failure", match_requests_on: [:request_body] do
        {:error, message} = CiscoAdapter.deliver(message, config)

        assert message == "Number not in +E164 format"
      end
    end

    test "deliver/2 should return a 401 when the service key is invalid" do
      config = %{
        service_key: "invalid_service_key"
      }

      message = Message.new(from: "88979", to: "15557654321", body: "Hello there")

      use_cassette "cisco_sms_invalid_service_key_failure", match_requests_on: [:request_body] do
        error = CiscoAdapter.deliver(message, config)

        assert error == {:error, "Unauthorized"}
      end
    end
  end
end
