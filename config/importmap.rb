# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "easymde", to: "https://ga.jspm.io/npm:easymde@2.16.1/src/js/easymde.js"
pin "codemirror", to: "https://ga.jspm.io/npm:codemirror@5.65.3/lib/codemirror.js"
pin "codemirror-spell-checker", to: "https://ga.jspm.io/npm:codemirror-spell-checker@1.1.2/src/js/spell-checker.js"
pin "codemirror/addon/display/autorefresh.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/display/autorefresh.js"
pin "codemirror/addon/display/fullscreen.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/display/fullscreen.js"
pin "codemirror/addon/display/placeholder.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/display/placeholder.js"
pin "codemirror/addon/edit/continuelist.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/edit/continuelist.js"
pin "codemirror/addon/mode/overlay.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/mode/overlay.js"
pin "codemirror/addon/search/searchcursor.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/search/searchcursor.js"
pin "codemirror/addon/selection/mark-selection.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/addon/selection/mark-selection.js"
pin "codemirror/mode/gfm/gfm.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/mode/gfm/gfm.js"
pin "codemirror/mode/markdown/markdown.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/mode/markdown/markdown.js"
pin "codemirror/mode/xml/xml.js", to: "https://ga.jspm.io/npm:codemirror@5.65.3/mode/xml/xml.js"
pin "fs", to: "https://ga.jspm.io/npm:@jspm/core@2.0.0-beta.24/nodelibs/browser/fs.js"
pin "marked", to: "https://ga.jspm.io/npm:marked@4.0.15/lib/marked.cjs"
pin "typo-js", to: "https://ga.jspm.io/npm:typo-js@1.2.1/typo.js"

pin_all_from 'app/javascript/custom', under: 'custom'