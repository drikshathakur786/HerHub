//
//  PaddedLabel.swift
//  HerHub
//
//  Created by Nihar Sandhu on 27/11/25.
//

import Foundation

import UIKit

class PaddedLabel: UILabel {
    var padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: padding)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }
}
