defmodule Apus.SmsSenderTest do
  use ExUnit.Case

  defmodule TestAdapter do
    def deliver(%{body: "I fail"}, _) do
      {:error, "failure message"}
    end

    def deliver(message, _config) do
      send(:sender_test, {:ok, message})
    end

    def handle_config(config), do: config
  end

  defmodule TestSender do
    use Apus.SmsSender, otp_app: :apus
  end

  @adapter_config adapter: TestAdapter

  Application.put_env(:apus, __MODULE__.TestSender, @adapter_config)

  setup do
    Process.register(self(), :sender_test)
    :ok
  end

  describe "message delivery" do
    test "deliver_now/1 should return the message" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there"
      }

      assert ^message = TestSender.deliver_now(message)
    end

    test "deliver_now/1 should deliver the message" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there"
      }

      TestSender.deliver_now(message)

      assert_receive {:ok, ^message}
    end

    test "deliver_now/1 should not deliver a message without a recipient" do
      message = %Apus.Message{
        from: "+15551234567",
        body: "Hello there"
      }

      expected_error = {:error, {:to, "Cannot be nil or empty"}}

      result = TestSender.deliver_now(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "",
        body: "Hello there"
      }

      result = TestSender.deliver_now(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20
    end

    test "deliver_now/1 should not deliver a message without a body" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321"
      }

      expected_error = {:error, {:body, "Cannot be nil or empty"}}

      result = TestSender.deliver_now(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: ""
      }

      result = TestSender.deliver_now(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20
    end

    test "deliver_now/1 returns an error message when the adapter failed to send the message" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: "I fail"
      }

      assert {:error, "failure message"} = TestSender.deliver_now(message)
    end

    test "deliver_later/1 should return the message" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there"
      }

      assert ^message = TestSender.deliver_later(message)
    end

    test "deliver_later/1 should deliver the message" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there"
      }

      TestSender.deliver_later(message)

      assert_receive {:ok, ^message}
    end

    test "deliver_later/1 should not deliver a message without a recipient" do
      message = %Apus.Message{
        from: "+15551234567",
        body: "Hello there"
      }

      expected_error = {:error, {:to, "Cannot be nil or empty"}}

      result = TestSender.deliver_later(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "",
        body: "Hello there"
      }

      result = TestSender.deliver_later(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20
    end

    test "deliver_later/1 should not deliver a message without a body" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321"
      }

      expected_error = {:error, {:body, "Cannot be nil or empty"}}

      result = TestSender.deliver_later(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: ""
      }

      result = TestSender.deliver_later(message)

      assert result == expected_error
      refute_receive {:ok, ^message}, 20
    end
  end
end
