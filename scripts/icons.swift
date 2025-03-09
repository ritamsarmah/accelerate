/// Generates all necessary extension icons from system symbols
import Cocoa
import CoreGraphics

let svgFileURL = URL(fileURLWithPath: "icon.svg")

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


// MARK: - General

print(svgFileURL.path())

// Using imagemagick to convert SVG to PNG
let process = Process()
process.launchPath = "/opt/homebrew/bin/magick"
process.arguments = [svgFileURL.path(), "-resize", "1024x1024", "-background", "black", "-stroke", "white", "icon.png"]
try! process.run()

// generateMacIcons()

// MARK: - macOS

// func generateMacIcons() {
//     let appIconDirectory = URL(fileURLWithPath: "macOS/Accelerate/Supporting Files/Assets.xcassets/AppIcon.appiconset")
//     let contentsPath = appIconDirectory.appendingPathComponent("Contents.json")

//     guard let data = try? Data(contentsOf: contentsPath) else {
//         print("Failed to read Contents.json")
//         return
//     }

//     guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
//           let dictionary = json as? [String: Any],
//           let images = dictionary["images"] as? [[String: Any]] else {
//         print("Failed to parse JSON")
//         return
//     }

//     for image in images {
//         if let scale = image["scale"] as? String,
//            let size = image["size"] as? String,
//            let filename = image["filename"] as? String {

//             let scale = Int(scale.dropLast())!
//             let dimensions = size.split(separator: "x").map { Int($0)! * scale }
            
//             let iconPath = appIconDirectory.appendingPathComponent(filename)
//             let width = dimensions[0]
//             let height = dimensions[1]


//             do {
//                 try process.run()
//                 process.waitUntilExit()
//                 if process.terminationStatus != 0 {
//                     print("Failed to generate icon: \(filename)")
//                 }
//             } catch {
//                 print("Error executing imagemagick process: \(error)")
//             }
//         }
//     }
// }

// MARK: - iOS

// TODO: Generate popover icons

// let macSnackbarDirectory = "Web/snackbar"
// let iosSnackbarDirectory = "iOS/Accelerate Extension/Resources/images/snackbar"
// let iosActionDirectory = "iOS/Accelerate Extension/Resourecs/images/actions"

// TODO: For each image

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
