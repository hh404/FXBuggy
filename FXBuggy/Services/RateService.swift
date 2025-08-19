import Foundation
import Combine

protocol RateServiceType {
    func loadCurrencies() -> AnyPublisher<[Currency], Error>
    func loadRates() -> AnyPublisher<RatesResponse, Error>
}

final class RateService: RateServiceType {
    enum ServiceError: Error { case fileNotFound, badData }

    private func loadJSON<T: Decodable>(_ name: String, as type: T.Type) -> AnyPublisher<T, Error> {
        Future<T, Error> { promise in
            let delay = UInt64(100_000_000) // 0.1s
            Task.detached {
                try? await Task.sleep(nanoseconds: delay)
                guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
                      let data = try? Data(contentsOf: url) else {
                    return promise(.failure(ServiceError.fileNotFound))
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    promise(.success(decoded))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func loadCurrencies() -> AnyPublisher<[Currency], Error> {
        loadJSON("currencies", as: [Currency].self)
    }

    func loadRates() -> AnyPublisher<RatesResponse, Error> {
        return loadJSON("rate", as: RatesResponse.self)
    }
}
