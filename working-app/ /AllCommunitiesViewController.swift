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
    
    var myUserID: UUID? {
        return AuthManager.shared.currentUser?.id
    }
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = "All Communities"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
            
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
            
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedCommunity = communities[indexPath.row]
        
        let isJoined = (myUserID != nil) ? selectedCommunity.members.contains(myUserID!) : false
                
        if isJoined {
            let storyboard = UIStoryboard(name: "community", bundle: nil)
                    
                if let detailVC = storyboard.instantiateViewController(withIdentifier: "CommunityDetailVC") as? CommunityDetailViewController {
                        detailVC.community = selectedCommunity
                        navigationController?.pushViewController(detailVC, animated: true)
                    }
        } else {
                let alert = UIAlertController(title: "Join Community", message: "You must join this community to view its posts.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true)
                    
                    tableView.deselectRow(at: indexPath, animated: true)
        }
        
        
        
    }
       
    
    func loadData() {
        communities = CommunityManager.shared.getAllCommunities()
    }
}

   
extension AllCommunitiesViewController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communities.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllCommunityCell", for: indexPath) as! AllCommunityCell
            
        let community = communities[indexPath.row]
            
        print(community.name)
         
        let isJoined: Bool
        if let userID = myUserID {
            isJoined = community.members.contains(userID)
        } else {
            isJoined = false
        }
      
        cell.configure(community: community, isJoined: isJoined)
        
        cell.onJoinTapped = { [weak self] in
            guard let self = self else { return }
            guard let currentID = self.myUserID else { return }
                    
            CommunityManager.shared.joinCommunity(communityID: community.id, userID: currentID)
                    print("Joined \(community.name)!")
                    
            self.loadData()
                    
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
            NotificationCenter.default.post(name: NSNotification.Name("NewCommunityAdded"), object: nil)
        }
            
        return cell
    }
}
    

    


