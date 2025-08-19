import SwiftUI

struct QuoteView: View {
    @ObservedObject var viewModel: QuoteViewModel
    let title: String

    var body: some View {
        Form {
            Section("Amount (USD)") {
                TextField("e.g. 100", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
            }
            Section("Result") {
                if let msg = viewModel.errorMessage {
                    Text(msg).foregroundStyle(.red)
                }
                HStack {
                    Text("Converted:")
                    Spacer()
                    Text(viewModel.resultText).bold()
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading rates...")
            }
        }
        .navigationTitle("USD → \(title)")
    }
}
