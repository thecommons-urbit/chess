import React from 'react'
import '../css/tabs.css'
import '../css/buttons.css'
import '../css/general.css'
import '../css/textboxes.css'
import '../css/chessground.css'
// Import Chessground style sheets
import '../css/dependencies/chessground.base.css'
// Handles piece highlighting
import '../css/dependencies/chessground.highlight.css'
import { createRoot } from 'react-dom/client'
import App from './App'

declare global {
  interface Window {
    ship: string
  }
}

const root = createRoot(document.getElementById('root'))
root.render(
  <App />
)
