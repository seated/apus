defmodule Apus.MessageTest do
  use ExUnit.Case

  alias Apus.Message

  describe "message" do
    test "new/0 should return a Message struct with default values" do
      assert Message.new() == %Message{
               from: nil,
               to: nil,
               body: nil,
               provider: nil,
               message_id: nil,
               status_callback: nil
             }
    end

    test "new/1 should return a Message struct with provided values" do
      attrs = [from: "+15551234567", to: "+15557654321", body: "Hello there"]

      assert Message.new(attrs) == %Message{
               from: "+15551234567",
               to: "+15557654321",
               body: "Hello there",
               provider: nil,
               message_id: nil
             }
    end

    test "new/1 should return a Message struct with a status_callback when it's provided" do
      attrs = [
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there",
        status_callback: "https://valid_url.com"
      ]

      assert Message.new(attrs) == %Message{
               from: "+15551234567",
               to: "+15557654321",
               body: "Hello there",
               provider: nil,
               message_id: nil,
               status_callback: "https://valid_url.com"
             }
    end

    test "new/1 should return a Message struct with tags when they're provided" do
      attrs = [
        from: "+15551234567",
        to: "+15557654321",
        body: "Hello there",
        tags: %{tag1: "value1", tag2: "value2"}
      ]

      assert Message.new(attrs) == %Message{
               from: "+15551234567",
               to: "+15557654321",
               body: "Hello there",
               provider: nil,
               message_id: nil,
               tags: %{tag1: "value1", tag2: "value2"},
             }
    end
  end
end
