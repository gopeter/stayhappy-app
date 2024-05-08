//
//  WidgetSize.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 08.05.24.
//

import UIKit
import WidgetKit

func getWidgetSize(for family: WidgetFamily) -> CGSize {
    switch family {
        case .systemSmall:
            switch UIScreen.main.bounds.size {
                case CGSize(width: 430, height: 932): return CGSize(width: 170, height: 170)
                case CGSize(width: 428, height: 926): return CGSize(width: 170, height: 170)
                case CGSize(width: 414, height: 896): return CGSize(width: 169, height: 169)
                case CGSize(width: 414, height: 736): return CGSize(width: 159, height: 159)
                case CGSize(width: 393, height: 852): return CGSize(width: 158, height: 158)
                case CGSize(width: 390, height: 844): return CGSize(width: 158, height: 158)
                case CGSize(width: 375, height: 812): return CGSize(width: 155, height: 155)
                case CGSize(width: 375, height: 667): return CGSize(width: 148, height: 148)
                case CGSize(width: 360, height: 780): return CGSize(width: 155, height: 155)
                case CGSize(width: 320, height: 568): return CGSize(width: 141, height: 141)
                default: return CGSize(width: 155, height: 155)
            }
        case .systemMedium:
            switch UIScreen.main.bounds.size {
                case CGSize(width: 430, height: 932): return CGSize(width: 364, height: 170)
                case CGSize(width: 428, height: 926): return CGSize(width: 364, height: 170)
                case CGSize(width: 414, height: 896): return CGSize(width: 360, height: 169)
                case CGSize(width: 414, height: 736): return CGSize(width: 348, height: 157)
                case CGSize(width: 393, height: 852): return CGSize(width: 338, height: 158)
                case CGSize(width: 390, height: 844): return CGSize(width: 338, height: 158)
                case CGSize(width: 375, height: 812): return CGSize(width: 329, height: 155)
                case CGSize(width: 375, height: 667): return CGSize(width: 321, height: 148)
                case CGSize(width: 360, height: 780): return CGSize(width: 329, height: 155)
                case CGSize(width: 320, height: 568): return CGSize(width: 292, height: 141)
                default: return CGSize(width: 329, height: 155)
            }

        default: return CGSize(width: 329, height: 155)
    }
}
