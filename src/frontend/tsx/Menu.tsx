import React from 'react'
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs'
import { Challenges } from './Challenges'
import { Games } from './Games'
import { Settings } from './Settings'

export function Menu () {
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
