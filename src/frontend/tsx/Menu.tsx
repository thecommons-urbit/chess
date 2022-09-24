import React from 'react'
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs'
import { Challenges } from './Challenges'
import { Games } from './Games'
import { Settings } from './Settings'
import usePreferenceStore from '../ts/state/preferenceStore'

export function Menu () {
  const { pieceTheme, boardTheme, setPieceTheme, setBoardTheme } = usePreferenceStore()

  const initThemes = () => {
    let storedPieceTheme = localStorage.getItem('pieceTheme')
    let storedBoardTheme = localStorage.getItem('boardTheme')

    if (storedPieceTheme !== null) {
      setPieceTheme(storedPieceTheme)
    } else {
      localStorage.setItem('pieceTheme', pieceTheme)
    }

    if (storedBoardTheme !== null) {
      setBoardTheme(storedBoardTheme)
    } else {
      localStorage.setItem('boardTheme', boardTheme)
    }
  }

  React.useEffect(
    () => { initThemes() },
    [])

  return (
    <Tabs className='menu-container'>
      <TabList>
        <Tab>Games</Tab>
        <Tab>Challenges</Tab>
        <Tab>Settings</Tab>
      </TabList>

      <TabPanel>
        <Games />
      </TabPanel>
      <TabPanel>
        <Challenges />
      </TabPanel>
      <TabPanel>
        <Settings />
      </TabPanel>
    </Tabs>
  )
}
