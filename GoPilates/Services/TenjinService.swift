import Foundation
import AppTrackingTransparency
import TenjinSDK

// MARK: - Configuration

private enum TenjinConfig {
    static let sdkKey = "NYWSZSZZC7YWZX6FKPDPC6WW1TBISKHS"
}

// MARK: - TenjinService

/// Service centralisant toutes les interactions avec le SDK Tenjin.
final class TenjinService {

    static let shared = TenjinService()
    private var initialized = false

    private init() {}

    // MARK: - Initialize

    /// Initialise le SDK Tenjin.
    func initialize(userId: String? = nil) async {
        guard !initialized else { return }
        print("TENJIN: Initializing SDK...")

        // 1. Initialiser le SDK
        TenjinSDK.getInstance(TenjinConfig.sdkKey)

        // 2. Définir l'ID utilisateur AVANT connect()
        if let userId = userId {
            TenjinSDK.setCustomerUserId(userId)
            print("TENJIN: Customer User ID set: \(userId)")
        }

        // 3. Demander ATT puis connecter dans le callback
        if #available(iOS 14.0, *) {
            let status = await withCheckedContinuation { continuation in
                ATTrackingManager.requestTrackingAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
            print("TENJIN: ATT status: \(status.rawValue)")
        }

        TenjinSDK.connect()
        initialized = true
        print("TENJIN: SDK Initialized and connected.")
        
        #if DEBUG
        TenjinSDK.debugLogs()
        #endif
    }

    // MARK: - Customer User ID

    func setCustomerUserId(_ userId: String) {
        TenjinSDK.setCustomerUserId(userId)
        print("TENJIN: Customer User ID set: \(userId)")
    }

    // MARK: - Track Events

    func trackEvent(_ eventName: String, value: Int? = nil) {
        if let value = value {
            TenjinSDK.sendEvent(withName: eventName, andEventValue: String(value))
        } else {
            TenjinSDK.sendEvent(withName: eventName)
        }
        let valueLog = value.map { " with value: \($0)" } ?? ""
        print("TENJIN: Event tracked: \(eventName)\(valueLog)")
    }

    // MARK: - Track Subscription

    /// Track le début d'un free trial / abonnement.
    func trackSubscription() {
        // Utilisation de l'événement "start_trial" comme demandé
        TenjinSDK.sendEvent(withName: "start_trial")
        if #available(iOS 14.0, *) {
            TenjinSDK.updatePostbackConversionValue(Int32(20)) // 20 = subscription
        }
        print("TENJIN: Free trial started event tracked (start_trial)")
    }

    // MARK: - SKAdNetwork Conversion Value

    func updateConversionValue(
        _ conversionValue: Int,
        coarseValue: String? = nil,
        lockWindow: Bool? = nil
    ) {
        if #available(iOS 16.1, *), let coarseValue = coarseValue {
            if let lockWindow = lockWindow {
                TenjinSDK.updatePostbackConversionValue(
                    Int32(conversionValue),
                    coarseValue: coarseValue,
                    lockWindow: lockWindow
                )
            } else {
                TenjinSDK.updatePostbackConversionValue(
                    Int32(conversionValue),
                    coarseValue: coarseValue
                )
            }
        } else if #available(iOS 14.0, *) {
            TenjinSDK.updatePostbackConversionValue(Int32(conversionValue))
        }
        print("TENJIN: Conversion value updated: \(conversionValue)")
    }
}
