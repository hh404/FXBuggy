import SwiftUI

struct CurrencyListView: View {
    @ObservedObject var viewModel: CurrencyListViewModel

    var body: some View {
        NavigationStack {
            List {
                if let msg = viewModel.errorMessage {
                    Text(msg).foregroundStyle(.red)
                }
                ForEach(viewModel.filtered) { c in
                    NavigationLink("\(c.code) - \(c.name)") {
                        QuoteView(
                            viewModel: QuoteViewModel(service: RateService(), toCode: c.code),
                            title: c.code
                        )
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                }
            }
            .navigationTitle("Currencies")
            .searchable(text: $viewModel.searchText, prompt: "Search")
        }
    }
}
