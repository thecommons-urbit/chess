import React, { useEffect, useRef } from 'react'
import { Chessground as ChessgroundApi } from 'chessground'
import usePracticeBoardStore from '../ts/stores/practiceBoardStore'

interface ChessgroundProps {
  size?: number | null;
}

function Chessground ({ size = null }: ChessgroundProps) {
  const boardRef = useRef(null)
  const { baseConfig, setApi } = usePracticeBoardStore()

  useEffect(
    () => { setApi(ChessgroundApi(boardRef.current, baseConfig)) },
    [boardRef, baseConfig])

  return (
    <div style={{ height: (size === null) ? '100%' : size, width: (size === null) ? '100%' : size }}>
      <div ref={boardRef} className='chessboard' />
    </div>
  )
}

export default Chessground
