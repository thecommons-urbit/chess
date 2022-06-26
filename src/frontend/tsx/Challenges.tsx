import * as React from 'react'
import { ChessChallenge, ChessSide, Ship } from '../ts/types/chess'
import useChessStore from '../ts/stores/chessStore'

export function Challenges () {
  const { urbit, removeChallenge, receivedChallenges } = useChessStore()

  var [who, setWho] = React.useState('')
  var [event, setEvent] = React.useState('Casual Game')
  var [round, setRound] = React.useState('')
  var [side, setSide] = React.useState('random')

  const challengerKing = (side: ChessSide): string => {
    switch (side) {
      case ChessSide.White: {
        return '♔'
      }
      case ChessSide.Black: {
        return '♚'
      }
      case ChessSide.Random:
        return '⚂'
    }
  }

  const extractRound = (challenge: ChessChallenge) => {
    return challenge.round === '' ? '' : `: Round ${challenge.round}`
  }

  const acceptChallenge = async (who: Ship) => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: {
        'chess-action': 'accept-game',
        'who': who
      },
      onSuccess: () => { removeChallenge(who) }
    })
  }

  const declineChallenge = async (who: Ship) => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: {
        'chess-action': 'decline-game',
        'who': who
      },
      onSuccess: () => { removeChallenge(who) }
    })
  }

  const sendChallenge = async (who: Ship, side: string, event: string, round: string) => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: {
        'chess-action': 'challenge',
        'who': who,
        'challenger-side': side,
        'event': event,
        'round': round
      }
    })
  }

  return (
    <div className='challenges-container'>
      <h1>Challenges</h1>
      <div className='challenges-list'>
        <ul>
          {
            Array.from(receivedChallenges).map(([challenger, challenge]) => {
              return (
                <li key={challenger}>
                  {`Challenged by ${challengerKing(challenge.challengerSide)}${challenger}`}<br/>
                  {`${challenge.event}${extractRound(challenge)}`}<br/>
                  <div className='challenge-reply'>
                    <button onClick={() => acceptChallenge(challenger)}>Accept</button>
                    <button onClick={() => declineChallenge(challenger)}>Decline</button>
                  </div>
                </li>)
            })
          }
        </ul>
      </div>
      <div className='challenge-prompt'>
        Challenge a player:<br/>
        Player: <input
          name='who'
          placeholder={'~sampel-palnet'}
          onChange={(e) => setWho(e.target.value)}
        /><br/>
        Event: <input
          name='event'
          defaultValue={'Casual Game'}
          onChange={(e) => setEvent(e.target.value)}
        /><br/>
        Round: <input
          name='round'
          onChange={(e) => setRound(e.target.value)}
        /><br/>
        <div className='challenge-side'>
          <input
            name='side'
            value='white'
            type='radio'
            onChange={(e) => setSide(e.target.value)}
          /> ♔
          <input
            name='side'
            value='black'
            type='radio'
            onChange={(e) => setSide(e.target.value)}
          /> ♚
          <input
            name='side'
            value='random'
            defaultChecked={true}
            type='radio'
            onChange={(e) => setSide(e.target.value)}
          /> ⚂
        </div>
        <button onClick={() => sendChallenge(who, side, event, round)}>Challenge</button>
      </div>
    </div>
  )
}
