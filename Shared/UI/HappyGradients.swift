//
//  HappyGradients.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 22.02.24.
//

import Hue
import SmoothGradient
import SwiftUI

enum HappyGradients: String, CaseIterable {
    case warmFlame
    case nightFade
    case springWarmth
    case juicyPeach
    case ladyLips
    case sunnyMorning
    case rainyAshville
    case winterNeva
    case dustyGrass
    case temptingAzure
    case amyCrisp
    case meanFruit
    case softBlue
    case ripeMalinka
    case malibuBeach
    case trueSunset
    case nearMoon
    case saintPetersburg
    case plumPlate
    case happyFisher
    case ladogaBottom
    case lemonGate
    case itmeoBranding
    case zeusMiracle
    case oldHat
    case starWine
    case deepBlue
    case awesomePine
    case newYork
    case mixedHopes
    case flyHigh
    case strongBliss
    case freshMilk
    case grownEarly
    case sharpBlues
    case dirtyBeauty
    case greatWhale
    case teenNotebook
    case politeRumors
    case redSalvation
    case nightParty
    case skyGlider
    case heavenPeach
    case purpleDivision
    case aquaSplash
    case spikyNaga
    case loveKiss
    case cleanMirror
    case coldEvening
    case cochitiLake
    case summerGames
    case passionateBed
    case phoenixStart
    case octoberSilence
    case farawayRiver
    case overSun
    case marsParty
    case eternalConstance
    case japanBlush
    case bigMango
    case healthyWater
    case amourAmour
    case paloAlto
    case happyMemories
    case crystalline
    case partyBliss
    case leCocktail
    case riverCity
    case frozenBerry
    case childCare
    case flyingLemon
    case newRetrowave
    case hiddenJaguar
    case nega
    case seashore
    case cheerfulCaramel
    case nightSky
    case youngGrass
    case colorfulPeach
    case gentleCare
    case plumBath
    case happyUnicorn
    case solidStone
    case orangeJuice
    case fruitBlend
    case millenniumPine
    case highFlight
    case spaceShift
    case forestInei
    case royalGarden
    case juicyCake
    case smartIndigo
    case sandStrike
    case norseBeauty
    case aquaGuidance
    case sunVeggie
    case seaLord
    case blackSea
    case grassShampoo
    case sleeplessNight
    case angelCare
    case softLipstick
    case freshOasis
    case strictNovember
    case morningSalad
    case deepRelief
    case nightCall
    case supremeSky
    case lightBlue
    case mindCrawl
    case sugarLollipop
    case sweetDessert
    case teenParty
    case frozenHeat
    case gagarinView
    case fabledSunset
}

