import "@hotwired/turbo-rails"
import "controllers"

// Chart.js UMD sets window.Chart, then the bundled date adapter registers
// itself against it — no separate date-fns/luxon import needed
import "Chart.bundle.min"
import "chartjs-adapter-date-fns"
import "chartkick"
