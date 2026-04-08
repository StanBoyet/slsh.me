import "@hotwired/turbo-rails"
import "controllers"

// Load in dependency order: Chart.js → Luxon → date adapter → Chartkick
// All UMD bundles; they set window.Chart / window.luxon as side effects
import "Chart.bundle.min"
import "luxon"
import "chartjs-adapter-luxon"
import "chartkick"