extension HappyGradients {
    func baseColors(name: HappyGradients) -> [String] {
        switch name {
        case .warmFlame:
            ["ff9a9e", "fad0c4"]
        case .nightFade:
            ["a18cd1", "fbc2eb"]
        case .springWarmth:
            ["fad0c4", "ffd1ff"]
        case .juicyPeach:
            ["ffecd2", "fcb69f"]
        case .ladyLips:
            ["ff9a9e", "fecfef"]
        case .sunnyMorning:
            ["f6d365", "fda085"]
        case .rainyAshville:
            ["fbc2eb", "a6c1ee"]
        case .winterNeva:
            ["a1c4fd", "c2e9fb"]
        case .dustyGrass:
            ["d4fc79", "96e6a1"]
        case .temptingAzure:
            ["84fab0", "8fd3f4"]
        case .amyCrisp:
            ["a6c0fe", "f68084"]
        case .meanFruit:
            ["fccb90", "d57eeb"]
        case .softBlue:
            ["e0c3fc", "8ec5fc"]
        case .ripeMalinka:
            ["f093fb", "f5576c"]
        case .malibuBeach:
            ["4facfe", "00f2fe"]
        case .trueSunset:
            ["fa709a", "fee140"]
        case .nearMoon:
            ["5ee7df", "b490ca"]
        case .saintPetersburg:
            ["f5f7fa", "c3cfe2"]
        case .plumPlate:
            ["667eea", "764ba2"]
        case .happyFisher:
            ["89f7fe", "66a6ff"]
        case .ladogaBottom:
            ["ebc0fd", "d9ded8"]
        case .lemonGate:
            ["96fbc4", "f9f586"]
        case .itmeoBranding:
            ["2af598", "009efd"]
        case .zeusMiracle:
            ["cd9cf2", "f6f3ff"]
        case .oldHat:
            ["e4afcb", "7edbdc"]
        case .starWine:
            ["b8cbb8", "ee609c"]
        case .deepBlue:
            ["6a11cb", "2575fc"]
        case .awesomePine:
            ["ebbba7", "cfc7f8"]
        case .newYork:
            ["fff1eb", "ace0f9"]
        case .mixedHopes:
            ["c471f5", "fa71cd"]
        case .flyHigh:
            ["48c6ef", "6f86d6"]
        case .strongBliss:
            ["f78ca0", "fe9a8b"]
        case .freshMilk:
            ["feada6", "f5efef"]
        case .grownEarly:
            ["0ba360", "3cba92"]
        case .sharpBlues:
            ["00c6fb", "005bea"]
        case .dirtyBeauty:
            ["6a85b6", "bac8e0"]
        case .greatWhale:
            ["a3bded", "6991c7"]
        case .teenNotebook:
            ["9795f0", "fbc8d4"]
        case .politeRumors:
            ["a7a6cb", "8989ba"]
        case .redSalvation:
            ["f43b47", "453a94"]
        case .nightParty:
            ["0250c5", "d43f8d"]
        case .skyGlider:
            ["88d3ce", "6e45e2"]
        case .heavenPeach:
            ["d9afd9", "97d9e1"]
        case .purpleDivision:
            ["7028e4", "e5b2ca"]
        case .aquaSplash:
            ["13547a", "80d0c7"]
        case .spikyNaga:
            ["505285", "b5aee4"]
        case .loveKiss:
            ["ff0844", "ffb199"]
        case .cleanMirror:
            ["93a5cf", "e4efe9"]
        case .coldEvening:
            ["0c3483", "a2b6df"]
        case .cochitiLake:
            ["93a5cf", "e4efe9"]
        case .summerGames:
            ["92fe9d", "00c9ff"]
        case .passionateBed:
            ["ff758c", "ff7eb3"]
        case .phoenixStart:
            ["f83600", "f9d423"]
        case .octoberSilence:
            ["b721ff", "21d4fd"]
        case .farawayRiver:
            ["6e45e2", "88d3ce"]
        case .overSun:
            ["abecd6", "fbed96"]
        case .marsParty:
            ["5f72bd", "9b23ea"]
        case .eternalConstance:
            ["09203f", "537895"]
        case .japanBlush:
            ["ddd6f3", "faaca8"]
        case .bigMango:
            ["c71d6f", "d09693"]
        case .healthyWater:
            ["96deda", "50c9c3"]
        case .amourAmour:
            ["f77062", "fe5196"]
        case .paloAlto:
            ["16a085", "f4d03f"]
        case .happyMemories:
            ["ff5858", "f09819"]
        case .crystalline:
            ["00cdac", "8ddad5"]
        case .partyBliss:
            ["4481eb", "04befe"]
        case .leCocktail:
            ["874da2", "c43a30"]
        case .riverCity:
            ["4481eb", "04befe"]
        case .frozenBerry:
            ["e8198b", "c7eafd"]
        case .childCare:
            ["f794a4", "fdd6bd"]
        case .flyingLemon:
            ["64b3f4", "c2e59c"]
        case .newRetrowave:
            ["3b41c5", "ffc8a9"]
        case .hiddenJaguar:
            ["0fd850", "f9f047"]
        case .nega:
            ["ee9ca7", "ffdde1"]
        case .seashore:
            ["209cff", "68e0cf"]
        case .cheerfulCaramel:
            ["e6b980", "eacda3"]
        case .nightSky:
            ["1e3c72", "2a5298"]
        case .youngGrass:
            ["9be15d", "00e3ae"]
        case .colorfulPeach:
            ["ed6ea0", "ec8c69"]
        case .gentleCare:
            ["ffc3a0", "ffafbd"]
        case .plumBath:
            ["cc208e", "6713d2"]
        case .happyUnicorn:
            ["b3ffab", "12fff7"]
        case .solidStone:
            ["243949", "517fa4"]
        case .orangeJuice:
            ["fc6076", "ff9a44"]
        case .fruitBlend:
            ["f9d423", "ff4e50"]
        case .millenniumPine:
            ["50cc7f", "f5d100"]
        case .highFlight:
            ["0acffe", "495aff"]
        case .spaceShift:
            ["3d3393", "35eb93"]
        case .forestInei:
            ["df89b5", "bfd9fe"]
        case .royalGarden:
            ["ed6ea0", "ec8c69"]
        case .juicyCake:
            ["e14fad", "f9d423"]
        case .smartIndigo:
            ["b224ef", "7579ff"]
        case .sandStrike:
            ["c1c161", "d4d4b1"]
        case .norseBeauty:
            ["ec77ab", "7873f5"]
        case .aquaGuidance:
            ["007adf", "00ecbc"]
        case .sunVeggie:
            ["20E2D7", "F9FEA5"]
        case .seaLord:
            ["2CD8D5", "FFBAC3"]
        case .blackSea:
            ["2CD8D5", "8E37D7"]
        case .grassShampoo:
            ["DFFFCD", "39F3BB"]
        case .sleeplessNight:
            ["5271C4", "ECA1FE"]
        case .angelCare:
            ["FFE29F", "FF719A"]
        case .softLipstick:
            ["B6CEE8", "F578DC"]
        case .freshOasis:
            ["7DE2FC", "B9B6E5"]
        case .strictNovember:
            ["CBBACC", "2580B3"]
        case .morningSalad:
            ["B7F8DB", "50A7C2"]
        case .deepRelief:
            ["7085B6", "DEF3F8"]
        case .nightCall:
            ["AC32E4", "4801FF"]
        case .supremeSky:
            ["D4FFEC", "4596FB"]
        case .lightBlue:
            ["9EFBD3", "45D4FB"]
        case .mindCrawl:
            ["473B7B", "30D2BE"]
        case .sugarLollipop:
            ["A445B2", "FF0066"]
        case .sweetDessert:
            ["7742B2", "FD8BD9"]
        case .teenParty:
            ["FF057C", "321575"]
        case .frozenHeat:
            ["FF057C", "4CC3FF"]
        case .gagarinView:
            ["69EACB", "6654F1"]
        case .fabledSunset:
            ["231557", "FFF800"]
        }
    }

    func radial(startRadius: CGFloat, endRadius: CGFloat) -> RadialGradient {
        let colors = baseColors(name: self)

        return RadialGradient(
            gradient: Gradient(
                colors: smoothColors(
                    fromColor: UIColor(hex: colors[0]),
                    toColor: UIColor(hex: colors[1])
                )
            ),
            center: .topLeading,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    func linear() -> LinearGradient {
        let colors = baseColors(name: self)

        return LinearGradient(gradient: Gradient(colors: smoothColors(
            fromColor: UIColor(hex: colors[0]),
            toColor: UIColor(hex: colors[1])
        )
        ), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension HappyGradients {
    func smoothColors(fromColor: UIColor, toColor: UIColor) -> [Color] {
        return SmoothGradientGenerator()
            .generate(
                from: fromColor,
                to: toColor,
                interpolation: .hcl,
                precision: .high
            ).map { Color(uiColor: $0) }
    }
}
