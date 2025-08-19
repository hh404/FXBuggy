import Foundation
import Combine

final class CurrencyListViewModel: ObservableObject {
    // Input
    @Published var searchText: String = ""

    // Output
    @Published private(set) var currencies: [Currency] = []
    @Published private(set) var filtered: [Currency] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let service: RateServiceType
    private var bag = Set<AnyCancellable>()

    init(service: RateServiceType) {
        self.service = service
        bind()
        load()
    }

    func load() {
        isLoading = true
        errorMessage = nil
        service.loadCurrencies()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.errorMessage = "load failed：\(err.localizedDescription)"
                }
            } receiveValue: { [weak self] items in
                self?.currencies = items
                self?.filtered = items
            }
            .store(in: &bag)
    }

    private func bind() {
        $searchText
            .throttle(for: .milliseconds(0), scheduler: DispatchQueue.global(), latest: true)
            .removeDuplicates()
            .map { [weak self] q -> [Currency] in
                guard let self = self else { return [] }
                let t = q.lowercased()
                if t.isEmpty { return self.currencies }
                return self.currencies.filter { $0.code.lowercased().contains(t) || $0.name.lowercased().contains(t) }
            }
            .sink { [weak self] list in
                self?.filtered = list
            }
            .store(in: &bag)
    }
}
