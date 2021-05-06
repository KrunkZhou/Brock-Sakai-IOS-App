//
//  RawAnnouncement.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 8/31/18.
//  Modified by Krunk
//

import Foundation

struct AnnouncementCollection: Decodable {
    let announcementCollection: [Announcement]

    enum CodingKeys: String, CodingKey {
        case announcementCollection = "announcement_collection"
    }
}
