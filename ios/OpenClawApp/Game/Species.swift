import Foundation
import SwiftUI

enum RigFamily: String, Codable, Sendable, CaseIterable {
    case orbBlob
    case catBunny
    case bearKoala
    case axolotlDragonCharm
}

enum Species: String, Codable, Sendable, CaseIterable {
    case orb
    case kit
    case cub
    case axo
    case pup
    case chick
    case slime
    case shade

    var rig: RigFamily {
        switch self {
        case .orb, .slime, .shade: return .orbBlob
        case .kit:                 return .catBunny
        case .cub, .pup:           return .bearKoala
        case .axo, .chick:         return .axolotlDragonCharm
        }
    }

    var defaultBodyColor: Color {
        switch self {
        case .orb:    return PixelPalette.Pet.pink
        case .kit:    return PixelPalette.Pet.blue
        case .cub:    return PixelPalette.Pet.cream
        case .axo:    return PixelPalette.Pet.mint
        case .pup:    return PixelPalette.Pet.coral
        case .chick:  return PixelPalette.Pet.cream
        case .slime:  return PixelPalette.Pet.lilac
        case .shade:  return PixelPalette.Pet.charcoal
        }
    }
}

enum EarStyle:    String, Codable, Sendable, CaseIterable { case none, roundEars, longEars, hornsSingle, hornsDouble, finlets }
enum EyeSet:     String, Codable, Sendable, CaseIterable  { case square, oval, sparkle, sleepy, halfClosed, heart }
enum ChestEmblem: String, Codable, Sendable, CaseIterable { case none, heart, star, leaf }
enum SkinMaterial:String, Codable, Sendable, CaseIterable { case matte, glossy, sparkleDot, pearlescent, glowEdge }
enum Accessory:   String, Codable, Sendable, CaseIterable { case none, bow, scarf, tinyHat, antennaBall }
enum Mutation:    String, Codable, Sendable, CaseIterable { case none, freckles, halo, driftingPetal, thirdEye }

enum Rarity: String, Codable, Sendable, CaseIterable {
    case common
    case uncommon
    case rare
    case special
    case secret
}

struct PetTraits: Codable, Sendable, Hashable {
    var species: Species
    var bodyColor: PixelBodyColor
    var ears: EarStyle
    var eyes: EyeSet
    var emblem: ChestEmblem
    var skin: SkinMaterial
    var accessory: Accessory
    var mutation: Mutation
    var rarity: Rarity

    static let firstHatchling = PetTraits(
        species: .orb,
        bodyColor: .pink,
        ears: .none,
        eyes: .square,
        emblem: .none,
        skin: .matte,
        accessory: .none,
        mutation: .none,
        rarity: .common
    )
}

enum PixelBodyColor: String, Codable, Sendable, CaseIterable {
    case pink, blue, cream, mint, lilac, coral, cloud, charcoal

    var color: Color {
        switch self {
        case .pink:     return PixelPalette.Pet.pink
        case .blue:     return PixelPalette.Pet.blue
        case .cream:    return PixelPalette.Pet.cream
        case .mint:     return PixelPalette.Pet.mint
        case .lilac:    return PixelPalette.Pet.lilac
        case .coral:    return PixelPalette.Pet.coral
        case .cloud:    return PixelPalette.Pet.cloud
        case .charcoal: return PixelPalette.Pet.charcoal
        }
    }
}
