import React from 'react'
import '../css/tabs.css'
import '../css/text.css'
import '../css/popups.css'
import '../css/buttons.css'
import '../css/general.css'
import '../css/graphics.css'
import '../css/textboxes.css'
import '../css/responsive.css'
import '../css/chessground.css'
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
