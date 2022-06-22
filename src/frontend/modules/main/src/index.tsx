import React from 'react'
import ReactDOM from 'react-dom'
import App from './tsx/App'

declare global {
  interface Window {
    ship: string
  }
}

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
)
