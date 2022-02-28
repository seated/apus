defmodule Apus.PlivoAdapterTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]

  alias Apus.Message
  alias Apus.PlivoAdapter

  describe "message delivery" do
    test "deliver/2 should deliver a message" do
      config = %{
        auth_id: "fake-auth-id",
        auth_token: "fake-auth-token"
      }

      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      use_cassette "plivo_sms_from_success", match_requests_on: [:request_body] do
        {:ok, %Apus.Message{} = pl_message} = PlivoAdapter.deliver(message, config)

        assert pl_message.from == "+15551234567"
        assert pl_message.to == "+15557654321"
        assert pl_message.body == "Hello there"
      end
    end

    test "deliver/2 passes request_options to hackney" do
      config = %{
        request_options: [recv_timeout: 0],
        auth_id: "fake-auth-id",
        auth_token: "fake-auth-token"
      }

      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      assert {:error, :timeout} == PlivoAdapter.deliver(message, config)
    end

    test "deliver/2 should return the plivo error message" do
      config = %{
        auth_id: "fake-auth-id",
        auth_token: "fake-auth-token"
      }

      message = Message.new(from: "+15551234568", to: "+15557654321", body: "Hello there")

      use_cassette "plivo_sms_failure", match_requests_on: [:request_body] do
        {:error, message} = PlivoAdapter.deliver(message, config)

        assert message == "Some server error occurred"
      end
    end
  end
end
