# TurboLive

TurboLive is a Ruby gem that enables the creation of async, progressively enhanced, live components for Ruby applications. It works seamlessly over both WebSockets and HTTPS, providing real-time interactivity with graceful degradation.

## Table of Contents

- [Installation](#installation)
- [Setup](#setup)
- [Usage](#usage)
  - [Creating a Component](#creating-a-component)
  - [Model State](#model-state)
  - [View](#view)
  - [Update](#update)
- [Events](#events)
  - [Manual Events](#manual-events)
  - [Timed Events](#timed-events)
- [Examples](#examples)
- [Performance Considerations](#performance-considerations)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [License](#license)

## Installation

Add it to your project with:

```console
bundle add 'turbo_live'
```

Or install it yourself using:

```console
gem install turbo_live
```

### JavaScript

TurboLive ships a JavaScript component that comes as an npm package. You can pin it with importmaps or install it as an npm package depending on your asset pipeline:

For importmaps:

```console
bin/importmap pin @radioactive-labs/turbo-live
```

For npm:

```console
npm install @radioactive-labs/turbo-live
```

## Setup

### Stimulus Controller

TurboLive uses a Stimulus controller to manage interactions. In your `app/javascript/controllers/index.js`:

```diff
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
+import * as turboLive from "@radioactive-labs/turbo-live"

eagerLoadControllersFrom("controllers", application)
+turboLive.registerControllers(application)
```

### ActionCable (Optional)

TurboLive supports WebSockets using ActionCable with automatic failover to HTTPS. If you have ActionCable set up and would like to benefit from better performance, you can set up the integration.

In `app/javascript/channels/index.js`:

```diff
+import consumer from "./consumer"
+import * as turboLive from "@radioactive-labs/turbo-live"
+
+turboLive.registerChannels(consumer)
```

Then in your `app/javascript/application.js`:

```diff
import "@hotwired/turbo-rails"
import "controllers"
+import "channels"
```

## Usage

A TurboLive component is a self-contained, interactive unit of a web application that can update in real-time without full page reloads. Components follow [The Elm Architecture](https://guide.elm-lang.org/architecture/) pattern.

### Creating a Component

To create a TurboLive component, inherit from `TurboLive::Component`:

```ruby
class MyComponent < TurboLive::Component
  # Component logic goes here
end
```

### Model State

Define state variables using the `state` method:

```ruby
class MyComponent < TurboLive::Component
  state :count, Integer do |value|
    value || 0
  end
end
```

> Note: State variables can only be primitive objects and basic collections.

### View

Define the component's HTML structure in the `view` method:

```ruby
def view
  div do
    button(**on(click: :increment)) { "+" }
    span { count }
    button(**on(click: :decrement)) { "-" }
  end
end
```

Components are [phlex](https://www.phlex.fun/) views, allowing you to write HTML in Ruby.

### Update

Handle events in the `update` method:

```ruby
def update(input)
  case input
  in [:increment]
    self.count += 1
  in [:decrement]
    self.count -= 1
  end
end
```

## Events

Events are transmitted to the server using the currently active transport (HTTP or WebSockets).

### Manual Events

Use the `on` method to set up manually triggered events:

```ruby
button(**on(click: :decrement)) { "-" }
```

You can also emit compound events that carry extra data:

```ruby
button(**on(click: [:change_value, 1])) { "+" }
```

> Note: Currently, only `:click` and `:change` events are supported.

### Timed Events

Use the `every` method to set up recurring events:

```ruby
def view
  div do
    h1 { countdown }
    every(1000, :tick) if countdown > 0
  end
end
```

## Examples

See the [/examples](/examples) folder in for detailed component examples including Counter, Countdown, Showcase and Tic-Tac-Toe components.

## Performance Considerations

- Use fine-grained components to minimize the amount of data transferred and rendered.
- Implement debouncing for frequently triggered events.
- Consider using background jobs for heavy computations to keep the UI responsive.

## Testing

TurboLive components can be tested using standard Rails testing tools. Here's a basic example:

```ruby
require "test_helper"

class CounterComponentTest < ActiveSupport::TestCase
  test "increments count" do
    component = CounterComponent.new
    assert_equal 0, component.count
    component.update([:increment])
    assert_equal 1, component.count
  end
end
```

## Troubleshooting

Common issues and their solutions:

1. **Component not updating**: Ensure that your `update` method is correctly handling the event and modifying the state.
2. **WebSocket connection failing**: Check your ActionCable configuration and ensure that your server supports WebSocket connections.
3. **JavaScript errors**: Make sure you've correctly set up the TurboLive JavaScript integration in your application.
3. **My timed events won't go away**: Due to the use of morphing, there might be instances where your some meta attributes are not removed.

For more issues, please check our [FAQ](https://github.com/radioactive-labs/turbo_live/wiki/FAQ) or open an issue on GitHub.

## Contributing

We welcome contributions to TurboLive! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more information on how to get started.

## Changelog

See the [CHANGELOG.md](CHANGELOG.md) file for details on each release.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).