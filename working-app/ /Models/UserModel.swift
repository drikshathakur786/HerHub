//
//  UserModel.swift
//  HerHub
//
//  Created by Nihar Sandhu on 28/10/25.
//

import Foundation

struct User: Codable, Equatable {
    var id = UUID()
    var email: String?
    var phoneNumber: String?
    var password: String
    var userName: String?
    var userPicture: String?
    var dateOfBirth: Date?

    var joinedCommunityIDs: [UUID]?     
    var createdCommunityIDs: [UUID]?  
    var healthConditions: [String]?


    // MARK: - Linked Cycle Data
    var baselineProfile: CycleBaselineProfile?      
    var recentCheckIns: [CycleCheckIn]?            
    var latestPrediction: CyclePrediction?         

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phoneNumber = "phone_number"
        case password
        case userName = "user_name"
        case userPicture = "user_picture"
        case dateOfBirth = "date_of_birth"
        case joinedCommunityIDs = "joined_community_ids"
        case createdCommunityIDs = "created_community_ids"
        case baselineProfile
        case recentCheckIns
        case latestPrediction = "latest_prediction"
        case healthConditions = "health_conditions"
    }
}



