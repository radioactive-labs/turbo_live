// Import controllers here
import registerTurboLiveChannel from "./turbo_live_channel.js"

export default function (consumer) {
  // Register channels here
  registerTurboLiveChannel(consumer)
}
