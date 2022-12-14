defmodule Apus.LocalAdapterTest do
  use ExUnit.Case

  alias Apus.Message
  alias Apus.LocalAdapter
  alias Apus.SentMessages

  describe "message delivery" do
    test "deliver/2 should deliver a message" do
      message = Message.new(from: "+15551234567", to: "+15557654321", body: "Hello there")

      LocalAdapter.deliver(message, %{})

      assert SentMessages.all() == [{:ok, message}]
    end
  end

  describe "adapter config" do
    test "handle_config/1 should pass through the provided config" do
      config = %{key: "value"}

      assert LocalAdapter.handle_config(config) == config
    end
  end
end
