import Foundation
import StoreKit

/// The one real App Store Connect In-App Purchase product identifier for
/// MyFamilyTree. Must exactly match what was entered in App Store Connect.
enum ProductID: String {
    case pro = "com.aries_rst.myfamilytree.app.pro"
}

enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase could not be verified by the App Store."
        case .productNotFound:
            return "This product isn't available right now. Please try again later."
        }
    }
}

/// Owns all real StoreKit 2 interaction: loading the product, purchasing,
/// restoring, and keeping AppState.isPro in sync with what the App Store
/// actually says the user owns. AppState no longer decides this itself — it
/// just reflects whatever this class determines from real entitlements.
@MainActor
final class StoreManager: ObservableObject {
    @Published private(set) var product: Product?
    @Published var isPurchasing = false
    @Published var lastError: String?
    @Published var statusMessage: String?

    private var updatesTask: Task<Void, Never>?
    private weak var appState: AppState?

    /// Call once, right after both AppState and StoreManager exist (see
    /// MyFamilyTreeApp). Starts listening for transaction updates (purchases
    /// made via Ask to Buy, or restored on another device) and does an
    /// initial product load + entitlement check so isPro reflects reality
    /// even if the app was reinstalled.
    func start(appState: AppState) {
        self.appState = appState
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(transactionResult: result)
            }
        }
        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [ProductID.pro.rawValue])
            product = products.first
        } catch {
            lastError = "Couldn't load the price from the App Store: \(error.localizedDescription)"
        }
    }

    /// Buys PRO. On success, updates AppState.isPro immediately (the
    /// transaction listener would also catch it, but this avoids any lag in
    /// the UI). Safe to call repeatedly; guarded by isPurchasing.
    func purchase() async {
        guard !isPurchasing else { return }
        lastError = nil
        statusMessage = nil
        guard let product else {
            // Product may not have loaded yet (e.g. cold launch with a slow
            // network) — try once more before giving up.
            await loadProduct()
            guard let product else {
                lastError = StoreError.productNotFound.errorDescription
                return
            }
            await purchase(product: product)
            return
        }
        await purchase(product: product)
    }

    private func purchase(product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                appState?.applyEntitlement(for: transaction)
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                // e.g. Ask to Buy — will resolve later via Transaction.updates.
                break
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Re-syncs with the App Store and re-checks entitlements. Used both by
    /// the explicit "Restore purchase" button and automatically at launch.
    func restore() async {
        guard !isPurchasing else { return }
        lastError = nil
        statusMessage = nil
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            statusMessage = appState?.lang == .ru ? "Покупка восстановлена." : "Purchase restored."
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Checks every currently-owned (non-revoked) transaction for the PRO
    /// product and tells AppState. This is the single source of truth for
    /// `isPro` — it's what makes the purchase survive reinstalls, device
    /// changes, and Ask to Buy approvals.
    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.productID == ProductID.pro.rawValue {
                owned = true
            }
        }
        appState?.setProFromEntitlements(owned)
    }

    private func handle(transactionResult: VerificationResult<Transaction>) async {
        guard let transaction = try? checkVerified(transactionResult) else { return }
        if transaction.productID == ProductID.pro.rawValue {
            appState?.applyEntitlement(for: transaction)
        }
        await transaction.finish()
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}
