import Foundation
import StoreKit
import Observation

@MainActor
@Observable
final class TipJarService {
    private(set) var product: Product?
    private(set) var tipCount: Int
    private(set) var isLoadingProduct: Bool = false
    private(set) var isPurchasing: Bool = false
    private(set) var lastError: String?

    private static let tipCountKey = "tipJar.count"
    private let productLoader: @Sendable () async -> Product?
    private let purchaser: @Sendable (Product) async -> Bool

    init(
        productLoader: @escaping @Sendable () async -> Product? = TipJarService.liveProductLoader,
        purchaser: @escaping @Sendable (Product) async -> Bool = TipJarService.livePurchaser
    ) {
        self.productLoader = productLoader
        self.purchaser = purchaser
        self.tipCount = UserDefaults.standard.integer(forKey: Self.tipCountKey)
    }

    func load() async {
        guard product == nil, !isLoadingProduct else { return }
        isLoadingProduct = true
        defer { isLoadingProduct = false }
        product = await productLoader()
    }

    @discardableResult
    func purchase() async -> Bool {
        guard let product, !isPurchasing else { return false }
        isPurchasing = true
        defer { isPurchasing = false }
        let success = await purchaser(product)
        if success {
            incrementTipCount()
        }
        return success
    }

    private func incrementTipCount() {
        tipCount += 1
        UserDefaults.standard.set(tipCount, forKey: Self.tipCountKey)
    }
}

// MARK: - Live StoreKit hooks

extension TipJarService {
    nonisolated static let liveProductLoader: @Sendable () async -> Product? = {
        do {
            let products = try await Product.products(for: [RepoConfig.tipProductID])
            return products.first
        } catch {
            return nil
        }
    }

    nonisolated static let livePurchaser: @Sendable (Product) async -> Bool = { product in
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return true
                case .unverified:
                    return false
                }
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }
}

// MARK: - Previews

extension TipJarService {
    static func preview(tipCount: Int = 0) -> TipJarService {
        let service = TipJarService(
            productLoader: { nil },
            purchaser: { _ in true }
        )
        UserDefaults.standard.set(tipCount, forKey: Self.tipCountKey)
        return service
    }
}
