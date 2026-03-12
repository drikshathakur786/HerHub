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
    var password: String?  // Optional - managed by Supabase Auth
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
    
    // MARK: - Memberwise Initializer (for creating users in code)
    init(
        id: UUID = UUID(),
        email: String? = nil,
        phoneNumber: String? = nil,
        password: String? = nil,
        userName: String? = nil,
        userPicture: String? = nil,
        dateOfBirth: Date? = nil,
        joinedCommunityIDs: [UUID]? = nil,
        createdCommunityIDs: [UUID]? = nil,
        healthConditions: [String]? = nil,
        baselineProfile: CycleBaselineProfile? = nil,
        recentCheckIns: [CycleCheckIn]? = nil,
        latestPrediction: CyclePrediction? = nil
    ) {
        self.id = id
        self.email = email
        self.phoneNumber = phoneNumber
        self.password = password
        self.userName = userName
        self.userPicture = userPicture
        self.dateOfBirth = dateOfBirth
        self.joinedCommunityIDs = joinedCommunityIDs
        self.createdCommunityIDs = createdCommunityIDs
        self.healthConditions = healthConditions
        self.baselineProfile = baselineProfile
        self.recentCheckIns = recentCheckIns
        self.latestPrediction = latestPrediction
    }
    
    // MARK: - Custom decoder (for decoding from Supabase)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        userName = try container.decodeIfPresent(String.self, forKey: .userName)
        userPicture = try container.decodeIfPresent(String.self, forKey: .userPicture)
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        joinedCommunityIDs = try container.decodeIfPresent([UUID].self, forKey: .joinedCommunityIDs)
        createdCommunityIDs = try container.decodeIfPresent([UUID].self, forKey: .createdCommunityIDs)
        healthConditions = try container.decodeIfPresent([String].self, forKey: .healthConditions)
        baselineProfile = try container.decodeIfPresent(CycleBaselineProfile.self, forKey: .baselineProfile)
        recentCheckIns = try container.decodeIfPresent([CycleCheckIn].self, forKey: .recentCheckIns)
        latestPrediction = try container.decodeIfPresent(CyclePrediction.self, forKey: .latestPrediction)
    }
}



