import React from 'react'
import { Tab, Tabs, TabList, TabPanel } from 'react-tabs'
import { Challenges } from './Challenges'
import { Games } from './Games'

export function Menu () {
  return (
    <Tabs className='menu-container'>
      <TabList>
        <Tab>games</Tab>
        <Tab>challenges</Tab>
      </TabList>

      <TabPanel>
        <Games />
      </TabPanel>
      <TabPanel>
        <Challenges />
      </TabPanel>
    </Tabs>
  )
}
