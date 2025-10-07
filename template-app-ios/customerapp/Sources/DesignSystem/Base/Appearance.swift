import Foundation
import UIKit

struct Appearance {
    
    static func configure() {
        // TODO: Style tab bar and navigation bar 
        self.textField()
        self.navigationBar()
        self.tabBar()
        UIFont.overrideInitialize()
    }
    
    static fileprivate func textField() {
        // Caret color
        UITextField.appearance().tintColor = Colors.Foreground.default.color
    }
    
    static fileprivate func navigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = Colors.Background.surface.color

        // Add subtle border at bottom
        navigationBarAppearance.shadowColor = Colors.Border.default.color

        // Title text attributes
        var titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Colors.Foreground.default.color,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        navigationBarAppearance.titleTextAttributes = titleTextAttributes

        // Large title text attributes
        titleTextAttributes[.font] = UIFont.preferredFont(forTextStyle: .largeTitle)
        navigationBarAppearance.largeTitleTextAttributes = titleTextAttributes

        // Apply to all states
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance

        // Tint color for buttons
        UINavigationBar.appearance().tintColor = Colors.Foreground.brand.color
    }
    
    static fileprivate func tabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = Colors.Background.surface.color

        // Add top border for separation
        tabBarAppearance.shadowColor = Colors.Border.default.color

        // Selected tab (use default/brand color for emphasis)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = Colors.Foreground.brand.color
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: Colors.Foreground.brand.color,
            .font: UIFont.preferredFont(forTextStyle: .caption2.emphasized)
        ]

        // Normal/unselected tab (use muted color)
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = Colors.Foreground.muted.color
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: Colors.Foreground.muted.color,
            .font: UIFont.preferredFont(forTextStyle: .caption2)
        ]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    static fileprivate func printFonts() {
        
        for family: String in UIFont.familyNames {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }
    }
    
}
