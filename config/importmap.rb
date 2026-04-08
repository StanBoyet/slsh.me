# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Charts: UMD side-effect imports (set window.Chart, then register date adapter)
# chartjs-adapter-date-fns.bundle includes date-fns — no extra peer dep needed
pin "Chart.bundle.min",             to: "https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"
pin "chartjs-adapter-date-fns",     to: "https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3/dist/chartjs-adapter-date-fns.bundle.min.js"
pin "chartkick",                    to: "chartkick.js"
