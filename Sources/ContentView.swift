//
//  ContentView.swift
//  IPRange
//
//  Created by Mac on 8/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    var body: some View {
        AddressGridView(addresses: viewModel.addresses)
    }
}

#Preview {
    ContentView()
}
