//
//  LayoutGuideProtocol.swift
//  ConfigurableSwitchConrol
//
//  Created by Maksim Petrov on 07.06.2023.
//

import UIKit

protocol LayoutGuideProtocol {
    var owningView: UIView? { get }
    
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: LayoutGuideProtocol {
    var owningView: UIView? { superview }
}

extension UILayoutGuide: LayoutGuideProtocol {}

extension LayoutGuideProtocol {
    @discardableResult
    func constrainToSuperview( insets: UIEdgeInsets = .zero, constrainToMargins: Bool = false ) -> [ NSLayoutConstraint ] {
        
        let secondItem: LayoutGuideProtocol = constrainToMargins ? owningView!.layoutMarginsGuide : owningView!
        
        let constraints = [
            topAnchor.constraint( equalTo: secondItem.topAnchor, constant: insets.top ),
            leadingAnchor.constraint( equalTo: secondItem.leadingAnchor, constant: insets.left ),
            secondItem.bottomAnchor.constraint( equalTo: bottomAnchor, constant: insets.bottom ),
            secondItem.trailingAnchor.constraint( equalTo: trailingAnchor, constant: insets.right ),
            ]
        
        NSLayoutConstraint.activate( constraints )
        return constraints
    }
}
