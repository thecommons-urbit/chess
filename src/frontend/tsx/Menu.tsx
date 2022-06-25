import * as React from 'react'
import { Challenges } from './Challenges'
import { Games } from './Games'

export function Menu () {
  return (
    <div className='menu-container'>
      <Games />
      <Challenges />
    </div>
  )
}
