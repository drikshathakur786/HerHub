//
//  CommunityViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 13/11/25.
//

import UIKit

class CommunityViewController: UIViewController{

    @IBOutlet weak var communitiesCollectionView: UICollectionView!
    @IBOutlet weak var featuredTableView: UITableView!
    
    var allPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Community"
        
        // Do any additional setup after loading the view.
        communitiesCollectionView.delegate = self
        communitiesCollectionView.dataSource = self
        
        
        featuredTableView.delegate = self
        featuredTableView.dataSource = self
        featuredTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Refresh featured posts list
        loadFeaturedData()

        // Refresh community cards
        communitiesCollectionView.reloadData()

        // Refresh featured posts table
        featuredTableView.reloadData()
    }


    // Add this helper function to get the posts
    func loadFeaturedData() {
        allPosts = CommunityManager.shared.getFeaturedPosts()
            featuredTableView.reloadData()
    }

}

//
// MARK: - UICollectionView Flow Layout
//
extension CommunityViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

//        return CGSize(width: 120, height: 100)
        // Section 0: Top Cards (Add + Communities)
                if indexPath.section == 0 {
                    return CGSize(width: 120, height: 130)
                }
                // Section 1: Featured Posts
                else {
                    // Full screen width minus padding (16 left + 16 right = 32)
                    let width = collectionView.frame.width - 32
                    
                    // Fixed height for posts (e.g., 350 or 400)
                    // You can adjust this number to make the cards taller/shorter
                    return CGSize(width: width, height: 350)
                }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}


//
// MARK: - UICollectionView DataSource & Delegate
//
extension CommunityViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CommunityManager.shared.getAllCommunities().count + 1  // +1 for "+"
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCommunityCell", for: indexPath) as! AddCommunityCell
            return cell
        }

        let communities = CommunityManager.shared.getAllCommunities()
        let community = communities[indexPath.item - 1]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommunityInfoCell", for: indexPath) as! CommunityInfoCell

        cell.configure(
            title: community.name,
            members: "\(community.members.count)",
            iconName: "heart.fill",
            color: UIColor(named: community.themeColor) ?? .systemPink
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.item == 0 {
            let storyboard = UIStoryboard(name: "community", bundle: nil)
            if let createVC = storyboard.instantiateViewController(withIdentifier: "CreateCommunityVC") as? CreateCommunityViewController {
                createVC.modalPresentationStyle = .pageSheet
                if let sheet = createVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
                self.present(createVC, animated: true)
            }
            return
        }

        let communities = CommunityManager.shared.getAllCommunities()
        let selectedCommunity = communities[indexPath.item - 1]

        navigateToDetail(with: selectedCommunity)
    }

    func navigateToDetail(with community: Community) {
        let storyboard = UIStoryboard(name: "community", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "CommunityDetailVC") as? CommunityDetailViewController {
            detailVC.community = community
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

//
// MARK: - UITableView
//
extension CommunityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FeaturedPostCell", for: indexPath) as! FeaturedPostCell
        let post = allPosts[indexPath.row]
        let community = CommunityManager.shared.getCommunity(by: post.communityID)
        cell.configure(post: post, community: community)
        
        return cell
    }
}
