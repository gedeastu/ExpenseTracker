//
//  CurrencyService.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 15/02/26.
//
import Foundation

protocol CurrencyServiceProtocol {
    func fetchRates(base: String,
                    completion: @escaping (Result<[String: Double], Error>) -> Void)
}

final class CurrencyService: CurrencyServiceProtocol {

    func fetchRates(base: String = "IDR",
                    completion: @escaping (Result<[String: Double], Error>) -> Void) {

        guard let url = CurrencyAPI.latest(base: base) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 15
        )

        URLSession.shared.dataTask(with: request) { data, response, error in

            // Network Error
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // HTTP Validation
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            // Data Validation
            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(CurrencyResponse.self, from: data)

                guard decoded.result.lowercased() == "success" else {
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                    }
                    return
                }

                DispatchQueue.main.async {
                    completion(.success(decoded.rates))
                }

            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }

        }.resume()
    }
}
