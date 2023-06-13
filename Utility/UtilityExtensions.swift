//
//  Then.swift
//  ConfigurableSwitchConrol
//
//  Created by Maksim Petrov on 06.06.2023.
//

import UIKit

protocol Then {}

extension NSObject: Then {}

extension Then where Self: UIView {

    @discardableResult
    func then(_ block: (Self) -> Void ) -> Self {
        block(self)
        return self
    }
}

extension Optional {

    @discardableResult
    func then<T>( _ block: ( Wrapped ) throws -> T ) rethrows -> T? {
        switch self {
        case .none: return nil
        case .some( let value ): return try block( value )
        }
    }
}

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}

extension UIEdgeInsets {
    init(constantInset inset: CGFloat) {
        self.init( top: inset, left: inset, bottom: inset, right: inset )
    }
}

extension CGSize {
    func inset(by value: CGFloat) -> Self {
        return CGSize(width: width - value, height: height - value)
    }
}

extension UIGestureRecognizer {
    convenience init<T: UIGestureRecognizer>( target: Any?, handler: @escaping ( T ) -> Void ) {
        let wrapper = HandlerWrapper<T>( handler )
        self.init( target: wrapper, action: #selector( HandlerWrapper.invoke ))
        wrapper.recognizer = self as? T
        objc_setAssociatedObject( target ?? self,
                                  &UIGestureRecognizer.AssociatedObjectHandle,
                                  wrapper,
                                  .OBJC_ASSOCIATION_RETAIN )
    }

    /// Wrapper class used to store closure.
    private final class HandlerWrapper<T: UIGestureRecognizer> {
        let handler: ( T ) -> Void
        weak var recognizer: T?
        init ( _ handler: @escaping ( T ) -> Void ) { self.handler = handler }
        @objc func invoke() { recognizer.then { handler( $0 ) }}
    }

    static private var AssociatedObjectHandle: UInt8 = 0
}
