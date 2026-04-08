# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Chartkick: pin the gem's own chartkick.js (uses global Chart) +
# Chart.js UMD as a side-effect import that sets window.Chart
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle.min", to: "https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"
