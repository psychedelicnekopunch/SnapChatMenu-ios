
import UIKit

class Menu {
    
    var index: Int
    
    var type: MenuType
    
    var iconName: String
    
    var activeIconName: String
    
    var view: UIView
    
    var constraint: [NSLayoutConstraint]
    
    var styles: [MenuStyle] = [MenuStyle]()
    
    var status: MenuStatus = .normal {
        didSet {
            self.action(progress: self.storeProgress, from: self.storeFrom, to: self.storeTo)
        }
    }
    
    private var storeProgress: CGFloat = 0
    // 最初に表示する index
    private var storeFrom: Int = 1
    // 最初に表示する index
    private var storeTo: Int = 1
    
    
    enum MenuType {
        case icon
        case bar
    }
    
    
    enum MenuStatus {
        case normal
        case active
    }
    
    
    init(index: Int, type: MenuType, iconName: String, activeIconName: String, view: UIView, constraint: [NSLayoutConstraint], styles: [MenuStyle]) {
        
        self.index = index
        
        self.type = type
        
        self.iconName = iconName
        
        self.activeIconName = activeIconName
        
        self.view = view
        
        self.constraint = constraint
        
        self.styles = styles
    }
    
    
    func action(progress: CGFloat, from: Int, to: Int) {
        guard let fromStyle: MenuStyle = self.getStyle(index: from) else {
            return
        }
        guard let toStyle: MenuStyle = self.getStyle(index: to) else {
            return
        }
        
        self.storeProgress = progress
        self.storeFrom = from
        self.storeTo = to
        
        if from == to {
            
            for (i, constraint) in self.constraint.enumerated() {
                constraint.constant = toStyle.constraint[i]
            }
            
            fromStyle.updateIconSize(view: self.view, size: toStyle.size)
            toStyle.updateIconSize(view: self.view, size: toStyle.size)
            
            fromStyle.updateBar(view: self.view, width: toStyle.size)
            toStyle.updateBar(view: self.view, width: toStyle.size)
            
            switch self.status {
            case .normal:
                fromStyle.imageView?.alpha = 0
                toStyle.imageView?.alpha = 1
                fromStyle.activeImageView?.alpha = 0
                toStyle.activeImageView?.alpha = 0
            case .active:
                fromStyle.imageView?.alpha = 0
                toStyle.imageView?.alpha = 0
                fromStyle.activeImageView?.alpha = 0
                toStyle.activeImageView?.alpha = 1
            }
            
            fromStyle.view?.alpha = 0
            toStyle.view?.alpha = 1
            return
        }
        
        let ajustProgress: CGFloat = self.ajustProgress(progress: progress, delay: toStyle.delay, forward: toStyle.forward)
        
        for (i, constraint) in self.constraint.enumerated() {
            let diffConstraint: CGFloat = toStyle.constraint[i] - fromStyle.constraint[i]
            constraint.constant = fromStyle.constraint[i] + (diffConstraint * ajustProgress)
        }
        
        let diffIconSize: CGFloat = toStyle.size - fromStyle.size
        let size: CGFloat = fromStyle.size + (diffIconSize * ajustProgress)
        
        fromStyle.updateIconSize(view: self.view, size: size)
        toStyle.updateIconSize(view: self.view, size: size)
        
        fromStyle.updateBar(view: self.view, width: size)
        toStyle.updateBar(view: self.view, width: size)
        
        switch self.status {
        case .normal:
            fromStyle.imageView?.alpha = 1 - ajustProgress
            toStyle.imageView?.alpha = ajustProgress
            fromStyle.activeImageView?.alpha = 0
            toStyle.activeImageView?.alpha = 0
        case .active:
            fromStyle.imageView?.alpha = 0
            toStyle.imageView?.alpha = 0
            fromStyle.activeImageView?.alpha = 1 - ajustProgress
            toStyle.activeImageView?.alpha = ajustProgress
        }
        
        fromStyle.view?.alpha = 1 - ajustProgress
        toStyle.view?.alpha = ajustProgress
    }
    
    
    private func getStyle(index: Int) -> MenuStyle? {
        for style in styles {
            if style.thenIndex == index {
                return style
            }
        }
        return nil
    }
    
    
    private func ajustProgress(progress: CGFloat, delay: CGFloat, forward: CGFloat) -> CGFloat {
        if progress <= delay {
            return 0.0
        }
        if progress >= 1 - forward {
            return 1.0
        }
        let rate: CGFloat = 1 / (1 - forward - delay)
        let diff: CGFloat = progress - delay
        return diff * rate
    }
    
}
