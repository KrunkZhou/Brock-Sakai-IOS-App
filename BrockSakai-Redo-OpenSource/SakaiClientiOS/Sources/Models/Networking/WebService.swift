//
//  WebService.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 1/1/19.
//  Modified by Krunk
//

import Foundation
import WebKit

protocol WebService {
    var processPool: WKProcessPool { get }
    var cookies: [HTTPCookie]? { get }
}
