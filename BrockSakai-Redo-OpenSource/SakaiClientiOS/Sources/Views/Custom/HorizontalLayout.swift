//
//  HorizontalLayout.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 6/10/18.
//  Modified by Krunk
//

import UIKit

/// A CollectionViewLayout to scroll horizontally
class HorizontalLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .horizontal
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
