import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: String,
    component: String,
  }
  static targets = ["meta"]

  get component() {
    return this.componentValue
  }

  initialize() {
    this.metaTargetsMap = new WeakMap()
    this.metaTargetsCount = 0
    this.intervals = {}
  }

  connect() {
    console.log("TurboLiveController connected", this.element.id, this.component)
  }

  metaTargetConnected(target) {
    console.log("TurboLiveController metaTargetConnected", this.element.id, this.#metaTargetId(target))
    this.#readMetadata(target)
  }

  metaTargetDisconnected(target) {
    console.log("TurboLiveController metaTargetDisconnected", this.element.id, this.#metaTargetId(target))
    this.#teardownInterval(this.#metaTargetId(target))
  }

  disconnect() {
    console.log("TurboLiveController disconnected", this.element.id)
    this.#cleanup()
  }

  dispatch(event, payload) {
    console.log("TurboLiveController dispatch", this.element.id, event, payload)
    const data = { id: this.element.id, event, payload, component: this.component }

    if (window.turboLive) {
      console.log("TurboLiveController dispatching via websockets", this.element.id)
      window.turboLive.send(data)
    } else {
      console.log("TurboLiveController dispatching via HTTP", this.element.id)
      this.#dispatchHTTP(data)
    }
  }

  onClick(event) {
    console.log("TurboLiveController onClick", this.element.id)
    this.#dispatchSimpleEvent("click", event)
  }

  onChange(event) {
    console.log("TurboLiveController onChange", this.element.id)
    this.#dispatchValueEvent("change", event)
  }

  onInput(event) {
    console.log("TurboLiveController onInput", this.element.id)
    this.#dispatchValueEvent("input", event)
  }

  #metaTargetId(target) {
    if (!this.metaTargetsMap.has(target)) {
      this.metaTargetsMap.set(target, ++this.metaTargetsCount)
    }
    return this.metaTargetsMap.get(target)
  }

  #readMetadata(element) {
    const type = element.dataset.turboLiveMetaType
    if (type === "interval") {
      this.#setupInterval(element)
    }
  }

  #setupInterval(element) {
    try {
      const config = JSON.parse(element.dataset.turboLiveMetaValue)
      this.intervals[this.#metaTargetId(element)] = setInterval(() => {
        this.dispatch("interval", [config.event])
      }, config.interval)
    } catch (e) {
      console.error(e)
    }
  }

  #teardownInterval(id) {
    if (this.intervals[id]) {
      clearInterval(this.intervals[id])
      delete this.intervals[id]
    }
  }

  #cleanup() {
    Object.keys(this.intervals).forEach(this.#teardownInterval.bind(this))
  }

  #dispatchSimpleEvent(name, { params }) {
    const liveEvent = params[name]
    this.dispatch(name, [liveEvent])
  }

  #dispatchValueEvent(name, { params, target }) {
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
        console.log('TurboLiveController dispatch success', this.element.id, turboStream)
        if (turboStream) Turbo.renderStreamMessage(turboStream)
      })
      .catch((error) => {
        console.error('TurboLiveController dispatch error', this.element.id, error)
      })
  }
}