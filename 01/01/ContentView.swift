//
//  ContentView.swift
//  01
//
//  Created by MacBook Air on 18/08/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: _1Document

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(_1Document()))
}
