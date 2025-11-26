//
//  AllCommunitiesViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 17/11/25.
//

import UIKit

class AllCommunitiesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
        var communities: [Community] = []
        
        // We'll fake a user ID for this example to test the "Join" button
//        let myUserID = UUID()
        let myUserID = CommunityManager.shared.currentUserID
        
        override func viewDidLoad() {
            super.viewDidLoad()

            // Set the title you wanted
            title = "All Communities"
            navigationController?.navigationBar.prefersLargeTitles = true
            
            // Load the data
            loadData()
            // Set the "brains" for the table view
            tableView.delegate = self
            tableView.dataSource = self
            
            // This is CRITICAL. It tells the table to auto-size the cells.
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 120 // A guess to help performance
            
            
            
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        // 1. Get the ID of the selected community
//        let selectedCommunityID = communities[indexPath.row].id
//        
//        // 2. Ask the Manager for the FRESH copy of this community
//        // This ensures we get the version that has the posts!
//        guard let freshCommunity = CommunityManager.shared.getCommunity(by: selectedCommunityID) else {
//            print("Error: Could not find community with ID \(selectedCommunityID)")
//            return
//        }
//        
//        print("DEBUG: Selecting \(freshCommunity.name), Post Count: \(freshCommunity.posts.count)") // Debug print
//        
//        // 3. Navigate
//        let storyboard = UIStoryboard(name: "community", bundle: nil)
//        if let detailVC = storyboard.instantiateViewController(withIdentifier: "CommunityDetailVC") as? CommunityDetailViewController {
//            
//            // 4. Pass the FRESH data
//            detailVC.community = freshCommunity
//            
//            navigationController?.pushViewController(detailVC, animated: true)
//        }
        // 1. Get the community for the row tapped
            let selectedCommunity = communities[indexPath.row]
            
            // 2. Load the storyboard
            let storyboard = UIStoryboard(name: "community", bundle: nil)
            
            // 3. Create the Detail Screen using the ID we set in Step 2
            if let detailVC = storyboard.instantiateViewController(withIdentifier: "CommunityDetailVC") as? CommunityDetailViewController {
                
                // 4. PASS THE DATA (This is the missing link!)
                detailVC.community = selectedCommunity
                
                // 5. Show the screen
                navigationController?.pushViewController(detailVC, animated: true)
            }
    }
        
        func loadData() {
            communities = CommunityManager.shared.getAllCommunities()
            //tableView.reloadData()
        }
    }

    // MARK: - Table View Delegate & Data Source
    extension AllCommunitiesViewController: UITableViewDelegate, UITableViewDataSource {
        
        // This tells the table how many rows to make
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return communities.count
        }
        
        // This creates and configures each cell
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            // 1. Get your reusable cell 'template'
            let cell = tableView.dequeueReusableCell(withIdentifier: "AllCommunityCell", for: indexPath) as! AllCommunityCell
            
            // 2. Get the specific community for this row
            let community = communities[indexPath.row]
            
            print(community.name)
            
            // 3. Check if our fake user is in the member list
            let isJoined = community.members.contains(myUserID)
            
            // 4. Use your 'configure' function to set up the cell!
            cell.configure(community: community, isJoined: isJoined)
            
            return cell
        }
    }
    

    


