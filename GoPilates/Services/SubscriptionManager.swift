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
    var customerInfo: CustomerInfo?
    var currentOffering: Offering?

    private override init() {
        super.init()
    }

    // MARK: - Configure SDK (call once at launch)

    func configure(withAPIKey apiKey: String) {
        Purchases.logLevel = .debug
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
            self.isProEntitled = !info.entitlements.active.isEmpty || info.entitlements["GoPilates Pro"]?.isActive == true
        } catch {
            print("❌ Failed to fetch customer info: \(error.localizedDescription)")
        }
    }

    // MARK: - Fetch Offerings

    func fetchOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            if let current = offerings.current {
                self.currentOffering = current
            }
        } catch {
            print("❌ Failed to fetch offerings: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase Package

    func purchase(package: Package) async throws -> Bool {
        let (_, info, userCancelled) = try await Purchases.shared.purchase(package: package)
        self.customerInfo = info
        self.isProEntitled = !info.entitlements.active.isEmpty || info.entitlements["GoPilates Pro"]?.isActive == true

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
            self.isProEntitled = !info.entitlements.active.isEmpty || info.entitlements["GoPilates Pro"]?.isActive == true
        } catch {
            print("❌ Failed to restore purchases: \(error.localizedDescription)")
        }
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
