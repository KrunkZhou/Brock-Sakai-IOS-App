//
//  AssignmentElement.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 12/30/18.
//  Modified by Krunk
//

import Foundation

struct AssignmentElement: Decodable {
    let title: String
    let dueTimeString: String
    let dueTime: DueTime
    let instructions: String?
    let siteId: String
    let status: String?
    let resubmissionAllowed: Bool
    let reference: String
    let maxPoints: String?
    let attachments: [AttachmentElement]?
    let submissionType: String
    let entityURL: String

    enum CodingKeys: String, CodingKey {
        case title, dueTimeString, dueTime, instructions
        case siteId = "context"
        case status
        case reference = "entityReference"
        case resubmissionAllowed = "allowResubmission"
        case maxPoints = "gradeScaleMaxPoints"
        case attachments
        case submissionType
        case entityURL
    }
}

struct DueTime: Decodable {
    let epochSecond: Date
}
