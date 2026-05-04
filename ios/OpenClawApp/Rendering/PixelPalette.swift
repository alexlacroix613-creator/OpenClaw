import SwiftUI

enum PixelPalette {
    static let outline = Color(red: 0x2A/255, green: 0x1B/255, blue: 0x4D/255)
    static let outlineSoft = Color(red: 0x2A/255, green: 0x1B/255, blue: 0x4D/255).opacity(0.20)

    enum Sky {
        static let top = Color(red: 1.00, green: 0.851, blue: 0.910)
        static let bot = Color(red: 0.788, green: 0.875, blue: 1.00)
    }

    enum Cloud {
        static let fill = Color.white
        static let shade = Color(red: 0.898, green: 0.925, blue: 1.00)
    }

    enum Platform {
        static let top = Color(red: 0.710, green: 0.886, blue: 0.659)
        static let side = Color(red: 0.498, green: 0.729, blue: 0.439)
        static let shade = Color(red: 0.361, green: 0.600, blue: 0.329)
    }

    enum Tree {
        static let leaf = Color(red: 0.424, green: 0.761, blue: 0.459)
        static let leafShade = Color(red: 0.310, green: 0.635, blue: 0.345)
        static let trunk = Color(red: 0.545, green: 0.369, blue: 0.235)
    }

    enum Pet {
        static let pink = Color(red: 0.961, green: 0.769, blue: 0.851)
        static let blue = Color(red: 0.761, green: 0.835, blue: 0.941)
        static let cream = Color(red: 1.00, green: 0.898, blue: 0.659)
        static let mint = Color(red: 0.718, green: 0.922, blue: 0.824)
        static let lilac = Color(red: 0.851, green: 0.784, blue: 0.961)
        static let coral = Color(red: 1.00, green: 0.725, blue: 0.604)
        static let cloud = Color.white
        static let charcoal = Color(red: 0.247, green: 0.227, blue: 0.310)
    }

    static let cheek = Color(red: 1.00, green: 0.702, blue: 0.820)
    static let eyeWhite = Color.white
    static let eyeDark = outline

    enum Snack {
        static let apple = Color(red: 1.00, green: 0.600, blue: 0.600)
        static let leaf = Color(red: 0.710, green: 0.886, blue: 0.659)
        static let honey = Color(red: 1.00, green: 0.827, blue: 0.502)
        static let berry = Color(red: 0.788, green: 0.627, blue: 1.00)
        static let shell = Color(red: 1.00, green: 0.878, blue: 0.541)
        static let mystery = Color(red: 0.690, green: 0.667, blue: 1.00)
    }

    enum Panel {
        static let fill = Color.white
        static let accent = Color(red: 1.00, green: 0.788, blue: 0.867)
    }
}
