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
import LichessPgnViewer from 'lichess-pgn-viewer'

declare global {
  interface Window {
    ship: string
  }
}

LichessPgnViewer(document.getElementById('pgn'), {
  pgn: 'e4 c5 Nf3 d6 e5 Nc6 exd6 Qxd6 Nc3 Nf6'
})

const root = createRoot(document.getElementById('root'))
root.render(
  <App />
)
