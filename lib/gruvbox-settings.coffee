settings =
  config:
    brightness:
      type: 'string'
      default: 'Dark'
      enum: ["Dark", "Light"]
    contrast:
      type: 'string'
      default: 'Medium'
      enum: ["Hard", "Medium", "Soft"]

module.exports = settings
