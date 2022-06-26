import React, { useEffect, useRef, useState } from 'react'
import { Chessground as ChessgroundApi } from 'chessground'
import { Api as CgApi } from 'chessground/api'
import { Config as CgConfig } from 'chessground/config'

interface ChessgroundProps {
  api: CgApi | null;
  setApi: (boardApi: CgApi) => void;
  contained?: boolean;
  size?: number;
  config?: CgConfig;
}

function Chessground ({ api, setApi, contained = true, size = 1000, config = {} }: ChessgroundProps) {
  const resizeCallback = () => { api.redrawAll() }

  //   const ref = useRef<HTMLDivElement>(null);
  //
  //   useEffect(() => {
  //     if (ref && ref.current && !api) {
  //       const chessgroundApi = ChessgroundApi(ref.current, {
  //         animation: { enabled: true, duration: 200 },
  //         ...config,
  //       });
  //       setApi(chessgroundApi);
  //     } else if (ref && ref.current && api) {
  //       api.set(config);
  //     }
  //   }, [ref]);
  //
  //   useEffect(() => {
  //     api?.set(config);
  //   }, [api, config]);

  //   const boardRef = useRef<HTMLDivElement>(null)
  //
  //   useEffect(
  //     () => {
  //       if (boardRef && boardRef.current && !api) {
  //         const chessgroundApi = ChessgroundApi(boardRef.current, config)
  //         setApi(chessgroundApi)
  //       } else if (boardRef && boardRef.current && api) {
  //         api.set(config)
  //       }
  //     },
  //     [boardRef])
  //
  //   useEffect(
  //     () => { api?.set(config) },
  //     [api, config])

  const boardRef = useRef(null)

  useEffect(
    () => { setApi(ChessgroundApi(boardRef.current, config)) },
    [boardRef])

  //   useEffect(
  //     () => { api?.set(config) },
  //     [api, config])

  useEffect(
    () => {
      window.addEventListener('resize', resizeCallback)

      return () => {
        window.removeEventListener('resize', resizeCallback)
      }
    })

  api?.set(config)

  return (
    <div style={{ height: contained ? '100%' : size, width: contained ? '100%' : size }}>
      <div ref={boardRef} className='chessboard' />
    </div>
  )

  //   return (
  //     <div style={{ height: contained ? '100%' : size, width: contained ? '100%' : size }}>
  //       <div ref={boardRef} style={{ height: '100%', width: '100%', display: 'table' }} />
  //     </div>
  //   )
}

export default Chessground
