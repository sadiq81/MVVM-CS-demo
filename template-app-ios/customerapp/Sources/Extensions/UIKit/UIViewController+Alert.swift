
import UIKit

extension UIViewController {
    
    func alert(error: Error) {
        self.alert(title: Strings.Error.Generic.title, message: error.localizedDescription)
    }
    
    func alert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Strings.Button.ok, style: .default))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

