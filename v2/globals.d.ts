// CommonJS globals that Hammerspoon 2's require() provides to every module,
// but which hammerspoon.d.ts doesn't declare.
declare var module: { exports: any }
declare var exports: any
declare function require(id: string): any
declare var __filename: string
declare var __dirname: string
