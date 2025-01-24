//
//  PaddingLabel.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import UIKit

@IBDesignable
final class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 3.0
    @IBInspectable var bottomInset: CGFloat = 3.0
    @IBInspectable var leftInset: CGFloat = 5.0
    @IBInspectable var rightInset: CGFloat = 5.0

    private var textInsets: UIEdgeInsets {
        UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let adjustedWidth = size.width + leftInset + rightInset
        let adjustedHeight = size.height + topInset + bottomInset
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fittingSize = super.sizeThatFits(CGSize(width: size.width - leftInset - rightInset, height: size.height - topInset - bottomInset))
        return CGSize(width: fittingSize.width + leftInset + rightInset, height: fittingSize.height + topInset + bottomInset)
    }
    
    override var bounds: CGRect {
        didSet {
            let effectiveWidth = bounds.width - (leftInset + rightInset)
            if preferredMaxLayoutWidth != effectiveWidth {
                preferredMaxLayoutWidth = effectiveWidth
                setNeedsLayout()
            }
        }
    }
}

