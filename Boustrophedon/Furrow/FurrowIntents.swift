import AppIntents
import Foundation

/// Role: Furrow. App Intents open the four jobs or fire turn and face in place.
struct TurnFurrowIntent: AppIntent {
    static let title: LocalizedStringResource = "Turn furrow"
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        FurrowStore.shared.turnFurrow()
        return .result()
    }
}

struct FaceStichosIntent: AppIntent {
    static let title: LocalizedStringResource = "Face stichos"
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        if let first = FurrowStore.shared.liveFurrow?.stichoi.first(where: \.isRetrograde) {
            _ = FurrowStore.shared.faceStichos(first.index)
        }
        return .result()
    }
}

struct OpenQuizIntent: AppIntent {
    static let title: LocalizedStringResource = "Open quiz"
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        FurrowStore.shared.present(.none)
        return .result()
    }
}

struct OpenExploreIntent: AppIntent {
    static let title: LocalizedStringResource = "Open explore"
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        FurrowStore.shared.present(.explore)
        return .result()
    }
}

struct OpenSavedIntent: AppIntent {
    static let title: LocalizedStringResource = "Open saved"
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        FurrowStore.shared.present(.saved)
        return .result()
    }
}

struct OpenSettingsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open settings"
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        FurrowStore.shared.present(.settings)
        return .result()
    }
}
