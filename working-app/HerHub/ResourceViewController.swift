//
//  ResourceViewController.swift
//  HerHub
//

import UIKit

class ResourceViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    private var resources: [Resource] = []


    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Load all resources from ResourceManager
            resources = ResourceManager.shared.getAllResources()

            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.isTranslucent = false
            
            tableView.contentInsetAdjustmentBehavior = .never
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
    @IBAction func openLikedResources(_ sender: UIButton) {
        performSegue(withIdentifier: "showLikedResources", sender: nil)
    }


        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // Reload latest likes/bookmarks
            resources = ResourceManager.shared.getAllResources()
            tableView.reloadData()
        }
    }

    // MARK: - UITableView Delegate & DataSource
    extension ResourceViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return resources.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 280 // matches your card size
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCellIdentifier", for: indexPath) as! ResourceCell
            let item = resources[indexPath.row]
            cell.configure(with: item)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "detailPage", sender: indexPath)
        }

        // MARK: - Navigation to Detail Page
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "detailPage",
               let destination = segue.destination as? ArticleDetailViewController,
               let indexPath = sender as? IndexPath {
                
                destination.resource = resources[indexPath.row]   // FIXED
            }
        }
    }
