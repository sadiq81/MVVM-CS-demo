
import SwiftUI
import UIKit

import MustacheServices
import NavigatorUI

// MARK: - OID Authorization View

struct OIDAuthorizationView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

    @InjectedObject(\.oidAuthorizationViewModel)
    private var viewModel

    var body: some View {
        OIDPresenterView(viewModel: self.viewModel)
            .background(Color.clear)
            .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
                Button(Strings.Button.ok) {
                    self.navigator.dismiss()
                }
            } message: {
                Text(self.viewModel.errorMessage)
            }
            .onChange(of: self.viewModel.isFinished) { _, isFinished in
                if isFinished {
                    self.navigator.dismiss()
                }
            }
    }
}

// MARK: - Presenter UIViewControllerRepresentable

/// Transparent UIViewController that provides the presenter for AppAuth's OAuth flow.
/// The ViewModel handles all authorization logic — this just provides the UIViewController reference.
private struct OIDPresenterView: UIViewControllerRepresentable {

    @ObservedObject var viewModel: OIDAuthorizationViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Start authorization once the presenter is in the hierarchy
        if self.viewModel.isLoading && !context.coordinator.hasStarted {
            context.coordinator.hasStarted = true
            DispatchQueue.main.async {
                self.viewModel.startAuthorization(from: uiViewController)
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var hasStarted = false
    }
}
