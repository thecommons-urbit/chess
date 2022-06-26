import * as React from 'react'
import { useNavigate } from 'react-router-dom'
import Chessboard from 'chessboardjsx'
import { ChessActiveGameInfo, ChessGameID, ChessPositionFEN, ChessSide } from '../ts/types/chess'
import useChessStore from '../ts/stores/chessStore'

type BoardProps = {
  gameId: ChessGameID
}

type ChessRank = '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8'
type ChessFile = 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'g' | 'h'
type ChessPromotion = '' | 'knight' | 'bishop' | 'rook' | 'queen'

type NormalMove = {
  'from-file': ChessFile
  'from-rank': ChessRank
  'to-file': ChessFile
  'to-rank': ChessRank
  'into': ChessPromotion
}

interface ChessMoveAction {
  'chess-action': 'move',
  'game-id': ChessGameID,
  'chess-move': 'move' | 'castle' | 'end'
}

enum CastleSide {
  Kingside = 'kingside',
  Queenside = 'queenside',
  None = ''
}

type CastleMove = {
  'castle-side': CastleSide.Kingside | CastleSide.Queenside
}

type EndMove = {
  'result': '1-0' | '0-1' | '½–½'
}

interface NormalChessMove extends NormalMove, ChessMoveAction {
  'chess-move': 'move'
}

interface CastleChessMove extends CastleMove, ChessMoveAction {
  'chess-move': 'castle'
}

interface EndChessMove extends EndMove, ChessMoveAction {
  'chess-move': 'end'
}

type BoardMove = {
  sourceSquare: string,
  targetSquare: string,
  piece: string
}

function renderActiveGame (activeGame: ChessActiveGameInfo) {
  const { urbit, declineDraw, offerDraw } = useChessStore()
  const navigate = useNavigate()
  var [promotion, setPromotion] = React.useState('')
  var [undo, setUndo] = React.useState(false)

  const gameId = activeGame.info.gameID
  const side: ChessSide = (urbit.ship === activeGame.info.white.substring(1)) ? ChessSide.White : ChessSide.Black

  const darkSquareStyle = { backgroundColor: 'rgb(68, 68, 68)' }
  const lightSquareStyle = { backgroundColor: 'rgb(238, 238, 238)' }

  const pokeMove = (move: ChessMoveAction) => {
    move['chess-action'] = 'move'

    urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: move,
      onError: () => { setUndo(true) }
    })
  }

  const castleSide = (isKing: boolean, isStartPos: boolean, isTargetQueenFar: boolean, isTargetKingFar: boolean) => {
    if (isKing && isStartPos) {
      if (isTargetQueenFar) {
        return CastleSide.Queenside
      } else if (isTargetKingFar) {
        return CastleSide.Kingside
      }
    }

    return CastleSide.None
  }

  const makeMove = ({ sourceSquare, targetSquare, piece }: BoardMove, promotion: ChessPromotion) => {
    var move: ChessMoveAction
    const castle: CastleSide = castleSide(
      piece[1] === 'K',
      (sourceSquare === 'e1' || sourceSquare === 'e8'),
      (targetSquare === 'a1' || targetSquare === 'a8'),
      (targetSquare === 'h1' || targetSquare === 'h8'))

    switch (castle) {
      case CastleSide.Kingside: {
        move = ({
          'chess-move': 'castle',
          'castle-side': 'kingside'
        } as CastleChessMove)

        break
      }
      case CastleSide.Queenside: {
        move = ({
          'chess-move': 'castle',
          'castle-side': 'queenside'
        } as CastleChessMove)

        break
      }
      case CastleSide.None: {
        move = ({
          'chess-move': 'move',
          'from-file': sourceSquare[0],
          'from-rank': sourceSquare[1],
          'to-file': targetSquare[0],
          'to-rank': targetSquare[1],
          'into': promotion
        } as NormalChessMove)

        break
      }
    }

    move['game-id'] = gameId

    pokeMove(move)
  }

  const makeMoveWithExtra = (promotion: ChessPromotion) => {
    if (undo) {
      setUndo(false)
    }

    return (boardMove: BoardMove) => makeMove(boardMove, promotion)
  }

  const resignGame = async () => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: ({
        'game-id': gameId,
        'chess-action': 'move',
        'chess-move': 'end',
        'result': side === ChessSide.White ? '0-1' : '1-0'
      } as EndChessMove)
    })
  }

  const offer = async () => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: {
        'chess-action': 'offer-draw',
        'game-id': gameId
      },
      onSuccess: () => { offerDraw(gameId) }
    })
  }

  const accept = async () => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: {
        'chess-action': 'accept-draw',
        'game-id': gameId
      }
    })
  }

  const decline = async () => {
    await urbit.poke({
      app: 'chess',
      mark: 'chess-action',
      json: {
        'chess-action': 'decline-draw',
        'game-id': gameId
      },
      onSuccess: () => { declineDraw(gameId) }
    })
  }

  return (
    <div className='board-container'>
      <div className='board-proper'>
        <Chessboard
          id = {gameId}
          position = {activeGame.position}
          orientation = {side}
          darkSquareStyle = {darkSquareStyle}
          lightSquareStyle = {lightSquareStyle}
          onDrop = {makeMoveWithExtra(promotion as ChessPromotion)}
          undo = {undo}
          calcWidth = { ({ screenWidth, screenHeight }) =>
            Math.min(
              Math.floor(screenWidth * (4/5)),
              Math.floor(screenHeight * (4/5))
            )}
        />
      </div>
      <div className='board-info'>
        {
          activeGame.position.split(' ')[1] === 'w'
            ? <span>{`${activeGame.info.white}(white) to move`}</span>
            : <span>{`${activeGame.info.black}(black) to move`}</span>
        }
      </div>
      <div className='board-controls'>
        <div className='board-draw-offer' hidden={!activeGame.gotDrawOffer}>
          Opponent offered draw<br/>
          <button onClick={() => accept()}>Accept</button>
          <button onClick={() => decline()}>Decline</button>
        </div>
        <div className='board-buttons'>
          <div>
            <button disabled={activeGame.sentDrawOffer} onClick={(e) => offer()}>Offer Draw</button>
          </div>
          <div hidden={!activeGame.sentDrawOffer}>
            Offered draw to opponent<br/>
          </div>
          <div>
            <button onClick={() => resignGame()}>Resign</button>
          </div>
          <div>
            <button onClick={() => navigate('/')}>Main Menu</button>
          </div>
        </div>
        <div className='board-promotion'>
          Promote pawn:<br/>
          <div>
            <input
              name='promotion'
              value=''
              defaultChecked={true}
              type='radio'
              onChange={(e) => setPromotion(e.target.value)}
            /> None<br/>
          </div>
          <div>
            <input
              name='promotion'
              value='knight'
              type='radio'
              onChange={(e) => setPromotion(e.target.value)}
            /> {side === 'white' ? '♘' : '♞'}<br/>
          </div>
          <div>
            <input
              name='promotion'
              value='bishop'
              type='radio'
              onChange={(e) => setPromotion(e.target.value)}
            /> {side === 'white' ? '♗' : '♝'}<br/>
          </div>
          <div>
            <input
              name='promotion'
              value='rook'
              type='radio'
              onChange={(e) => setPromotion(e.target.value)}
            /> {side === 'white' ? '♖' : '♜'}<br/>
          </div>
          <div>
            <input
              name='promotion'
              value='queen'
              type='radio'
              onChange={(e) => setPromotion(e.target.value)}
            /> {side === 'white' ? '♕' : '♛'}<br/>
          </div>
        </div>
      </div>
    </div>)
}

