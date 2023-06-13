//
//  ConfigurableSwitchControl.swift
//  ConfigurableSwitchConrol
//
//  Created by Maksim Petrov on 06.06.2023.
//

import UIKit

class ConfigurableSwitchControl: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        contentView.layer.cornerRadius = frame.height / 2
        thumbnailView.frame.size = CGSize(width: frame.height - UIConstant.ThumbnailInset.double,
                                          height: frame.height - UIConstant.ThumbnailInset.double)
        thumbnailView.layer.cornerRadius = thumbnailView.frame.height / 2
        calculatePositions()
        updateImages()
        setOn(isOn, animated: false)
    }
    
    /// changes `isOn`,  `completion` is called after animation finishes if `animated`
    func setOn(_ isOn: Bool,
               animated: Bool = false,
               completion: (() -> Void)? = nil) {
        self.isOn = isOn
        let block = { [weak self] in
            guard let self else { return }
            self.onStateChange(to: isOn)
            self.thumbnailView.frame.origin = isOn ? self.onPoint : self.offPoint
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: block) { _ in
                completion?()
            }
        } else {
            block()
            completion?()
        }
    }
    
    // MARK: - @IBInspectables
    /// tint color for case `isOn == true`
    @IBInspectable var onTintColor: UIColor = .systemGreen
    /// tint color for case `isOn == false`
    @IBInspectable var offTintColor: UIColor = .secondarySystemBackground
    /// thumb color for case `isOn == true`
    @IBInspectable var onThumbColor: UIColor = .white
    /// thumb color for case `isOn == false`
    @IBInspectable var offThumbColor: UIColor?
    /// thumb image for case `isOn == true`
    @IBInspectable var onThumbImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    /// thumb image for case `isOn == false`
    @IBInspectable var offThumbImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    /// image located in opposite to current `isOn` value origin
    /// regarding switch's contentView
    ///  - note: image for `isOn == true`
    @IBInspectable var onBackImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    /// image located in opposite to current `isOn` value origin
    /// regarding switch's contentView
    ///  - note: image for `isOn == false`
    @IBInspectable var offBackImage: UIImage? {
        didSet { setNeedsLayout() }
    }
    
    private(set) var isOn: Bool = false
    
    // MARK: - subviews
    private let contentView = UIView()
    private let thumbnailView = UIView().then { $0.clipsToBounds = true }
    private lazy var thumbImageView = UIImageView()
    private lazy var backOnImageView = UIImageView()
    private lazy var backOffImageView = UIImageView()
    
    private var currentThumbImage: UIImage? { isOn ? onThumbImage : offThumbImage }
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    /// thumb view`'isOn == true` origin
    private var onPoint: CGPoint!
    /// thumb view `isOn == false` origin
    private var offPoint: CGPoint!
}

// MARK: - ui ocnfigurations
private extension ConfigurableSwitchControl {
    func pinViews() {
        addSubview(contentView)
        contentView.addSubview(thumbnailView)
    }
    
    func onStateChange(to isOn: Bool) {
        contentView.backgroundColor = isOn ? onTintColor : offTintColor
        thumbnailView.backgroundColor = isOn ? onThumbColor : (offThumbColor ?? onThumbColor)
        if let currentThumbImage { thumbImageView.image = currentThumbImage }
    }
    
    func updateImages() {
        defer { contentView.bringSubviewToFront(thumbnailView) }
        let constImageViewSize = CGSize(width: thumbnailView.frame.width - UIConstant.ThumbnailInset.standart,
                                        height: thumbnailView.frame.height - UIConstant.ThumbnailInset.standart)
        // thumb part
        if let image = currentThumbImage {
            if !thumbnailView.subviews.contains(thumbImageView) {
                thumbnailView.addSubview(thumbImageView)
                thumbImageView.bounds.size = constImageViewSize
                thumbImageView.center = thumbnailView.center
            }
            thumbImageView.image = image
            thumbImageView.isHidden = false
        } else {
            thumbImageView.isHidden = true
        }
        // back images part
        if let image = offBackImage {
            if !contentView.subviews.contains(backOffImageView) {
                contentView.addSubview(backOffImageView)
                backOffImageView.bounds.size = constImageViewSize
                backOffImageView.frame.origin.x = onPoint.x + UIConstant.ThumbnailInset.standart
                backOffImageView.center.y = contentView.center.y
            }
            backOffImageView.image = image
            backOffImageView.isHidden = false
        } else {
            backOffImageView.isHidden = true
        }
        if let image = onBackImage {
            if !contentView.subviews.contains(backOnImageView) {
                contentView.addSubview(backOnImageView)
                backOnImageView.bounds.size = constImageViewSize
                backOnImageView.frame.origin.x = offPoint.x
                backOnImageView.center.y = contentView.center.y
            }
            backOnImageView.image = image
            backOnImageView.isHidden = false
        } else {
            backOnImageView.isHidden = true
        }
    }
}

private extension ConfigurableSwitchControl {
    func commonInit() {
        pinViews()
        addPanGesture()
        addTapGesture()
    }
}

// MARK: - math
private extension ConfigurableSwitchControl {
    func calculatePositions() {
        offPoint = CGPoint(x: UIConstant.ThumbnailInset.standart,
                           y: UIConstant.ThumbnailInset.standart)
        onPoint = CGPoint(x: bounds.width - thumbnailView.bounds.width - UIConstant.ThumbnailInset.standart,
                          y: UIConstant.ThumbnailInset.standart)
    }
}

// MARK: - switch gestures
private extension ConfigurableSwitchControl {
    func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: nil) { [weak self] pan in
            guard let self else { return }
            feedbackGenerator.prepare()
            switch pan.state {
            case .changed, .cancelled, .ended:
                let targetState = pan.location(in: self).x > self.bounds.size.width / 2
                let shallPassControl = targetState != isOn
                self.setOn(targetState,
                           animated: true) { [weak self] in
                    guard let self, shallPassControl else { return }
                    self.feedbackGenerator.selectionChanged()
                }
                if shallPassControl { sendActions(for: .valueChanged) }
            default:
                break
            }
        }
        addGestureRecognizer(pan)
    }
    
    func addTapGesture() {
        let tap = UITapGestureRecognizer(target: nil) { [weak self] _ in
            guard let self else { return }
            feedbackGenerator.prepare()
            self.setOn(!self.isOn, animated: true) { [weak self] in
                self?.feedbackGenerator.selectionChanged()
            }
            sendActions(for: .valueChanged)
        }
        addGestureRecognizer(tap)
    }
}
