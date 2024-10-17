import { Controller } from "@hotwired/stimulus"
import { logger } from "../logger.js"

export default class extends Controller {
  static values = {
    type: String,
    data: String,
  }

  connect() {
    logger.debug("TurboLiveMetaDataController connected", this.typeValue, this.dataValue)
    this.#setup(this.typeValue, this.dataValue)
  }

  disconnect() {
    logger.debug("TurboLiveMetaDataController disconnected", this.typeValue, this.dataValue)
    this.#teardown()
    this.component = null
  }

  beforeMorph({ detail: { currentElement, newElement } }) {
    logger.debug("TurboLiveMetaDataController beforeMorph", this.typeValue, this.dataValue)
    if (currentElement.dataset.turboLiveMetaType != newElement.dataset.turboLiveMetaType ||
      currentElement.dataset.turboLiveMetaValue != newElement.dataset.turboLiveMetaValue) {
      logger.info("TurboLiveMetaDataController changed",
        this.typeValue, this.dataValue,
        newElement.dataset.turboLiveMetaDataTypeValue, newElement.dataset.turboLiveMetaDataDataValue)

      this.changedDuringMorph = true
      // teardown here since we still have our current state
      this.#teardown()
    }
  }

  afterMorph() {
    logger.debug("TurboLiveMetaDataController afterMorph", this.typeValue, this.dataValue)
    if (this.changedDuringMorph) {
      this.#setup(this.typeValue, this.dataValue)
      this.changedDuringMorph = false
    }
  }

  setComponent(component) {
    logger.debug("TurboLiveMetaDataController setComponent", this.typeValue, this.dataValue, component)
    this.component = component
  }

  #setup(type, data) {
    logger.debug("TurboLiveMetaDataController #setup", this.typeValue, this.dataValue, type, data)
    if (type === "interval") {
      this.#setupInterval(JSON.parse(data))
    }
  }

  #teardown() {
    logger.debug("TurboLiveMetaDataController #teardown", this.typeValue, this.dataValue)
    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }
  }

  #setupInterval(config) {
    logger.debug("TurboLiveMetaDataController #setupInterval", this.typeValue, this.dataValue, config)
    this.interval = setInterval(() => {
      this.component.dispatch("interval", [config.event])
    }, config.interval)
  }
}