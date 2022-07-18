// COMET VS. COMET:     LENGTH = 123    MAX FONT SIZE = min(max(2.1vh, 19px), max(0.95vw, 12px))
// COMET VS. MOON:      LENGTH = 94     MAX FONT SIZE = min(max(2.6vh, 25px), max(1.25vw, 14px))
// COMET VS. PLANET:    LENGTH = 80     MAX FONT SIZE = min(max(3.0vh, 28px), max(1.5vw, 14px))
// COMET VS. STAR:      LENGTH = 73     MAX FONT SIZE = min(max(3.0vh, 28px), max(1.6vw, 14px))
// COMET VS. GALAXY:    LENGTH = 70     MAX FONT SIZE = min(max(3.0vh, 28px), max(1.7vw, 14px))
// MOON VS. MOON:       LENGTH = 65     MAX FONT SIZE = min(max(3.2vh, 28px), max(1.8vw, 14px))
// MOON VS. PLANET:     LENGTH = 51     MAX FONT SIZE = min(max(3.2vh, 28px), max(2.2vw, 15px))
// MOON VS. STAR:       LENGTH = 44     MAX FONT SIZE = min(max(3.2vh, 28px), max(2.6vw, 17px))
// MOON VS. GALAXY:     LENGTH = 41     MAX FONT SIZE = min(max(3.4vh, 28px), max(2.8vw, 18px))
// PLANET VS. PLANET:   LENGTH = 37     MAX FONT SIZE = min(max(3.5vh, 28px), max(2.8vw, 20px))
// PLANET VS. STAR:     LENGTH = 30     MAX FONT SIZE = min(max(4.2vh, 28px), max(2.8vw, 25px))
// PLANET VS. GALAXY:   LENGTH = 27     MAX FONT SIZE = min(max(4.6vh, 28px), max(2.8vw, 28px))
// STAR VS. STAR:       LENGTH = 23     MAX FONT SIZE = min(max(5.2vh, 28px), max(2.8vw, 28px))
// STAR VS. GALAXY:     LENGTH = 20     MAX FONT SIZE = min(max(5.8vh, 28px), max(2.8vw, 28px))
// GALAXY VS. GALAXY:   LENGTH = 17     MAX FONT SIZE = min(max(6.4vh, 28px), max(2.8vw, 28px))
//
// COMET PRACTICE:      LENGTH = 74     MAX FONT SIZE = min(max(3.3vh, 32px), max(1.6vw, 12px))
// MOON PRACTICE:       LENGTH = 45     MAX FONT SIZE = min(max(3.5vh, 32px), max(2.7vw, 17px))
// PLANET PRACTICE:     LENGTH = 31     MAX FONT SIZE = min(max(4.2vh, 32px), max(3.0vw, 24px))
// STAR PRACTICE:       LENGTH = 24     MAX FONT SIZE = min(max(5.2vh, 32px), max(3.0vw, 31px))
// GALAXY PRACTICE:     LENGTH = 21     MAX FONT SIZE = min(max(5.8vh, 32px), max(3.0vw, 36px))
//
const LENGTH_TO_FONT_SIZE: Map<number, string> = new Map([
  [17, 'min(max(6.4vh, 28px), max(2.8vw, 28px))'],
  [20, 'min(max(5.8vh, 28px), max(2.8vw, 28px))'],
  [23, 'min(max(5.2vh, 28px), max(2.8vw, 28px))'],
  [27, 'min(max(4.6vh, 28px), max(2.8vw, 28px))'],
  [30, 'min(max(4.2vh, 28px), max(2.8vw, 25px))'],
  [37, 'min(max(3.5vh, 28px), max(2.8vw, 20px))'],
  [41, 'min(max(3.4vh, 28px), max(2.8vw, 18px))'],
  [44, 'min(max(3.2vh, 28px), max(2.6vw, 17px))'],
  [51, 'min(max(3.2vh, 28px), max(2.2vw, 15px))'],
  [65, 'min(max(3.2vh, 28px), max(1.8vw, 14px))'],
  [70, 'min(max(3.0vh, 28px), max(1.7vw, 14px))'],
  [73, 'min(max(3.0vh, 28px), max(1.6vw, 14px))'],
  [80, 'min(max(3.0vh, 28px), max(1.5vw, 14px))'],
  [94, 'min(max(2.6vh, 25px), max(1.25vw, 14px))'],
  [123, 'min(max(2.1vh, 19px), max(0.95vw, 12px))'],
  //
  [21, 'min(max(5.8vh, 32px), max(3.0vw, 36px))'],
  [24, 'min(max(5.2vh, 32px), max(3.0vw, 31px))'],
  [31, 'min(max(4.2vh, 32px), max(3.0vw, 24px))'],
  [45, 'min(max(3.5vh, 32px), max(2.7vw, 17px))'],
  [74, 'min(max(3.3vh, 32px), max(1.6vw, 12px))']
])

export const URBIT_CHESS = {
  lengthToFontSize: LENGTH_TO_FONT_SIZE
}
