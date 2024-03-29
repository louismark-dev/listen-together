//
//  Resource.swift
//  Cider
//
//  Created by Scott Hoyt on 8/9/17.
//  Copyright © 2017 Scott Hoyt. All rights reserved.
//

import Foundation

public struct Resource<AttributesType: Codable, RelationshipsType: Codable>: Codable, Hashable, Identifiable {
    
    public var id: UUID = UUID()
    public let storeID: String
    public let type: MediaType
    public let href: String
    public let attributes: AttributesType?
    public let relationships: RelationshipsType?
    // let meta: Meta
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(href)
    }
    
    public static func == (lhs: Resource<AttributesType, RelationshipsType>, rhs: Resource<AttributesType, RelationshipsType>) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case storeID = "id"
        case type
        case href
        case attributes
        case relationships
    }
}
