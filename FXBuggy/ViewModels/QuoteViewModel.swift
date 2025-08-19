import Foundation
import Combine

final class QuoteViewModel: ObservableObject {
    // Input
    @Published var amountText: String = "" // USD 金额

    // Output
    @Published private(set) var resultText: String = "--"
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false

    private let service: RateServiceType
    private let toCode: String
    private var bag = Set<AnyCancellable>()

    init(service: RateServiceType, toCode: String) {
        self.service = service
        self.toCode = toCode
        setupPipeline()
    }

    private func setupPipeline() {
        let amountPublisher = $amountText
            .map { Double($0) ?? 0 }
            .removeDuplicates()
            .setFailureType(to: Error.self)

        let ratesOnce = service.loadRates()
            .share()

        amountPublisher
            .combineLatest(ratesOnce)
            .map { [toCode] amount, resp -> String in
                let rate = resp.rates[toCode] ?? 0
                return String(format: "%.2f %@", amount * rate, toCode)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] comp in
                if case .failure(let e) = comp { self?.errorMessage = "fxrate load failed：\(e.localizedDescription)" }
            }, receiveValue: { [weak self] text in
                self?.resultText = text
            })
    }
}
