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
        
        // Standardized Background Gradient
        let bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = view.bounds
        bgGradientLayer.colors = [
            UIColor(red: 1.0, green: 0.941, blue: 0.961, alpha: 1.0).cgColor,
            UIColor(red: 0.961, green: 0.827, blue: 0.922, alpha: 1.0).cgColor
        ]
        bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(bgGradientLayer, at: 0)
        
        title = "Community"
        
        communitiesCollectionView.delegate = self
        communitiesCollectionView.dataSource = self
        
        
        featuredTableView.delegate = self
        featuredTableView.dataSource = self
        featuredTableView.rowHeight = UITableView.automaticDimension
        
   
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: NSNotification.Name("RefreshCommunityData"),
            object: nil
        )
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
    }
    
    
    @objc func handleRefresh() {
        communitiesCollectionView.reloadData()
        loadFeaturedData()
        print("Data refreshed via Notification!")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFeaturedData()
        communitiesCollectionView.reloadData()
        featuredTableView.reloadData()
    }
    
    func loadFeaturedData() {
        allPosts = CommunityManager.shared.getFeaturedPosts()
            featuredTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frame on layout changes
        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            gradientLayer.frame = view.bounds
        }
    }

}

extension CommunityViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

                if indexPath.section == 0 {
                    return CGSize(width: 120, height: 130)
                }
                else {
                    let width = collectionView.frame.width - 32
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


extension CommunityViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return CommunityManager.shared.getJoinedCommunities().count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCommunityCell", for: indexPath) as! AddCommunityCell
            return cell
        }

        let communities = CommunityManager.shared.getJoinedCommunities()
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
                
                // IMPORTANT: Set the callback to refresh when community is created
                createVC.onCommunityCreated = { [weak self] in
                    self?.communitiesCollectionView.reloadData()
                    self?.loadFeaturedData()
                }
                
                self.present(createVC, animated: true)
            }
            return
        }

        let communities = CommunityManager.shared.getJoinedCommunities()
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
