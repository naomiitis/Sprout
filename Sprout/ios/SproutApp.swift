import SwiftUI

@main
struct SproutApp: App {
    @StateObject private var viewModel = SproutViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
                    .onChange(of: hasCompletedOnboarding) { completed in
                        if completed {
                            // Load profile after onboarding completes
                            Task {
                                await viewModel.loadProfile()
                            }
                        }
                    }
            } else {
                RootView()
                    .environmentObject(viewModel)
                    .task {
                        if viewModel.userProfile == nil {
                            await viewModel.loadProfile()
                        }
                    }
            }
        }
    }
}

