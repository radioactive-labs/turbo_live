import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    id: String,
    component: String,
  }

  get component() {
    return this.componentValue
  }

  connect() {
    console.log("TurboLiveController connected:", this.element.id, this.component)

    this.intervals = []

    this.#readEmbeddedData()
  }

  disconnect() {
    console.log("TurboLiveController disconnected")
    this.#clearIntervals()
  }

  dispatch(event, payload) {
    console.log("TurboLiveController dispatch:", this.element.id, event, payload)
    let data = { id: this.element.id, event: event, payload: payload, component: this.component }
    if (window.turboLive) {
      console.log("TurboLiveController dispatching via websockets")
      window.turboLive.send(data)
    }
    else {
      console.log("TurboLiveController dispatching via HTTP")

      fetch('/turbo_live', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
      })
        .then(response => {
          if (!response.ok) {
            throw new Error(`Network response was not OK`);
          }
          return response.text();
        })
        .then(turbo_stream => {
          console.log('TurboLiveController dispatch success:', turbo_stream);
          Turbo.renderStreamMessage(turbo_stream);
        })
        .catch((error) => {
          console.error('TurboLiveController dispatch error:', error);
        });
    }
  }

  onClick(event) {
    // event.preventDefault();
    console.log("TurboLiveController onClick")
    this.#dispatchSimpleEvent("click", event)
  }

  onChange(event) {
    // event.preventDefault();
    console.log("TurboLiveController onChange")
    this.#dispatchValueEvent("change", event)
  }

  #readEmbeddedData() {
    this.element.querySelectorAll(".turbo-live-data").forEach((element) => {
      if (this.element.id != element.dataset.turboLiveId) return;

      let type = element.dataset.turboLiveDataType
      let value = JSON.parse(element.dataset.turboLiveDataValue)
      switch (type) {
        case "every":
          this.#setupInterval(value)
          break;
      }
    })
  }

  #setupInterval(intervalConfig) {
    try {
      for (let interval in intervalConfig) {
        this.intervals.push(
          setInterval(() => {
            this.dispatch("every", [intervalConfig[interval]])
          }, interval)
        )
      }
    }
    catch (e) {
      console.error(e)
    }
  }

  #clearIntervals() {
    this.intervals.forEach((interval) => {
      clearInterval(interval)
    })
  }

  #dispatchSimpleEvent(name, { params }) {
    let live_event = params[name]
    this.dispatch(name, [live_event])
  }

  #dispatchValueEvent(name, { params, target }) {
    let value = target.value
    let live_event = params[name]
    this.dispatch(name, [live_event, value])
  }
}
