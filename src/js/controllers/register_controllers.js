// Import controllers here
import TurboLiveController from "./turbo_live_controller.js"

export default function (application) {
  // Register controllers here
  application.register("turbo-live", TurboLiveController)
}
