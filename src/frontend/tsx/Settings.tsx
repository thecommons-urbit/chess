import React from 'react'

export function Settings () {
  return (
    <div className='settings-container'>
      <div id="visuals-settings" className="control-panel-container col">
        <h4 className="control-panel-header">Visuals</h4>
      </div>
      <div id="gameplay-settings" className="control-panel-container col">
        <h4 className="control-panel-header">Gameplay</h4>
      </div>
      <div id="data-settings" className="control-panel-container col">
        <h4 className="control-panel-header">Data</h4>
        <button>Export PGN</button>
      </div>
      <div id="settings-footer" className="control-panel-container col">
        <p><a href="">Credits</a> • <a href="https://github.com/ashelkovnykov/urbit-chess">GitHub</a></p>
      </div>
    </div>
  )
}
