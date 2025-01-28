# Apus

Apus is an Elixir library enabling a flexible and testable approach to sending SMS messages.

## Installation

You can install apus by adding it to your list of dependencies in `mix.exs` and running `mix deps.get`.

```elixir
def deps do
  [
    {:apus, "~> 0.14.0"}
  ]
end
```

## Getting Started

To get started using apus you must first setup a module that will handle sending sms messages.

```elixir
defmodule MyApp.SmsSender do
  use Apus.SmsSender, otp_app: :my_app
end
```

Once the `SmsSender` module has been created it can be configured to use an adapter in your `config/config.exs` file.

```elixir
config :my_app, MyApp.SmsSender,
  adapter: Apus.TwilioAdapter,
  account_sid: "<twilio account sid>",
  auth_token: "<twilio auth token>"
```

Now we can send sms messages like so.

```elixir
message = %Apus.Message{
  to: "+15551234567",
  from: "+15557654321",
  body: "Hello there!"
}

# to deliver a message synchronously
MyApp.SmsSender.deliver_now(message)

# to deliver in the background
MyApp.SmsSender.deliver_later(message)
```

## Working in development mode

When working in development we don't always want to send real SMS messages but we do want
to see that they have been correctly sent through apus. To solve this, apus offers an in-memory
adapter that can be configured in your `config/dev.exs` file.

```elixir
config :my_app, MyApp.SmsSender, adapter: Apus.LocalAdapter
```

You will now see the sent messages being printed to the current terminal session as they are delivered.

## Sent messages viewer

Apus comes with a built-in web interface for viewing sent messages via a `plug`. This interface works
directly with the `Apus.LocalAdapter` which must be configured before using the sent messages viewer.

Using with Plug

```elixir
defmodule MyApp.Router do
  use Plug.Router

  if Mix.env == :dev do
    forward("/sent_messages", to: Apus.SentMessagesViewerPlug)
  end
end
```

Using with Phoenix

```elixir
defmodule MyApp.Router do
  use Phoenix.Router

  if Mix.env == :dev do
    forward("/sent_messages", Apus.SentMessagesViewerPlug)
  end
end
```

## Testing

Apus comes with an `Apus.TestAdapter` and some handy macros to make testing SMS delivery straightforward.

Setup the test adapter in the `config/test.exs` file.

```elixir
config :my_app, MyApp.SmsSender, adapter: Apus.TestAdapter
```

Now you can test SMS delivery using the `assert_delivered_message` macro.

### Assertions

For full match use the following example:

```elixir
defmodule MyApp.RegistrationTest do
  use ExUnit.Case

  import Apus.Test
  alias Apus.Message

  test "the user gets a message after registration" do
    new_user = user

    Users.register(new_user)

    assert_delivered_message %Message{
      to: new_user.phone_number,
      body: "Welcome there!"
    }
  end
end
```

If you only care that any message was delivered, you can use following assertion:

```elixir
test "message gets delivered" do
  new_user = user

  Users.register(new_user)

  message = assert_delivered_message()
  # do something with the delivered message...
end
```

Lastly anonymous function matcher is also provided for more flexible assertions:

```elixir
test "some delivered message attrs match" do
  new_user = user

  Users.register(new_user)

  assert_delivered_message_matches(fn message ->
    assert message.to == new_user.phone_number
    assert message.body =~ "partial match..."
  end)
end
```

### Refute

There is also a `refute_delivered_message/1` macro for testing that a specific message was not delivered.

```elixir
  test "specific message doesn't get delivered" do
    # Do something...

    # assert that following message wasn't sent out
    message = %Apus.Message(to: 123, body: "message")
    refute_delivered_message(message)
  end
```

Similarly you can also use `refute_delivered_message/0` to ensure no messages were delivered.

```elixir
  test "no messages delivered" do
    # Do something....

    # assert no messages were sent out
    refute_delivered_message()
  end
```
