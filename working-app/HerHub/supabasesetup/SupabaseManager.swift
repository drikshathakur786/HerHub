//
//  SupabaseManager.swift
//  HerHub
//
//  Created by Dhruv on 10/11/25.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabaseUrl = URL(string: "https://ecmyckxjxofrpodzrocj.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjbXlja3hqeG9mcnBvZHpyb2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NjQzOTksImV4cCI6MjA3ODM0MDM5OX0.JpDuj0g3TosgDVQxO2sccZ7RJWFY6JZRCD6S1N9cWLM"
    
    let client: SupabaseClient
    
    private init() {
        
        
         client = SupabaseClient(
             supabaseURL: supabaseUrl,
             supabaseKey: supabaseKey,
             options: .init(
                     auth: .init(
                         autoRefreshToken: true,
                         emitLocalSessionAsInitialSession: true  // ← FIX
                     )
                 )
         )
        
         print("✅ Supabase client initialized successfully")
     }
}
