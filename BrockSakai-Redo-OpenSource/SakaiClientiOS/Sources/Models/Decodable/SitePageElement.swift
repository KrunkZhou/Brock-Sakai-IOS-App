//
//  RawSitePage.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 8/31/18.
//  Modified by Krunk
//

import Foundation

struct SitePageElement: Decodable {
    let id: String
    let title: String?
    let siteId: String
    let url: String
}
