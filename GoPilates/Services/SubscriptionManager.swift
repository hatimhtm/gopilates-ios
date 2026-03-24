import Foundation
import RevenueCat
import SwiftUI
import Observation

// MARK: - Subscription Manager

@Observable
@MainActor
class SubscriptionManager: NSObject {
    static let shared = SubscriptionManager()

    var isProEntitled: Bool = false
    var isLoadingOfferings: Bool = false
    var customerInfo: CustomerInfo?
    var currentOffering: Offering?

    private var fetchOfferingsTask: Task<Void, Never>?

    private override init() {
        super.init()
    }

    // MARK: - Configure SDK (call once at launch)

    func configure(withAPIKey apiKey: String) {
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .info
        #endif
        Purchases.configure(withAPIKey: apiKey)
        Purchases.shared.delegate = self

        Task {
            await refreshCustomerInfo()
            await fetchOfferings()
        }
    }

    // MARK: - Refresh Customer Info

    func refreshCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            self.customerInfo = info
            updateEntitlementStatus(from: info)
        } catch {
            print("❌ Failed to fetch customer info: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Offerings (with retry support)

    func fetchOfferings() async {
        // If a fetch is already in progress, await it instead of silently returning
        if let existingTask = fetchOfferingsTask {
            await existingTask.value
            return
        }

        isLoadingOfferings = true
        let task = Task {
            do {
                let offerings = try await Purchases.shared.offerings()
                if let current = offerings.current {
                    self.currentOffering = current
                }
            } catch {
                print("❌ Failed to fetch offerings: \(error.localizedDescription)")
            }
            self.isLoadingOfferings = false
            self.fetchOfferingsTask = nil
        }
        fetchOfferingsTask = task
        await task.value
    }

    /// Re-fetch offerings if they haven't loaded yet (e.g., slow network on first attempt)
    func ensureOfferingsLoaded() async {
        if currentOffering == nil {
            await fetchOfferings()
        }
        // Retry once if the first attempt failed (e.g., SDK wasn't fully ready)
        if currentOffering == nil {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await fetchOfferings()
        }
    }

    // MARK: - Purchase Package

    func purchase(package: Package) async throws -> Bool {
        let (_, info, userCancelled) = try await Purchases.shared.purchase(package: package)
        self.customerInfo = info
        updateEntitlementStatus(from: info)

        if !userCancelled {
            self.isProEntitled = true
            return true
        }
        return false
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            let info = try await Purchases.shared.restorePurchases()
            self.customerInfo = info
            updateEntitlementStatus(from: info)
        } catch {
            print("❌ Failed to restore purchases: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func updateEntitlementStatus(from info: CustomerInfo) {
        self.isProEntitled = !info.entitlements.active.isEmpty || info.entitlements["GoPilates Pro"]?.isActive == true
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            self.customerInfo = customerInfo
            self.isProEntitled = !customerInfo.entitlements.active.isEmpty || customerInfo.entitlements["GoPilates Pro"]?.isActive == true
        }
    }
}
