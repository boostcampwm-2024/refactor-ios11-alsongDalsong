import FirebaseCore
import SwiftUI

@main
struct ASAIKitDemoApp: App {
    init() {
      FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ASAIKitDemoView()
        }
    }
}
