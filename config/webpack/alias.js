const { resolve } = require("path")
const rootJavascriptPath = config.source_path

module.exports = {
  resolve: {
    alias: {
      Helpers: resolve(rootJavascriptPath, "helpers"),
      Vendors: resolve(rootJavascriptPath, "vendors"),
    },
  },
}
