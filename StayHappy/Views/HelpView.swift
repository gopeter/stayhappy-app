//
//  HelpView.swift
//  StayHappy
//
//  Created by Peter Oesteritz on 01.02.24.
//

/*

 ---

 Willkommen bei StayHappy,
 ...deiner kleinen Gedächtnisstütze für die guten Dinge im Leben
 ...deinem Merkzettel für die guten Dinge im Leben

 [Hintergrundgeschichte] [Tour starten -->]

 ---

 In depressiven Episoden geht der Fokus auf die guten Dinge schnell verloren.
 StayHappy erinnert dich mit Hilfe von Widgets immer wieder daran, dass da noch mehr ist.

 <Bild vom ausgefüllten Widget>

 ---

 Notiere dir kleine Momente, auf die du dich freuen kannst. Die neue Folge deiner Lieblings-Serie, ein Bad oder etwas Leckeres zu Essen. Größere Momente, wie ein Konzertbesuch, das anstehende BBQ oder der letzte Urlaub können als Highlight markiert und mit einem Bild versehen werden.

 <Bild von ... ?>

 ---

 Schreibe dir auf, welche Ressourcen dich jeden Tag berreichern könnten. Der leckere Cappuchino jeden Morgen, der Duft deines Lieblingsparfums oder liebe Menschen in deiner Nähe.

 <Bild von ...?>

 ---

 StayHappy nimmt all diese Informationen und zeigt dir in verschiedenen Widgets eine clevere Auswahl an, die dir helfen kann, etwas Hoffnung zu fassen und dich auf den nächsten Tag zu freuen.

 [Los geht's -->]

 */

import SwiftUI

struct HelpView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("help")
                Text("thanks")
                Text("buy_me_coffee")
            }.background(Color("AppBackgroundColor"))
                .scrollContentBackground(.hidden)
                .navigationTitle("help")
                .toolbarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HelpView()
}
