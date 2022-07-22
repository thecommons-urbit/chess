//
// The maximum font size that looks good depends on the names of the ships playing. Since, unlike user names, ship names
// have a fixed length for each class of identity, it's possible to find the optimal text size for each combination of
// playing ship classes.
//
// COMET VS. COMET:     LENGTH = 123    MAX FONT SIZE = min(max(2.1vh, 38px), max(0.95vw, 24px))
// COMET VS. MOON:      LENGTH = 94     MAX FONT SIZE = min(max(2.6vh, 50px), max(1.25vw, 28px))
// COMET VS. PLANET:    LENGTH = 80     MAX FONT SIZE = min(max(3.0vh, 56px), max(1.5vw, 28px))
// COMET VS. STAR:      LENGTH = 73     MAX FONT SIZE = min(max(3.0vh, 56px), max(1.6vw, 28px))
// COMET VS. GALAXY:    LENGTH = 70     MAX FONT SIZE = min(max(3.0vh, 56px), max(1.7vw, 28px))
// MOON VS. MOON:       LENGTH = 65     MAX FONT SIZE = min(max(3.2vh, 56px), max(1.8vw, 28px))
// MOON VS. PLANET:     LENGTH = 51     MAX FONT SIZE = min(max(3.2vh, 56px), max(2.2vw, 30px))
// MOON VS. STAR:       LENGTH = 44     MAX FONT SIZE = min(max(3.2vh, 56px), max(2.6vw, 34px))
// MOON VS. GALAXY:     LENGTH = 41     MAX FONT SIZE = min(max(3.4vh, 56px), max(2.8vw, 36px))
// PLANET VS. PLANET:   LENGTH = 37     MAX FONT SIZE = min(max(3.5vh, 56px), max(2.8vw, 40px))
// PLANET VS. STAR:     LENGTH = 30     MAX FONT SIZE = min(max(4.2vh, 56px), max(2.8vw, 50px))
// PLANET VS. GALAXY:   LENGTH = 27     MAX FONT SIZE = min(max(4.6vh, 56px), max(2.8vw, 56px))
// STAR VS. STAR:       LENGTH = 23     MAX FONT SIZE = min(max(5.2vh, 56px), max(2.8vw, 56px))
// STAR VS. GALAXY:     LENGTH = 20     MAX FONT SIZE = min(max(5.8vh, 56px), max(2.8vw, 56px))
// GALAXY VS. GALAXY:   LENGTH = 17     MAX FONT SIZE = min(max(6.4vh, 56px), max(2.8vw, 56px))
//
// COMET PRACTICE:      LENGTH = 74     MAX FONT SIZE = min(max(3.3vh, 64px), max(1.6vw, 24px))
// MOON PRACTICE:       LENGTH = 45     MAX FONT SIZE = min(max(3.5vh, 64px), max(2.7vw, 34px))
// PLANET PRACTICE:     LENGTH = 31     MAX FONT SIZE = min(max(4.2vh, 64px), max(3.0vw, 48px))
// STAR PRACTICE:       LENGTH = 24     MAX FONT SIZE = min(max(5.2vh, 64px), max(3.0vw, 62px))
// GALAXY PRACTICE:     LENGTH = 21     MAX FONT SIZE = min(max(5.8vh, 64px), max(3.0vw, 72px))
//
const LENGTH_TO_FONT_SIZE: Map<number, string> = new Map([
  [17, 'min(max(6.4vh, 42px), max(2.8vw, 42px))'],
  [20, 'min(max(5.8vh, 42px), max(2.8vw, 42px))'],
  [23, 'min(max(5.2vh, 42px), max(2.8vw, 42px))'],
  [27, 'min(max(4.6vh, 42px), max(2.8vw, 42px))'],
  [30, 'min(max(4.2vh, 42px), max(2.8vw, 37px))'],
  [37, 'min(max(3.5vh, 42px), max(2.8vw, 30px))'],
  [41, 'min(max(3.4vh, 42px), max(2.8vw, 27px))'],
  [44, 'min(max(3.2vh, 42px), max(2.6vw, 25px))'],
  [51, 'min(max(3.2vh, 42px), max(2.2vw, 22px))'],
  [65, 'min(max(3.2vh, 42px), max(1.8vw, 21px))'],
  [70, 'min(max(3.0vh, 42px), max(1.7vw, 21px))'],
  [73, 'min(max(3.0vh, 42px), max(1.6vw, 21px))'],
  [80, 'min(max(3.0vh, 42px), max(1.5vw, 21px))'],
  [94, 'min(max(2.6vh, 37px), max(1.25vw, 21px))'],
  [123, 'min(max(2.1vh, 28px), max(0.95vw, 18px))'],
  //
  [21, 'min(max(5.8vh, 48px), max(3.0vw, 54px))'],
  [24, 'min(max(5.2vh, 48px), max(3.0vw, 46px))'],
  [31, 'min(max(4.2vh, 48px), max(3.0vw, 36px))'],
  [45, 'min(max(3.5vh, 48px), max(2.6vw, 25px))'],
  [74, 'min(max(3.3vh, 48px), max(1.6vw, 18px))']
])

export const URBIT_CHESS = {
  lengthToFontSize: LENGTH_TO_FONT_SIZE
}
