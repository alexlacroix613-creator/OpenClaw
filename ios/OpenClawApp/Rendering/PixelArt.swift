import SwiftUI

struct PixelSprite {
    let rows: [String]
    let palette: [Character: Color]

    var width: Int { rows.first?.count ?? 0 }
    var height: Int { rows.count }
}

struct PixelArt: View {
    let sprite: PixelSprite
    let scale: CGFloat
    var dropShadow: Bool = true

    var body: some View {
        let pixelSize = scale
        return ZStack {
            if dropShadow {
                rasterize(sprite: sprite, pixelSize: pixelSize, tint: PixelPalette.outlineSoft, onlyOpaque: true)
                    .offset(x: pixelSize, y: pixelSize)
            }
            rasterize(sprite: sprite, pixelSize: pixelSize, tint: nil, onlyOpaque: false)
        }
        .frame(
            width: CGFloat(sprite.width) * pixelSize + (dropShadow ? pixelSize : 0),
            height: CGFloat(sprite.height) * pixelSize + (dropShadow ? pixelSize : 0),
            alignment: .topLeading
        )
        .drawingGroup(opaque: false)
    }

    @ViewBuilder
    private func rasterize(sprite: PixelSprite, pixelSize: CGFloat, tint: Color?, onlyOpaque: Bool) -> some View {
        Canvas(opaque: false) { context, _ in
            for (rowIndex, row) in sprite.rows.enumerated() {
                for (colIndex, character) in row.enumerated() {
                    guard character != "." else { continue }
                    let color: Color
                    if let tintColor = tint {
                        color = tintColor
                    } else if let mapped = sprite.palette[character] {
                        color = mapped
                    } else {
                        continue
                    }
                    if onlyOpaque, sprite.palette[character] == nil { continue }
                    let rect = CGRect(
                        x: CGFloat(colIndex) * pixelSize,
                        y: CGFloat(rowIndex) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(
            width: CGFloat(sprite.width) * pixelSize,
            height: CGFloat(sprite.height) * pixelSize,
            alignment: .topLeading
        )
    }
}

extension PixelSprite {
    static let basePalette: [Character: Color] = [
        "o": PixelPalette.outline,
        "W": Color.white,
        "E": PixelPalette.eyeWhite,
        "P": PixelPalette.eyeDark,
        "M": PixelPalette.outline,
        "C": PixelPalette.cheek
    ]

    static func pet(bodyColor: Color) -> PixelSprite {
        let rows = [
            "....oooooooo....",
            "..ooBBBBBBBBoo..",
            ".oBBBBBBBBBBBBo.",
            "oBBBBBWWBBWWBBBo",
            "oBBBBBWWBBWWBBBo",
            "oBBoooooooooBBBo",
            "oBBoEEPPEEPPEoBo",
            "oBBoEEPPEEPPEoBo",
            "oBBoooooooooBBBo",
            "oBBBBCCBBBBCCBBo",
            "oBBBBBBoooBBBBBo",
            "oBBBBBoMMMoBBBBo",
            ".oBBBBoooooBBBo.",
            "..oBBBBBBBBBBoo.",
            "...oooBBBBoooo..",
            ".....ooooooo...."
        ]
        var palette = basePalette
        palette["B"] = bodyColor
        return PixelSprite(rows: rows, palette: palette)
    }

    static func petBlinking(bodyColor: Color) -> PixelSprite {
        let rows = [
            "....oooooooo....",
            "..ooBBBBBBBBoo..",
            ".oBBBBBBBBBBBBo.",
            "oBBBBBWWBBWWBBBo",
            "oBBBBBWWBBWWBBBo",
            "oBBoooooooooBBBo",
            "oBBoooooooooBBo.",
            "oBBoBBBBBBBBoBBo",
            "oBBoooooooooBBBo",
            "oBBBBCCBBBBCCBBo",
            "oBBBBBBoooBBBBBo",
            "oBBBBBoMMMoBBBBo",
            ".oBBBBoooooBBBo.",
            "..oBBBBBBBBBBoo.",
            "...oooBBBBoooo..",
            ".....ooooooo...."
        ]
        var palette = basePalette
        palette["B"] = bodyColor
        return PixelSprite(rows: rows, palette: palette)
    }

    static func petHappy(bodyColor: Color) -> PixelSprite {
        let rows = [
            "....oooooooo....",
            "..ooBBBBBBBBoo..",
            ".oBBBBBBBBBBBBo.",
            "oBBBBBWWBBWWBBBo",
            "oBBBBBWWBBWWBBBo",
            "oBBoooooooooBBBo",
            "oBBoBPPBBBBPPBBo",
            "oBBooooooooooBBo",
            "oBBoBBBBBBBBBBBo",
            "oBBBBCCBBBBCCBBo",
            "oBBBBBoooooBBBBo",
            "oBBBBoMMMMMoBBBo",
            ".oBBoooooooBBBo.",
            "..oBBBBBBBBBBoo.",
            "...oooBBBBoooo..",
            ".....ooooooo...."
        ]
        var palette = basePalette
        palette["B"] = bodyColor
        return PixelSprite(rows: rows, palette: palette)
    }

    static let egg: PixelSprite = {
        let rows = [
            "....oooooo....",
            "..ooSSSSSSoo..",
            ".oSSSSWWSSSSo.",
            "oSSSSWWWWSSSSo",
            "oSSSSSSSSSSSSo",
            "oSSdSSSSSSSdSo",
            "oSSSSSSSdSSSSo",
            "oSSSdSSSSSSSSo",
            "oSSSSSSdSSSSSo",
            "oSSSSdSSSSdSSo",
            ".oSSSSSSSSSSo.",
            "..ooSSSSSSoo..",
            "....oooooo...."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "S": PixelPalette.Pet.cream,
            "W": .white,
            "d": PixelPalette.Snack.honey
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let cloudSmall: PixelSprite = {
        let rows = [
            "...oooooo...",
            "..oWWWWWWoo.",
            ".oWWWWWWWWWo",
            "oWWWWWWWWWWo",
            "oWWWWSSSSSWo",
            ".ooWWWSSSWoo",
            "...oooooooo."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "W": PixelPalette.Cloud.fill,
            "S": PixelPalette.Cloud.shade
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let cloudWide: PixelSprite = {
        let rows = [
            "....ooooo......oooo....",
            "..ooWWWWWooooooWWWWoo..",
            ".oWWWWWWWWWWWWWWWWWWWo.",
            "oWWWWWWWWWWWWWWWWWWWWWo",
            "oWWWWSSSSSSSSSSSSSSWWWo",
            ".oWWSSSSSSSSSSSSSSSSWo.",
            "..ooooSSSSSSSSSSSooooo."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "W": PixelPalette.Cloud.fill,
            "S": PixelPalette.Cloud.shade
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let tree: PixelSprite = {
        let rows = [
            "....oooooo....",
            "..ooLLLLLLoo..",
            ".oLLLLLLLLLLo.",
            "oLLLLSSSSLLLLo",
            "oLLLLLSSSLLLLo",
            "oLLLLLLLLLLLLo",
            ".oLLLLLLLLLLo.",
            "..ooLLLLLLoo..",
            "....oTTTTo....",
            "....oTTTTo....",
            "....oTTTTo....",
            "...oTTTTTTo...",
            "..oTTTTTTTTo.."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "L": PixelPalette.Tree.leaf,
            "S": PixelPalette.Tree.leafShade,
            "T": PixelPalette.Tree.trunk
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let platform: PixelSprite = {
        var rows: [String] = []
        rows.append("..oooooooooooooooooooooooooooooooo..")
        rows.append(".oGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGo.")
        rows.append("oGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGo")
        rows.append("oGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGo")
        rows.append("oSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSo")
        rows.append("oSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSo")
        rows.append("oDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDo")
        rows.append("oDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDo")
        rows.append(".oDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDo.")
        rows.append("..ooDDDDDDDDDDDDDDDDDDDDDDDDDDDDoo..")
        rows.append("....oooooooooooooooooooooooooooo....")
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "G": PixelPalette.Platform.top,
            "S": PixelPalette.Platform.side,
            "D": PixelPalette.Platform.shade
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let snackApple: PixelSprite = {
        let rows = [
            "......oo......",
            ".....oTTo.....",
            "....oTTLo.....",
            "...ooLLoo.....",
            "..oAAAAAAo....",
            ".oAAAWAAAAo...",
            "oAAAWWAAAAAo..",
            "oAAAAAAAAAAo..",
            "oAAAAAAAAAAo..",
            ".oAAAAAAAAo...",
            "..oAAAAAAo....",
            "...oooooo....."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "A": PixelPalette.Snack.apple,
            "W": .white,
            "L": PixelPalette.Tree.leaf,
            "T": PixelPalette.Tree.trunk
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let snackHoney: PixelSprite = {
        let rows = [
            "..oooooooo..",
            "..oWWWWWWo..",
            ".oooooooooo.",
            "oHHHHHHHHHHo",
            "oHHHWWHHHHHo",
            "oHHWWHHHHHHo",
            "oHHHHHHHHHHo",
            "oHHHHHHHHHHo",
            ".oHHHHHHHHo.",
            "..oooooooo.."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "H": PixelPalette.Snack.honey,
            "W": .white
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let snackLeaf: PixelSprite = {
        let rows = [
            "......oo....",
            ".....oLLo...",
            "....oLLLLo..",
            "...oLLLLLLo.",
            "..oLLLSSLLLo",
            ".oLLLSSSSLLo",
            "oLLSSLLSSLLo",
            "oLSSLLLLLSLo",
            ".oLLLLLLLLo.",
            "..oTTTTTTo..",
            "...oTTTTo..."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "L": PixelPalette.Snack.leaf,
            "S": PixelPalette.Tree.leafShade,
            "T": PixelPalette.Tree.trunk
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let snackBerry: PixelSprite = {
        let rows = [
            ".....oo.....",
            "....oBBo....",
            "...oBWBBo...",
            "...oBBBBo...",
            "...ooooo....",
            ".oo.....oo..",
            "oBBo...oBBo.",
            "oBWBo.oBWBo.",
            "oBBBo.oBBBo.",
            ".ooo...oooo."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "B": PixelPalette.Snack.berry,
            "W": .white
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let snackShell: PixelSprite = {
        let rows = [
            "....oooo....",
            "..ooSSSSoo..",
            ".oSSSWSSSSo.",
            "oSSSWWDSSSSo",
            "oSSSSSSSDSSo",
            "oSSDSSSSSSSo",
            "oSSSSSDSSSSo",
            ".oSSSSSSSSo.",
            "..oooooooo.."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "S": PixelPalette.Snack.shell,
            "W": .white,
            "D": PixelPalette.Snack.apple
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()

    static let snackMystery: PixelSprite = {
        let rows = [
            "..oooooooo..",
            ".oMMMMMMMMo.",
            "oMMMMWWMMMMo",
            "oMMooMMooMMo",
            "oMMooMMMMMMMo",
            "oMMMMMooMMMo.",
            "oMMMMMooMMMo.",
            "oMMMMMMMMMMo",
            ".oMMMooMMMo.",
            "..oooooooo.."
        ]
        let palette: [Character: Color] = [
            "o": PixelPalette.outline,
            "M": PixelPalette.Snack.mystery,
            "W": .white
        ]
        return PixelSprite(rows: rows, palette: palette)
    }()
}
