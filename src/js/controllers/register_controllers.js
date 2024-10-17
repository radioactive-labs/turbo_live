// Import controllers here
import TurboLiveController from "./turbo_live_controller.js"
import TurboLiveMetaDataController from "./turbo_live_meta_data_controller.js"

export default function (application) {
  // Register controllers here
  application.register("turbo-live", TurboLiveController)
  application.register("turbo-live-meta-data", TurboLiveMetaDataController)
}
