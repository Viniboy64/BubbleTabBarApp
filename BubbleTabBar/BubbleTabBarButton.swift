//
//  BubbleTabBarButton.swift
//  BubbleTabBar
//  BubbleTabBarApp
//
//  Created by Marcus Vinícius on 25/07/19.
//  Copyright © 2019 Marcus Vinícius. All rights reserved.
//

import UIKit

public class BubbleTabBarItem: UITabBarItem {
    @IBInspectable public var tintColor: UIColor?
}

public class BubbleTabBarButton: UIControl {
    init(item: UITabBarItem) {
        super.init(frame: .zero)
        tabBarImage = UIImageView(image: item.image)
        
        defer {
            self.item = item
            configureSubviews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }
    
    private let backgroundHeight: CGFloat = 48.0
    
    private var constraintFoldedLabelLeading: NSLayoutConstraint!
    private var constraintUnfoldedLabelLeading: NSLayoutConstraint!
    private var constraintFoldedBackgroundTrailing: NSLayoutConstraint!
    private var constraintUnfoldedBackgroundTrailing: NSLayoutConstraint!
    
    private var foldedConstraints: [NSLayoutConstraint] {
        return [constraintFoldedLabelLeading, constraintFoldedBackgroundTrailing]
    }
    
    private var unfoldedConstraints: [NSLayoutConstraint] {
        return [constraintUnfoldedLabelLeading, constraintUnfoldedBackgroundTrailing]
    }
    
    private var tabBarLabel = UILabel()
    private var tabBarImage = UIImageView()
    private var tabBarBackground = UIView()
    
    private var _isSelected: Bool = false
    
    override public var isSelected: Bool {
        get {
            return _isSelected
        }
        
        set {
            guard newValue != _isSelected else {
                return
            }
            
            if newValue {
                unfold()
            } else {
                fold()
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            if _isSelected {
                tabBarImage.tintColor = tintColor
            }
            
            tabBarLabel.textColor = tintColor
            tabBarBackground.backgroundColor = tintColor.withAlphaComponent(0.24)
        }
    }
    
    public var item: UITabBarItem? {
        didSet {
            tabBarImage.image = item?.image?.withRenderingMode(.alwaysTemplate)
            tabBarLabel.text = item?.title
            
            if
                let tabBarItem = item as? BubbleTabBarItem,
                let tabBarColor = tabBarItem.tintColor
            {
                tintColor = tabBarColor
            }
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        tabBarBackground.layer.cornerRadius = tabBarBackground.bounds.height / 2.0
    }
    
    public func setSelected(_ selected: Bool, animationDuration duration: Double = 0.0) {
        _isSelected = selected
        
        if selected {
            unfold(animationDuration: duration)
        } else {
            fold(animationDuration: duration)
        }
    }
    
    private func fold(animationDuration duration: Double = 0.0) {
        foldedConstraints.forEach { $0.isActive = true }
        unfoldedConstraints.forEach { $0.isActive = false }
        
        UIView.animate(withDuration: duration) {
            self.tabBarBackground.alpha = 0.0
        }
        
        UIView.animate(withDuration: duration * 0.48) {
            self.tabBarLabel.alpha = 0.0
        }
        
        UIView.transition(with: tabBarImage, duration: duration, options: [.transitionCrossDissolve], animations: {
            self.tabBarImage.tintColor = .black
        }, completion: nil)
    }
    
    private func unfold(animationDuration duration: Double = 0.0) {
        foldedConstraints.forEach { $0.isActive = false }
        unfoldedConstraints.forEach { $0.isActive = true }
        
        UIView.animate(withDuration: duration) {
            self.tabBarBackground.alpha = 1.0
        }
        
        UIView.animate(withDuration: duration * 0.48, delay: duration * 0.48, options: [], animations: {
            self.tabBarLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.transition(with: tabBarImage, duration: duration, options: [.transitionCrossDissolve], animations: {
            self.tabBarImage.tintColor = self.tintColor
        }, completion: nil)
    }
    
    private func configureSubviews() {
        tabBarLabel.font = UIFont.systemFont(ofSize: 16)
        tabBarLabel.adjustsFontSizeToFitWidth = true
        tabBarLabel.translatesAutoresizingMaskIntoConstraints = false
        tabBarLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        tabBarImage.contentMode = .center
        tabBarImage.translatesAutoresizingMaskIntoConstraints = false
        tabBarImage.setContentHuggingPriority(.required, for: .vertical)
        tabBarImage.setContentHuggingPriority(.required, for: .horizontal)
        tabBarImage.setContentCompressionResistancePriority(.required, for: .vertical)
        tabBarImage.setContentCompressionResistancePriority(.required, for: .horizontal)
        tabBarImage.centerYAnchor.constraint(equalTo: tabBarBackground.centerYAnchor).isActive = true
        tabBarImage.leadingAnchor.constraint(equalTo: tabBarBackground.leadingAnchor, constant: backgroundHeight / 2.0).isActive = true
        
        tabBarBackground.isUserInteractionEnabled = false
        tabBarBackground.translatesAutoresizingMaskIntoConstraints = false
        tabBarBackground.heightAnchor.constraint(equalToConstant: backgroundHeight).isActive = true
        tabBarBackground.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tabBarBackground.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tabBarBackground.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        self.addSubview(tabBarImage)
        self.addSubview(tabBarLabel)
        self.addSubview(tabBarBackground)
        
        constraintFoldedLabelLeading = tabBarLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        constraintUnfoldedLabelLeading = tabBarLabel.leadingAnchor.constraint(equalTo: tabBarImage.trailingAnchor, constant: backgroundHeight / 4.0)
        constraintFoldedBackgroundTrailing = tabBarImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundHeight / 2.0)
        constraintUnfoldedBackgroundTrailing = tabBarLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -backgroundHeight / 2.0)
        
        fold()
        
        setNeedsLayout()
    }
}
