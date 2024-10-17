import logger from "../logger.js"

export default function (consumer) {
  consumer.subscriptions.create({ channel: "TurboLive::ComponentsChannel" }, {
    // Called once when the subscription is created.
    initialized() {
      logger.debug("TurboLiveChannel initialized")
    },

    // Called when the subscription is ready for use on the server.
    connected() {
      logger.debug("TurboLiveChannel connected")
      window.turboLive = this;
    },

    received(turbo_stream) {
      logger.info("TurboLiveChannel received", turbo_stream)
      Turbo.renderStreamMessage(turbo_stream);
    },

    // Called when the WebSocket connection is closed.
    disconnected() {
      logger.debug("TurboLiveChannel disconnected")
      window.turboLive = null;
    },

    // Called when the subscription is rejected by the server.
    rejected() {
      logger.debug("TurboLiveChannel rejected")
      window.turboLive = null;
    },
  })
}
