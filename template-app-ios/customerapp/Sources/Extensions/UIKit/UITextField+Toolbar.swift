
import UIKit

extension UITextField {
    
    func addDoneButton(doneTarget: Any? = nil, doneAction: Selector? = nil, cancelTarget: Any? = nil, cancelAction: Selector? = nil) {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        var items: [UIBarButtonItem] = []
        
        // Create the done button
        if let doneTarget, let doneAction {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: doneTarget, action: doneAction)
            items.append(doneButton)
        } else {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
            items.append(doneButton)
        }
                
        // Optional: Add a flexible space and cancel button
        if let cancelTarget, let cancelAction {
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            items.append(flexSpace)
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: cancelTarget, action: cancelAction)
            items.append(cancelButton)
        }
        
        
        // Add buttons to toolbar
        toolbar.items = items
        
        // Set the toolbar as the accessory view
        self.inputAccessoryView = toolbar
    }        
    
}
