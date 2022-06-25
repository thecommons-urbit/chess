import React from 'react'
import ReactDOM from 'react-dom'
import NewApp from './NewApp'

declare global {
  interface Window {
    ship: string
  }
}

ReactDOM.render(
  <React.StrictMode>
    <NewApp />
  </React.StrictMode>,
  document.getElementById('root')
)
