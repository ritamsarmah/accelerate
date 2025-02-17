#!/usr/bin/env swift

import Cocoa

let macSnackbarDirectory = "Web/snackbar"
let iosSnackbarDirectory = "iOS/Accelerate Extension/Resources/images/snackbar"
let iosActionDirectory = "iOS/Accelerate Extension/Resourecs/images/actions"

// Map SF symbol name to file name

let snackbarIcons: [String: String] = [
  "backward": "arrow.trianglehead.counterclockwise",
  "forward": "arrow.trianglehead.clockwise",
  "loop": "repeat",
  "mute": "speaker.slash.fill",
  "pause": "pause.fill",
  "pip": "pip.fill",
  "play": "play.fill",
  "skip": "forward.end.fill",
  "unmute": "speaker.wave.2.fill",
]

let actionIcons: [String: String] = [
  "pip": "pip",
  "playpause.circle": "playOrPause",
  "gauge.with.needle": "setRate",
  "eye.circle": "showRate",
  "arrow.trianglehead.counterclockwise": "skipBackward",
  "arrow.trianglehead.clockwise": "skipForward",
  "forward.end.circle": "skipToEnd",
  "hare.circle": "speedUp",
  "tortoise.circle": "slowDown",
  "arrow.up.left.and.arrow.down.right": "toggleFullscreen",
  "repeat.circle": "toggleLoop",
  "speaker.slash.circle": "toggleMute",
]


// TODO: For each image

// ST

// // Define the system symbol name and output file name
// let symbolName = "square.and.pencil"
// let outputFileName = "\(symbolName).svg"

// // Fetch the system symbol image
// guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
//     print("Error: Unable to find system symbol named \(symbolName)")
//     exit(1)
// }

// print(image)

// // Extract the image representation
// guard let tiffData = image.tiffRepresentation,
//       let bitmapRep = NSBitmapImageRep(data: tiffData) else {
//     print("Error: Unable to create image representation for \(symbolName)")
//     exit(1)
// }

// // Export to SVG format
// do {
//     // NSBitmapImageRep doesn't natively export SVG, but PDF data is supported
//     let pdfData = image.
//     try pdfData.write(to: URL(fileURLWithPath: outputFileName))
//     print("SVG file successfully created: \(outputFileName)")
// } catch {
//     print("Error: Failed to write SVG file - \(error.localizedDescription)")
//     exit(1)
// }
