//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        MomentsWidget()
        MotivationWidget()
    }
}