function renderCompletedGame (completedGame: ChessActiveGameInfo) {
  const { urbit } = useChessStore()
  const navigate = useNavigate()

  const darkSquareStyle = { backgroundColor: 'rgb(68, 68, 68)' }
  const lightSquareStyle = { backgroundColor: 'rgb(238, 238, 238)' }

  const side: ChessSide = (urbit.ship === completedGame.info.white) ? ChessSide.White : ChessSide.Black

  return (
    <div className='board-container'>
      <div className='board-proper'>
        <Chessboard
          id = {completedGame.info.gameID}
          position = {completedGame.position}
          orientation = {side}
          draggable = {false}
          darkSquareStyle = {darkSquareStyle}
          lightSquareStyle = {lightSquareStyle}
          calcWidth = { ({ screenWidth, screenHeight }) =>
            Math.min(
              Math.floor(screenWidth * (4/5)),
              Math.floor(screenHeight * (4/5))
            )}
        />
      </div>
      <div className='board-info'>
        <span color='red'>Result: {completedGame.info.result}</span>
      </div>
      <div className='board-controls'>
        <div className='board-buttons'>
          <div>
            <button onClick={() => navigate('/')}>Main Menu</button>
          </div>
        </div>
      </div>
    </div>)
}

export function GameBoard ({ gameId }: BoardProps) {
  const { activeGames, completedGames } = useChessStore()
  const navigate = useNavigate()

  if (activeGames.has(gameId)) {
    return renderActiveGame(activeGames.get(gameId))
  } else if (completedGames.has(gameId)) {
    return renderCompletedGame(completedGames.get(gameId))
  } else {
    navigate('/')
    return (<></>)
  }
}
