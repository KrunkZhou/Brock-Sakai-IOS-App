//
//  NavigationAnimatable.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 1/11/19.
//  Modified by Krunk
//

import Foundation
import UIKit

protocol NavigationAnimatable {
    func animationControllerForPop(to controller: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func animationControllerForPush(to controller: UIViewController) -> UIViewControllerAnimatedTransitioning?
}
