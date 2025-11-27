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

    // MARK: - Linked Cycle Data
    var baselineProfile: CycleBaselineProfile?      // full baseline
    var recentCheckIns: [CycleCheckIn]?            // list of check-ins
    var latestPrediction: CyclePrediction?         // full forecast

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case phoneNumber = "phone_number"
        case password
        case userName = "user_name"
        case userPicture = "user_picture"
        case baselineProfile
        case recentCheckIns
        case latestPrediction = "latest_prediction"
    }
}



