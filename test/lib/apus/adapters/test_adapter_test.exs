defmodule Apus.TestAdapterTest do
  use ExUnit.Case

  alias Apus.Message
  alias Apus.TestAdapter

  describe "message delivery" do
    test "deliver/2 should deliver a message" do
      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      {:ok, %Apus.Message{}} = TestAdapter.deliver(message, %{})

      assert_received {:delivered_message, ^message}
    end

    test "deliver/2 should support testing invalid to number" do
      message = Message.new(from: "+15551234567", to: "invalid number", body: "Hello there")

      result = TestAdapter.deliver(message, %{})

      assert result == {:error, "invalid number"}
      refute_receive {:delivered_message, ^message}, 20
    end

    test "deliver/2 should support testing invalid from number" do
      message = Message.new(from: "invalid number", to: "+15557654321", body: "Hello there")

      result = TestAdapter.deliver(message, %{})

      assert result == {:error, "invalid number"}
      refute_receive {:delivered_message, ^message}, 20
    end
  end

  describe "adapter config" do
    test "handle_config/1 should use the ImmediateDeliveryStrategy by default" do
      config = TestAdapter.handle_config(%{})

      assert config.deliver_later_strategy == Apus.ImmediateDeliveryStrategy
    end

    test "handle_config/1 should enforce the use of ImmediateDeliveryStrategy" do
      config = %{deliver_later_strategy: Apus.TaskSupervisorStrategy}

      assert_raise ArgumentError, fn ->
        TestAdapter.handle_config(config)
      end
    end
  end
end
