//
//  AddressGridView.swift
//  IPRanges
//
//  Created by Mac on 14/12/25.
//

import SwiftUI

// MARK: GridCellView
struct GridCellView: View {
    var value: String
    var body: some View {
        Text(value)
    }
}

// MARK: AddressGridView
struct AddressGridView: View {
    var addresses: [AddressElement]
    @State var selectedItem: AddressElement?
    let columns = [
        GridItem(.flexible(minimum: 160, maximum: 160)),
        GridItem(.flexible(minimum: 160, maximum: 160)),
        GridItem(.flexible(minimum: 50, maximum: 50))
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                // Add the Grid Header
                GridRow {
                    GridCellView(value: "Address")
                        .font(.subheadline)
                    GridCellView(value: "Country")
                        .font(.subheadline)
                    GridCellView(value: "Flag")
                        .font(.subheadline)
                    
                }
                ForEach(addresses) { item in
                    GridRow {
                        GridCellView(value: "\(item.address)")
                            .font(.caption)
                        GridCellView(value: "\(item.country)")
                            .font(.caption)
                        GridCellView(value: "\(item.flag)")
                            .font(.caption)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.selectedItem = item
                    }
                }
            }.sheet(item: $selectedItem) { item in
                AddressDetailView(address: item)
            }
        }
    }
}
