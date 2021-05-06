//
//  RawResourceItem.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 8/31/18.
//  Modified by Krunk
//

import Foundation

struct ResourceCollection: Decodable {
    let contentCollection: [ResourceItem]

    enum CodingKeys: String, CodingKey {
        case contentCollection = "content_collection"
    }
}
