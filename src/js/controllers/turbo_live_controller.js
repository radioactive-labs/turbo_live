import { Controller } from "@hotwired/stimulus"
import logger from "../logger.js"

export default class extends Controller {
  static values = {
    id: String,
    component: String,
  }
  static targets = ["meta"]

  get component() {
    return this.componentValue
  }

  metaTargetConnected(target) {
    logger.debug("TurboLiveController metaTargetConnected", this.element.id, target)
    this.application
      .getControllerForElementAndIdentifier(target, "turbo-live-meta-data")
      .setComponent(this)
  }

  dispatch(event, payload) {
    const data = { id: this.element.id, event, payload, component: this.component }
    logger.info("TurboLiveController dispatching", this.element.id, data)

    if (window.turboLive) {
      logger.debug("TurboLiveController dispatching via", this.element.id, "websockets")
      window.turboLive.send(data)
    } else {
      logger.debug("TurboLiveController dispatching via", this.element.id, "http")
      this.#dispatchHTTP(data)
    }
  }

  onClick(event) {
    logger.debug("TurboLiveController onClick", this.element.id, event)
    this.#dispatchSimpleEvent("click", event)
  }

  onChange(event) {
    logger.debug("TurboLiveController onChange", this.element.id, event)
    this.#dispatchValueEvent("change", event)
  }

  onInput(event) {
    logger.debug("TurboLiveController onInput", this.element.id, event)
    this.#dispatchValueEvent("input", event)
  }


  #dispatchSimpleEvent(name, { params }) {
    logger.debug("TurboLiveController dispatchSimpleEvent", this.element.id, name, params)
    const liveEvent = params[name]
    this.dispatch(name, [liveEvent])
  }

  #dispatchValueEvent(name, { params, target }) {
    logger.debug("TurboLiveController dispatchValueEvent", this.element.id, name, params)
    const value = target.value
    const liveEvent = params[name]
    this.dispatch(name, [liveEvent, value])
  }

  #dispatchHTTP(data) {
    fetch('/turbo_live', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    })
      .then(response => {
        if (!response.ok) {
          throw new Error(`Network response was not OK`)
        }
        return response.text()
      })
      .then(turboStream => {
        logger.info('TurboLiveController dispatch success', this.element.id, turboStream)
        if (turboStream) Turbo.renderStreamMessage(turboStream)
      })
      .catch((error) => {
        logger.error('TurboLiveController dispatch error', this.element.id, error)
      })
  }
}