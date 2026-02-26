//
//  CommunityViewController.swift
//  HerHub
//
//  Created by Driksha Thakur on 13/11/25.
//

import UIKit

class CommunityViewController: UIViewController{
    
    @IBOutlet weak var communitiesCollectionView: UICollectionView!
    
    var allPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = nil
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        let viewAllItem = UIBarButtonItem(
            title: "View All",
            style: .plain,
            target: self,
            action: #selector(didTapViewAll)
        )
        navigationItem.rightBarButtonItem = viewAllItem
        
        communitiesCollectionView.delegate = self
        communitiesCollectionView.dataSource = self
        communitiesCollectionView.register(
            FeaturedPostCollectionCell.self,
            forCellWithReuseIdentifier: "FeaturedPostCollectionCell"
        )
        communitiesCollectionView.register(
            FeaturedEmptyStateCell.self,
            forCellWithReuseIdentifier: "FeaturedEmptyStateCell"
        )
        
        communitiesCollectionView.register(
            FeaturedHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "FeaturedHeaderView"
        )
        
        if #available(iOS 13.0, *) {
            communitiesCollectionView.setCollectionViewLayout(createLayout(), animated: false)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefresh),
            name: NSNotification.Name("RefreshCommunityData"),
            object: nil
        )
    }
    
    
    @objc func handleRefresh() {
        communitiesCollectionView.reloadData()
        loadFeaturedData()
        print("Data refreshed via Notification!")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        title = nil
        loadFeaturedData()
        communitiesCollectionView.reloadData()
    }
    
    func loadFeaturedData() {
        allPosts = CommunityManager.shared.getFeaturedPosts()
        communitiesCollectionView.reloadData()
    }
    
    @objc private func didTapViewAll() {
        let storyboard = UIStoryboard(name: "community", bundle: nil)
        if let allCommunitiesVC = storyboard.instantiateViewController(withIdentifier: "AllCommunitiesVC") as? AllCommunitiesViewController {
            let navController = UINavigationController(rootViewController: allCommunitiesVC)
            navController.navigationBar.prefersLargeTitles = true
            navController.modalPresentationStyle = .pageSheet
            
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            
            present(navController, animated: true)
        }
    }

}
@available(iOS 13.0, *)
private func createLayout() -> UICollectionViewCompositionalLayout {
    
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
        
        if sectionIndex == 0 {
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120),
                                                  heightDimension: .absolute(130))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(120),
                                                   heightDimension: .absolute(130))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
            section.interGroupSpacing = 12
           
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(32))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        } else {
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(180))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(180))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
            section.interGroupSpacing = 12
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(32))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    return layout
}


extension CommunityViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return CommunityManager.shared.getJoinedCommunities().count + 1
        case 1:
            // Show empty-state cell when there are no featured posts yet
            return allPosts.isEmpty ? 1 : allPosts.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
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
        
        if allPosts.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedEmptyStateCell", for: indexPath) as! FeaturedEmptyStateCell
            cell.onBrowseTapped = { [weak self] in
                self?.didTapViewAll()
            }
            return cell
        } else {
            let post = allPosts[indexPath.item]
            let community = CommunityManager.shared.getCommunity(by: post.communityID)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedPostCollectionCell", for: indexPath) as! FeaturedPostCollectionCell
            cell.configure(post: post, community: community)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "FeaturedHeaderView",
            for: indexPath
        ) as! FeaturedHeaderView
        
        header.titleLabel.text = indexPath.section == 0 ? "My communities" : "Featured"
        return header
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            return
        }
        
        if indexPath.item == 0 {
            let storyboard = UIStoryboard(name: "community", bundle: nil)
            if let createVC = storyboard.instantiateViewController(withIdentifier: "CreateCommunityVC") as? CreateCommunityViewController {
                createVC.modalPresentationStyle = .pageSheet
                if let sheet = createVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
              
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

