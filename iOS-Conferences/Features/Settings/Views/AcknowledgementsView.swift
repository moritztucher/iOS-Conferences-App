import SwiftUI

struct AcknowledgementsView: View {
    @State private var selectedItem: Item?

    private let items: [Item] = [
        Item(
            id: "twostraws-wwdc",
            title: "twostraws/wwdc",
            detail: "WWDC-week event list curated by Paul Hudson and the community — source of much of Dubdub's WWDC data.",
            url: URL(string: "https://github.com/twostraws/wwdc")!
        )
    ]

    var body: some View {
        List(items) { item in
            Button {
                selectedItem = item
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .foregroundStyle(.primary)
                    Text(item.detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .scrollContentBackground(.hidden)
        .brandBackground()
        .navigationTitle("Acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedItem) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Item

extension AcknowledgementsView {
    fileprivate struct Item: Identifiable {
        let id: String
        let title: String
        let detail: String
        let url: URL
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsView()
    }
}
