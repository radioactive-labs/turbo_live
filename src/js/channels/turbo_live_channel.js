export default function (consumer) {
  consumer.subscriptions.create({ channel: "TurboLive::ComponentsChannel" }, {
    // Called once when the subscription is created.
    initialized() {
      console.log("TurboLiveChannel initialized")
    },

    // Called when the subscription is ready for use on the server.
    connected() {
      console.log("TurboLiveChannel connected")
      window.turboLive = this;
    },

    received(turbo_stream) {
      console.log("TurboLiveChannel received", turbo_stream)
      Turbo.renderStreamMessage(turbo_stream);
    },

    // Called when the WebSocket connection is closed.
    disconnected() {
      console.log("TurboLiveChannel disconnected")
      window.turboLive = null;
    },

    // Called when the subscription is rejected by the server.
    rejected() {
      console.log("TurboLiveChannel rejected")
      window.turboLive = null;
    },
  })
}
