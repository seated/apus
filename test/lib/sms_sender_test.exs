defmodule Apus.SmsSenderTest do
  use ExUnit.Case

  defmodule TestAdapter do
    def deliver(message, config) do
      send(:sender_test, {:deliver, message, config})
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

      assert_receive {:deliver, ^message, _}
    end

    test "deliver_now/1 should not deliver a message without a recipient" do
      message = %Apus.Message{
        from: "+15551234567",
        body: "Hello there"
      }

      TestSender.deliver_now(message)

      refute_receive {:deliver, ^message, _}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "",
        body: "Hello there"
      }

      TestSender.deliver_now(message)

      refute_receive {:deliver, ^message, _}, 20
    end

    test "deliver_now/1 should not deliver a message without a body" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321"
      }

      TestSender.deliver_now(message)

      refute_receive {:deliver, ^message, _}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: ""
      }

      TestSender.deliver_now(message)

      refute_receive {:deliver, ^message, _}, 20
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

      assert_receive {:deliver, ^message, _}
    end

    test "deliver_later/1 should not deliver a message without a recipient" do
      message = %Apus.Message{
        from: "+15551234567",
        body: "Hello there"
      }

      TestSender.deliver_later(message)

      refute_receive {:deliver, ^message, _}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "",
        body: "Hello there"
      }

      TestSender.deliver_later(message)

      refute_receive {:deliver, ^message, _}, 20
    end

    test "deliver_later/1 should not deliver a message without a body" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321"
      }

      TestSender.deliver_later(message)

      refute_receive {:deliver, ^message, _}, 20

      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: ""
      }

      TestSender.deliver_later(message)

      refute_receive {:deliver, ^message, _}, 20
    end
  end

  describe "delivery config" do
    test "sets the default deliver_later_strategy if none is set" do
      message = %Apus.Message{
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there"
      }

      TestSender.deliver_later(message)

      assert_receive {:deliver, _, config}
      assert config.deliver_later_strategy == Apus.TaskSupervisorStrategy
    end
  end
end
