//
//  _1App.swift
//  01
//
//  Created by MacBook Air on 18/08/24.
//

import SwiftUI

@main
struct _1App: App {
    var body: some Scene {
        DocumentGroup(newDocument: _1Document()) { file in
            ContentView(document: file.$document)
        }
    }
}
