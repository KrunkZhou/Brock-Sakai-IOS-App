//
//  RawSite.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 8/31/18.
//  Modified by Krunk
//

import Foundation

struct SiteCollection: Decodable {
    let siteCollection: [Site]

    enum CodingKeys: String, CodingKey {
        case siteCollection = "site_collection"
    }
}
