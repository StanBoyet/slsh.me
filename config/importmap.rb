# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Charts: all UMD side-effect imports so window.Chart / window.luxon are set
# before chartkick (gem asset) looks for them.
pin "Chart.bundle.min",      to: "https://cdn.jsdelivr.net/npm/chart.js@4/dist/chart.umd.min.js"
pin "luxon",                 to: "https://cdn.jsdelivr.net/npm/luxon@3/build/global/luxon.min.js"
pin "chartjs-adapter-luxon", to: "https://cdn.jsdelivr.net/npm/chartjs-adapter-luxon@1/dist/chartjs-adapter-luxon.umd.min.js"
pin "chartkick",             to: "chartkick.js"
