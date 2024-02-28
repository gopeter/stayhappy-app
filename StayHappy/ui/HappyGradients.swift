//
//  HappyGradients.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 22.02.24.
//

import Hue
import SwiftUI

enum HappyGradients: String, CaseIterable {
    case warmFlame
    case nightFade
    case springWarmth
    case juicyPeach
    case youngPassion
    case ladyLips
    case sunnyMorning
    case rainyAshville
    case frozenDreams
    case winterNeva
    case dustyGrass
    case temptingAzure
    case heavyRain
    case amyCrisp
    case meanFruit
    case softBlue
    case ripeMalinka
    case cloudyKnoxville
    case malibuBeach
    case newLife
    case trueSunset
    case morpheusDen
    case rareWind
    case nearMoon
    case wildApple
    case saintPetersburg
    case plumPlate
    case everlastingSky
    case happyFisher
    case blessing
    case sharpeyeEagle
    case ladogaBottom
    case lemonGate
    case itmeoBranding
    case zeusMiracle
    case oldHat
    case starWine
    case deepBlue
    case happyAcid
    case awesomePine
    case newYork
    case shyRainbow
    case mixedHopes
    case flyHigh
    case strongBliss
    case freshMilk
    case snowAgain
    case februaryInk
    case kindSteel
    case softGrass
    case grownEarly
    case sharpBlues
    case shadyWater
    case dirtyBeauty
    case greatWhale
    case teenNotebook
    case politeRumors
    case sweetPeriod
    case wideMatrix
    case softCherish
    case redSalvation
    case burningSpring
    case nightParty
    case skyGlider
    case heavenPeach
    case purpleDivision
    case aquaSplash
    case spikyNaga
    case loveKiss
    case cleanMirror
    case premiumDark
    case coldEvening
    case cochitiLake
    case summerGames
    case passionateBed
    case mountainRock
    case desertHump
    case jungleDay
    case phoenixStart
    case octoberSilence
    case farawayRiver
    case alchemistLab
    case overSun
    case premiumWhite
    case marsParty
    case eternalConstance
    case japanBlush
    case smilingRain
    case cloudyApple
    case bigMango
    case healthyWater
    case amourAmour
    case riskyConcrete
    case strongStick
    case viciousStance
    case paloAlto
    case happyMemories
    case midnightBloom
    case crystalline
    case partyBliss
    case confidentCloud
    case leCocktail
    case riverCity
    case frozenBerry
    case childCare
    case flyingLemon
    case newRetrowave
    case hiddenJaguar
    case aboveTheSky
    case nega
    case denseWater
    case seashore
    case marbleWall
    case cheerfulCaramel
    case nightSky
    case magicLake
    case youngGrass
    case colorfulPeach
    case gentleCare
    case plumBath
    case happyUnicorn
    case africanField
    case solidStone
    case orangeJuice
    case glassWater
    case northMiracle
    case fruitBlend
    case millenniumPine
    case highFlight
    case moleHall
    case spaceShift
    case forestInei
    case royalGarden
    case richMetal
    case juicyCake
    case smartIndigo
    case sandStrike
    case norseBeauty
    case aquaGuidance
    case sunVeggie
    case seaLord
    case blackSea
    case grassShampoo
    case landingAircraft
    case witchDance
    case sleeplessNight
    case angelCare
    case crystalRiver
    case softLipstick
    case saltMountain
    case perfectWhite
    case freshOasis
    case strictNovember
    case morningSalad
    case deepRelief
    case seaStrike
    case nightCall
    case supremeSky
    case lightBlue
    case mindCrawl
    case lilyMeadow
    case sugarLollipop
    case sweetDessert
    case magicRay
    case teenParty
    case frozenHeat
    case gagarinView
    case fabledSunset
    case perfectBlue
}

