const { resolve } = require("path")
const rootJavascriptPath = "app/javascript"

module.exports = {
  resolve: {
    alias: {
      Images: resolve(rootJavascriptPath, "images"),
      Helpers: resolve(rootJavascriptPath, "helpers"),
      Vendors: resolve(rootJavascriptPath, "vendors"),
    },
  },
}
