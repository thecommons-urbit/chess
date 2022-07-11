import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'

declare global {
  interface Window {
    ship: string
  }
}

const root = createRoot(document.getElementById('root'))
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
