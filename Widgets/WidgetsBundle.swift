//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by Peter Oesteritz on 05.03.24.
//

import SwiftUI
import WidgetKit

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        MomentsWidget()
        MotivationWidget()
    }
}