extension HappyGradients {
    var gradient: LinearGradient {
        switch self {
        case .warmFlame:
            HappyGradients.linear(colors: ["ff9a9e", "fad0c4", "fad0c4"], locations: [0.0, 0.99, 1.0])
          case .nightFade:
              HappyGradients.linear(colors: ["a18cd1", "fbc2eb"], locations: [0.0, 1.0])
          case .springWarmth:
              HappyGradients.linear(colors: ["fad0c4", "fad0c4", "ffd1ff"], locations: [0.0, 0.01, 1.0])
          case .juicyPeach:
              HappyGradients.linear(colors: ["ffecd2", "fcb69f"], locations: [0.0, 1.0])
          case .youngPassion:
              HappyGradients.linear(colors: ["ff8177", "ff867a", "ff8c7f", "f99185", "cf556c", "b12a5b"], locations: [0.0, 0.0, 0.21, 0.52, 0.78, 1.0])
          case .ladyLips:
              HappyGradients.linear(colors: ["ff9a9e", "fecfef", "fecfef"], locations: [0.0, 0.99, 1.0])
          case .sunnyMorning:
              HappyGradients.linear(colors: ["f6d365", "fda085"], locations: [0.0, 1.0])
          case .rainyAshville:
              HappyGradients.linear(colors: ["fbc2eb", "a6c1ee"], locations: [0.0, 1.0])
          case .frozenDreams:
              HappyGradients.linear(colors: ["fdcbf1", "fdcbf1", "e6dee9"], locations: [0.0, 0.01, 1.0])
          case .winterNeva:
              HappyGradients.linear(colors: ["a1c4fd", "c2e9fb"], locations: [0.0, 1.0])
          case .dustyGrass:
              HappyGradients.linear(colors: ["d4fc79", "96e6a1"], locations: [0.0, 1.0])
          case .temptingAzure:
              HappyGradients.linear(colors: ["84fab0", "8fd3f4"], locations: [0.0, 1.0])
          case .heavyRain:
              HappyGradients.linear(colors: ["cfd9df", "e2ebf0"], locations: [0.0, 1.0])
          case .amyCrisp:
              HappyGradients.linear(colors: ["a6c0fe", "f68084"], locations: [0.0, 1.0])
          case .meanFruit:
              HappyGradients.linear(colors: ["fccb90", "d57eeb"], locations: [0.0, 1.0])
          case .softBlue:
              HappyGradients.linear(colors: ["e0c3fc", "8ec5fc"], locations: [0.0, 1.0])
          case .ripeMalinka:
              HappyGradients.linear(colors: ["f093fb", "f5576c"], locations: [0.0, 1.0])
          case .cloudyKnoxville:
              HappyGradients.linear(colors: ["fdfbfb", "ebedee"], locations: [0.0, 1.0])
          case .malibuBeach:
              HappyGradients.linear(colors: ["4facfe", "00f2fe"], locations: [0.0, 1.0])
          case .newLife:
              HappyGradients.linear(colors: ["43e97b", "38f9d7"], locations: [0.0, 1.0])
          case .trueSunset:
              HappyGradients.linear(colors: ["fa709a", "fee140"], locations: [0.0, 1.0])
          case .morpheusDen:
              HappyGradients.linear(colors: ["30cfd0", "330867"], locations: [0.0, 1.0])
          case .rareWind:
              HappyGradients.linear(colors: ["a8edea", "fed6e3"], locations: [0.0, 1.0])
          case .nearMoon:
              HappyGradients.linear(colors: ["5ee7df", "b490ca"], locations: [0.0, 1.0])
          case .wildApple:
              HappyGradients.linear(colors: ["d299c2", "fef9d7"], locations: [0.0, 1.0])
          case .saintPetersburg:
              HappyGradients.linear(colors: ["f5f7fa", "c3cfe2"], locations: [0.0, 1.0])
          case .plumPlate:
              HappyGradients.linear(colors: ["667eea", "764ba2"], locations: [0.0, 1.0])
          case .everlastingSky:
              HappyGradients.linear(colors: ["fdfcfb", "e2d1c3"], locations: [0.0, 1.0])
          case .happyFisher:
              HappyGradients.linear(colors: ["89f7fe", "66a6ff"], locations: [0.0, 1.0])
          case .blessing:
              HappyGradients.linear(colors: ["fddb92", "d1fdff"], locations: [0.0, 1.0])
          case .sharpeyeEagle:
              HappyGradients.linear(colors: ["9890e3", "b1f4cf"], locations: [0.0, 1.0])
          case .ladogaBottom:
              HappyGradients.linear(colors: ["ebc0fd", "d9ded8"], locations: [0.0, 1.0])
          case .lemonGate:
              HappyGradients.linear(colors: ["96fbc4", "f9f586"], locations: [0.0, 1.0])
          case .itmeoBranding:
              HappyGradients.linear(colors: ["2af598", "009efd"], locations: [0.0, 1.0])
          case .zeusMiracle:
              HappyGradients.linear(colors: ["cd9cf2", "f6f3ff"], locations: [0.0, 1.0])
          case .oldHat:
              HappyGradients.linear(colors: ["e4afcb", "b8cbb8", "b8cbb8", "e2c58b", "c2ce9c", "7edbdc"], locations: [0.0, 0.0, 0.0, 0.3, 0.64, 1.0])
          case .starWine:
              HappyGradients.linear(colors: ["b8cbb8", "b8cbb8", "b465da", "cf6cc9", "ee609c", "ee609c"], locations: [0.0, 0.0, 0.0, 0.33, 0.66, 1.0])
          case .deepBlue:
              HappyGradients.linear(colors: ["6a11cb", "2575fc"], locations: [0.0, 1.0])
          case .happyAcid:
              HappyGradients.linear(colors: ["37ecba", "72afd3"], locations: [0.0, 1.0])
          case .awesomePine:
              HappyGradients.linear(colors: ["ebbba7", "cfc7f8"], locations: [0.0, 1.0])
          case .newYork:
              HappyGradients.linear(colors: ["fff1eb", "ace0f9"], locations: [0.0, 1.0])
          case .shyRainbow:
              HappyGradients.linear(colors: ["eea2a2", "bbc1bf", "57c6e1", "b49fda", "7ac5d8"], locations: [0.0, 0.19, 0.42, 0.79, 1.0])
          case .mixedHopes:
              HappyGradients.linear(colors: ["c471f5", "fa71cd"], locations: [0.0, 1.0])
          case .flyHigh:
              HappyGradients.linear(colors: ["48c6ef", "6f86d6"], locations: [0.0, 1.0])
          case .strongBliss:
              HappyGradients.linear(colors: ["f78ca0", "f9748f", "fd868c", "fe9a8b"], locations: [0.0, 0.19, 0.6, 1.0])
          case .freshMilk:
              HappyGradients.linear(colors: ["feada6", "f5efef"], locations: [0.0, 1.0])
          case .snowAgain:
              HappyGradients.linear(colors: ["e6e9f0", "eef1f5"], locations: [0.0, 1.0])
          case .februaryInk:
              HappyGradients.linear(colors: ["accbee", "e7f0fd"], locations: [0.0, 1.0])
          case .kindSteel:
              HappyGradients.linear(colors: ["e9defa", "fbfcdb"], locations: [0.0, 1.0])
          case .softGrass:
              HappyGradients.linear(colors: ["c1dfc4", "deecdd"], locations: [0.0, 1.0])
          case .grownEarly:
              HappyGradients.linear(colors: ["0ba360", "3cba92"], locations: [0.0, 1.0])
          case .sharpBlues:
              HappyGradients.linear(colors: ["00c6fb", "005bea"], locations: [0.0, 1.0])
          case .shadyWater:
              HappyGradients.linear(colors: ["74ebd5", "9face6"], locations: [0.0, 1.0])
          case .dirtyBeauty:
              HappyGradients.linear(colors: ["6a85b6", "bac8e0"], locations: [0.0, 1.0])
          case .greatWhale:
              HappyGradients.linear(colors: ["a3bded", "6991c7"], locations: [0.0, 1.0])
          case .teenNotebook:
              HappyGradients.linear(colors: ["9795f0", "fbc8d4"], locations: [0.0, 1.0])
          case .politeRumors:
              HappyGradients.linear(colors: ["a7a6cb", "8989ba", "8989ba"], locations: [0.0, 0.52, 1.0])
          case .sweetPeriod:
              HappyGradients.linear(colors: ["3f51b1", "5a55ae", "7b5fac", "8f6aae", "a86aa4", "cc6b8e", "f18271", "f3a469", "f7c978"], locations: [0.0, 0.13, 0.25, 0.38, 0.5, 0.62, 0.75, 0.87, 1.0])
          case .wideMatrix:
              HappyGradients.linear(colors: ["fcc5e4", "fda34b", "ff7882", "c8699e", "7046aa", "0c1db8", "020f75"], locations: [0.0, 0.15, 0.35, 0.52, 0.71, 0.87, 1.0])
          case .softCherish:
              HappyGradients.linear(colors: ["dbdcd7", "dddcd7", "e2c9cc", "e7627d", "b8235a", "801357", "3d1635", "1c1a27"], locations: [0.0, 0.24, 0.30, 0.46, 0.59, 0.71, 0.84, 1.0])
          case .redSalvation:
              HappyGradients.linear(colors: ["f43b47", "453a94"], locations: [0.0, 1.0])
          case .burningSpring:
              HappyGradients.linear(colors: ["4fb576", "44c489", "28a9ae", "28a2b7", "4c7788", "6c4f63", "432c39"], locations: [0.0, 0.30, 0.46, 0.59, 0.71, 0.86, 1.0])
          case .nightParty:
              HappyGradients.linear(colors: ["0250c5", "d43f8d"], locations: [0.0, 1.0])
          case .skyGlider:
              HappyGradients.linear(colors: ["88d3ce", "6e45e2"], locations: [0.0, 1.0])
          case .heavenPeach:
              HappyGradients.linear(colors: ["d9afd9", "97d9e1"], locations: [0.0, 1.0])
          case .purpleDivision:
              HappyGradients.linear(colors: ["7028e4", "e5b2ca"], locations: [0.0, 1.0])
          case .aquaSplash:
              HappyGradients.linear(colors: ["13547a", "80d0c7"], locations: [0.0, 1.0])
          case .spikyNaga:
              HappyGradients.linear(colors: ["505285", "585e92", "65689f", "7474b0", "7e7ebb", "8389c7", "9795d4", "a2a1dc", "b5aee4"], locations: [0.0, 0.12, 0.25, 0.37, 0.50, 0.62, 0.75, 0.87, 1.0])
          case .loveKiss:
              HappyGradients.linear(colors: ["ff0844", "ffb199"], locations: [0.0, 1.0])
          case .cleanMirror:
              HappyGradients.linear(colors: ["93a5cf", "e4efe9"], locations: [0.0, 1.0])
          case .premiumDark:
              HappyGradients.linear(colors: ["434343", "000000"], locations: [0.0, 1.0])
          case .coldEvening:
              HappyGradients.linear(colors: ["0c3483", "a2b6df", "6b8cce", "a2b6df"], locations: [0.0, 1.0, 1.0, 1.0])
          case .cochitiLake:
              HappyGradients.linear(colors: ["93a5cf", "e4efe9"], locations: [0.0, 1.0])
          case .summerGames:
              HappyGradients.linear(colors: ["92fe9d", "00c9ff"], locations: [0.0, 1.0])
          case .passionateBed:
              HappyGradients.linear(colors: ["ff758c", "ff7eb3"], locations: [0.0, 1.0])
          case .mountainRock:
              HappyGradients.linear(colors: ["868f96", "596164"], locations: [0.0, 1.0])
          case .desertHump:
              HappyGradients.linear(colors: ["c79081", "dfa579"], locations: [0.0, 1.0])
          case .jungleDay:
              HappyGradients.linear(colors: ["8baaaa", "ae8b9c"], locations: [0.0, 1.0])
          case .phoenixStart:
              HappyGradients.linear(colors: ["f83600", "f9d423"], locations: [0.0, 1.0])
          case .octoberSilence:
              HappyGradients.linear(colors: ["b721ff", "21d4fd"], locations: [0.0, 1.0])
          case .farawayRiver:
              HappyGradients.linear(colors: ["6e45e2", "88d3ce"], locations: [0.0, 1.0])
          case .alchemistLab:
              HappyGradients.linear(colors: ["d558c8", "24d292"], locations: [0.0, 1.0])
          case .overSun:
              HappyGradients.linear(colors: ["abecd6", "fbed96"], locations: [0.0, 1.0])
          case .premiumWhite:
              HappyGradients.linear(colors: ["d5d4d0", "d5d4d0", "eeeeec", "efeeec", "e9e9e7"], locations: [0.0, 0.01, 0.31, 0.75, 1.0])
          case .marsParty:
              HappyGradients.linear(colors: ["5f72bd", "9b23ea"], locations: [0.0, 1.0])
          case .eternalConstance:
              HappyGradients.linear(colors: ["09203f", "537895"], locations: [0.0, 1.0])
          case .japanBlush:
              HappyGradients.linear(colors: ["ddd6f3", "faaca8", "faaca8"], locations: [0.0, 1.0, 1.0])
          case .smilingRain:
              HappyGradients.linear(colors: ["dcb0ed", "99c99c"], locations: [0.0, 1.0])
          case .cloudyApple:
              HappyGradients.linear(colors: ["f3e7e9", "e3eeff", "e3eeff"], locations: [0.0, 0.99, 1.0])
          case .bigMango:
              HappyGradients.linear(colors: ["c71d6f", "d09693"], locations: [0.0, 1.0])
          case .healthyWater:
              HappyGradients.linear(colors: ["96deda", "50c9c3"], locations: [0.0, 1.0])
          case .amourAmour:
              HappyGradients.linear(colors: ["f77062", "fe5196"], locations: [0.0, 1.0])
          case .riskyConcrete:
              HappyGradients.linear(colors: ["c4c5c7", "dcdddf", "ebebeb"], locations: [0.0, 0.52, 1.0])
          case .strongStick:
              HappyGradients.linear(colors: ["a8caba", "5d4157"], locations: [0.0, 1.0])
          case .viciousStance:
              HappyGradients.linear(colors: ["29323c", "485563"], locations: [0.0, 1.0])
          case .paloAlto:
              HappyGradients.linear(colors: ["16a085", "f4d03f"], locations: [0.0, 1.0])
          case .happyMemories:
              HappyGradients.linear(colors: ["ff5858", "f09819"], locations: [0.0, 1.0])
          case .midnightBloom:
              HappyGradients.linear(colors: ["2b5876", "4e4376"], locations: [0.0, 1.0])
          case .crystalline:
              HappyGradients.linear(colors: ["00cdac", "8ddad5"], locations: [0.0, 1.0])
          case .partyBliss:
              HappyGradients.linear(colors: ["4481eb", "04befe"], locations: [0.0, 1.0])
          case .confidentCloud:
              HappyGradients.linear(colors: ["dad4ec", "dad4ec", "f3e7e9"], locations: [0.0, 0.01, 1.0])
          case .leCocktail:
              HappyGradients.linear(colors: ["874da2", "c43a30"], locations: [0.0, 1.0])
          case .riverCity:
              HappyGradients.linear(colors: ["4481eb", "04befe"], locations: [0.0, 1.0])
          case .frozenBerry:
              HappyGradients.linear(colors: ["e8198b", "c7eafd"], locations: [0.0, 1.0])
          case .childCare:
              HappyGradients.linear(colors: ["f794a4", "fdd6bd"], locations: [0.0, 1.0])
          case .flyingLemon:
              HappyGradients.linear(colors: ["64b3f4", "c2e59c"], locations: [0.0, 1.0])
          case .newRetrowave:
              HappyGradients.linear(colors: ["3b41c5", "a981bb", "ffc8a9"], locations: [0.0, 0.49, 1.0])
          case .hiddenJaguar:
              HappyGradients.linear(colors: ["0fd850", "f9f047"], locations: [0.0, 1.0])
          case .aboveTheSky:
              HappyGradients.linear(colors: ["d3d3d3", "d3d3d3", "e0e0e0", "efefef", "d9d9d9", "bcbcbc"], locations: [0.0, 0.01, 0.26, 0.48, 0.75, 1.0])
          case .nega:
              HappyGradients.linear(colors: ["ee9ca7", "ffdde1"], locations: [0.0, 1.0])
          case .denseWater:
              HappyGradients.linear(colors: ["3ab5b0", "3d99be", "56317a"], locations: [0.0, 0.31, 1.0])
          case .seashore:
              HappyGradients.linear(colors: ["209cff", "68e0cf"], locations: [0.0, 1.0])
          case .marbleWall:
              HappyGradients.linear(colors: ["bdc2e8", "bdc2e8", "e6dee9"], locations: [0.0, 0.01, 1.0])
          case .cheerfulCaramel:
              HappyGradients.linear(colors: ["e6b980", "eacda3"], locations: [0.0, 1.0])
          case .nightSky:
              HappyGradients.linear(colors: ["1e3c72", "1e3c72", "2a5298"], locations: [0.0, 0.01, 1.0])
          case .magicLake:
              HappyGradients.linear(colors: ["d5dee7", "ffafbd", "c9ffbf"], locations: [0.0, 0.0, 1.0])
          case .youngGrass:
              HappyGradients.linear(colors: ["9be15d", "00e3ae"], locations: [0.0, 1.0])
          case .colorfulPeach:
              HappyGradients.linear(colors: ["ed6ea0", "ec8c69"], locations: [0.0, 1.0])
          case .gentleCare:
              HappyGradients.linear(colors: ["ffc3a0", "ffafbd"], locations: [0.0, 1.0])
          case .plumBath:
              HappyGradients.linear(colors: ["cc208e", "6713d2"], locations: [0.0, 1.0])
          case .happyUnicorn:
              HappyGradients.linear(colors: ["b3ffab", "12fff7"], locations: [0.0, 1.0])
          case .africanField:
              HappyGradients.linear(colors: ["65bd60", "5ac1a8", "3ec6ed", "b7ddb7", "fef381"], locations: [0.0, 0.25, 0.50, 0.75, 1.0])
          case .solidStone:
              HappyGradients.linear(colors: ["243949", "517fa4"], locations: [0.0, 1.0])
          case .orangeJuice:
              HappyGradients.linear(colors: ["fc6076", "ff9a44"], locations: [0.0, 1.0])
          case .glassWater:
              HappyGradients.linear(colors: ["dfe9f3", "ffffff"], locations: [0.0, 1.0])
          case .northMiracle:
              HappyGradients.linear(colors: ["00dbde", "fc00ff"], locations: [0.0, 1.0])
          case .fruitBlend:
              HappyGradients.linear(colors: ["f9d423", "ff4e50"], locations: [0.0, 1.0])
          case .millenniumPine:
              HappyGradients.linear(colors: ["50cc7f", "f5d100"], locations: [0.0, 1.0])
          case .highFlight:
              HappyGradients.linear(colors: ["0acffe", "495aff"], locations: [0.0, 1.0])
          case .moleHall:
              HappyGradients.linear(colors: ["616161", "9bc5c3"], locations: [0.0, 1.0])
          case .spaceShift:
              HappyGradients.linear(colors: ["3d3393", "2b76b9", "2cacd1", "35eb93"], locations: [0.0, 0.37, 0.65, 1.0])
          case .forestInei:
              HappyGradients.linear(colors: ["df89b5", "bfd9fe"], locations: [0.0, 1.0])
          case .royalGarden:
              HappyGradients.linear(colors: ["ed6ea0", "ec8c69"], locations: [0.0, 1.0])
          case .richMetal:
              HappyGradients.linear(colors: ["d7d2cc", "304352"], locations: [0.0, 1.0])
          case .juicyCake:
              HappyGradients.linear(colors: ["e14fad", "f9d423"], locations: [0.0, 1.0])
          case .smartIndigo:
              HappyGradients.linear(colors: ["b224ef", "7579ff"], locations: [0.0, 1.0])
          case .sandStrike:
              HappyGradients.linear(colors: ["c1c161", "c1c161", "d4d4b1"], locations: [0.0, 0.0, 1.0])
          case .norseBeauty:
              HappyGradients.linear(colors: ["ec77ab", "7873f5"], locations: [0.0, 1.0])
          case .aquaGuidance:
              HappyGradients.linear(colors: ["007adf", "00ecbc"], locations: [0.0, 1.0])
          case .sunVeggie:
              HappyGradients.linear(colors: ["20E2D7", "F9FEA5"], locations: [0.0, 1.0])
          case .seaLord:
              HappyGradients.linear(colors: ["2CD8D5", "C5C1FF", "FFBAC3"], locations: [0.0, 0.56, 1.0])
          case .blackSea:
              HappyGradients.linear(colors: ["2CD8D5", "6B8DD6", "8E37D7"], locations: [0.0, 0.48, 1.0])
          case .grassShampoo:
              HappyGradients.linear(colors: ["DFFFCD", "90F9C4", "39F3BB"], locations: [0.0, 0.48, 1.0])
          case .landingAircraft:
              HappyGradients.linear(colors: ["5D9FFF", "B8DCFF", "6BBBFF"], locations: [0.0, 0.48, 1.0])
          case .witchDance:
              HappyGradients.linear(colors: ["A8BFFF", "884D80"], locations: [0.0, 1.0])
          case .sleeplessNight:
              HappyGradients.linear(colors: ["5271C4", "B19FFF", "ECA1FE"], locations: [0.0, 0.48, 1.0])
          case .angelCare:
              HappyGradients.linear(colors: ["FFE29F", "FFA99F", "FF719A"], locations: [0.0, 0.48, 1.0])
          case .crystalRiver:
              HappyGradients.linear(colors: ["22E1FF", "1D8FE1", "625EB1"], locations: [0.0, 0.48, 1.0])
          case .softLipstick:
              HappyGradients.linear(colors: ["B6CEE8", "F578DC"], locations: [0.0, 1.0])
          case .saltMountain:
              HappyGradients.linear(colors: ["FFFEFF", "D7FFFE"], locations: [0.0, 1.0])
          case .perfectWhite:
              HappyGradients.linear(colors: ["E3FDF5", "FFE6FA"], locations: [0.0, 1.0])
          case .freshOasis:
              HappyGradients.linear(colors: ["7DE2FC", "B9B6E5"], locations: [0.0, 1.0])
          case .strictNovember:
              HappyGradients.linear(colors: ["CBBACC", "2580B3"], locations: [0.0, 1.0])
          case .morningSalad:
              HappyGradients.linear(colors: ["B7F8DB", "50A7C2"], locations: [0.0, 1.0])
          case .deepRelief:
              HappyGradients.linear(colors: ["7085B6", "87A7D9", "DEF3F8"], locations: [0.0, 0.50, 1.0])
          case .seaStrike:
              HappyGradients.linear(colors: ["77FFD2", "6297DB", "1EECFF"], locations: [0.0, 0.48, 1.0])
          case .nightCall:
              HappyGradients.linear(colors: ["AC32E4", "7918F2", "4801FF"], locations: [0.0, 0.48, 1.0])
          case .supremeSky:
              HappyGradients.linear(colors: ["D4FFEC", "57F2CC", "4596FB"], locations: [0.0, 0.48, 1.0])
          case .lightBlue:
              HappyGradients.linear(colors: ["9EFBD3", "57E9F2", "45D4FB"], locations: [0.0, 0.48, 1.0])
          case .mindCrawl:
              HappyGradients.linear(colors: ["473B7B", "3584A7", "30D2BE"], locations: [0.0, 0.51, 1.0])
          case .lilyMeadow:
              HappyGradients.linear(colors: ["65379B", "886AEA", "6457C6"], locations: [0.0, 0.53, 1.0])
          case .sugarLollipop:
              HappyGradients.linear(colors: ["A445B2", "D41872", "FF0066"], locations: [0.0, 0.52, 1.0])
          case .sweetDessert:
              HappyGradients.linear(colors: ["7742B2", "F180FF", "FD8BD9"], locations: [0.0, 0.52, 1.0])
          case .magicRay:
              HappyGradients.linear(colors: ["FF3CAC", "562B7C", "2B86C5"], locations: [0.0, 0.52, 1.0])
          case .teenParty:
              HappyGradients.linear(colors: ["FF057C", "8D0B93", "321575"], locations: [0.0, 0.50, 1.0])
          case .frozenHeat:
              HappyGradients.linear(colors: ["FF057C", "7C64D5", "4CC3FF"], locations: [0.0, 0.48, 1.0])
          case .gagarinView:
              HappyGradients.linear(colors: ["69EACB", "EACCF8", "6654F1"], locations: [0.0, 0.48, 1.0])
          case .fabledSunset:
              HappyGradients.linear(colors: ["231557", "44107A", "FF1361", "FFF800"], locations: [0.0, 0.29, 0.67, 1.0])
          case .perfectBlue:
              HappyGradients.linear(colors: ["3D4E81", "5753C9", "6E7FF3"], locations: [0.0, 0.48, 1.0])
        }
    }
}

extension HappyGradients {
    static func linear(colors: [String], locations: [Double]) -> LinearGradient {
        var stops: [Gradient.Stop] = []
        for (index, color) in colors.enumerated() {
            stops.append(Gradient.Stop(color: Color(uiColor: UIColor(hex: color)), location: locations[index]))
        }
        
        return LinearGradient(gradient: Gradient(stops: stops), startPoint: .top, endPoint: .bottom)
    }
}
