//
//  ResourceViewController.swift
//  HerHub
//

import UIKit

class ResourceViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var matchedArticles: [Resource] = []
    private var remainingArticles: [Resource] = []
    private var displayedArticles: [Resource] = []
    private var allArticles: [Resource] = []
    
    @objc func refreshArticles() {
        applyPersonalization(searchText: searchBar.text ?? "")
    }

    func applyPersonalization(searchText: String = "") {
        let filteredArticles: [Resource]
        if searchText.isEmpty {
            filteredArticles = allArticles
        } else {
            filteredArticles = allArticles.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        let userConditions = UserDefaults.standard.stringArray(forKey: "userHealthConditions") ?? []
        print("Retrieved Conditions:", userConditions)
        print("All Article Tags:", allArticles.map { $0.tags ?? [] })

        let normalizedConditions = userConditions.map {
            $0.lowercased().trimmingCharacters(in: .whitespaces)
        }

        if normalizedConditions.isEmpty {
            matchedArticles = []
            remainingArticles = filteredArticles
            displayedArticles = filteredArticles
        } else {
            matchedArticles = filteredArticles.filter { article in
                return article.tags?.contains { tag in
                    normalizedConditions.contains(tag.lowercased().trimmingCharacters(in: .whitespaces))
                } ?? false
            }

            remainingArticles = filteredArticles.filter { article in
                return !(article.tags?.contains { tag in
                    normalizedConditions.contains(tag.lowercased().trimmingCharacters(in: .whitespaces))
                } ?? false)
            }

            displayedArticles = matchedArticles + remainingArticles
        }

        print("Matched Count:", matchedArticles.count)
        tableView.reloadData()
    }

    

    override func viewDidLoad() {
            super.viewDidLoad()
            
        allArticles = ResourceManager.shared.getAllResources()
        applyPersonalization()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshArticles), name: NSNotification.Name("HealthConditionUpdated"), object: nil)

         
            let bgGradientLayer = CAGradientLayer()
            bgGradientLayer.frame = view.bounds
            bgGradientLayer.colors = [
                UIColor(red: 1.0, green: 0.941, blue: 0.961, alpha: 1.0).cgColor,
                UIColor(red: 0.961, green: 0.827, blue: 0.922, alpha: 1.0).cgColor
            ]
        
            bgGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            bgGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            view.layer.insertSublayer(bgGradientLayer, at: 0)
    
            navigationController?.navigationBar.prefersLargeTitles = true
            
        searchBar.delegate = self
            searchBar.placeholder = "Search any resource..."
            
            
            searchBar.backgroundImage = UIImage()
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundColor = .clear
          
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            
                textField.backgroundColor = .white
                textField.layer.cornerRadius = 22
                textField.clipsToBounds = true
               
                textField.layer.shadowColor = UIColor.clear.cgColor
                textField.layer.shadowOpacity = 0
                textField.layer.shadowRadius = 0
                textField.layer.shadowOffset = .zero
                
               
                textField.borderStyle = .none
                textField.layer.borderWidth = 0
            }
        
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.backgroundColor = .clear
            
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
    @IBAction func openLikedResources(_ sender: UIButton) {
        performSegue(withIdentifier: "showLikedResources", sender: nil)
    }


        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            allArticles = ResourceManager.shared.getAllResources()
            applyPersonalization(searchText: searchBar.text ?? "")
        }
    
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // Update gradient frame on layout changes
            if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                gradientLayer.frame = view.bounds
            }
        }
    }
extension ResourceViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyPersonalization(searchText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


    
    extension ResourceViewController: UITableViewDelegate, UITableViewDataSource {
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return matchedArticles.isEmpty ? 1 : 2
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if !matchedArticles.isEmpty {
                return section == 0 ? matchedArticles.count : remainingArticles.count
            }
            return displayedArticles.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 280
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCellIdentifier", for: indexPath) as! ResourceCell
            let item: Resource
            if !matchedArticles.isEmpty {
                item = indexPath.section == 0 ? matchedArticles[indexPath.row] : remainingArticles[indexPath.row]
            } else {
                item = displayedArticles[indexPath.row]
            }
            cell.configure(with: item)
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "detailPage", sender: indexPath)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "detailPage",
               let destination = segue.destination as? ArticleDetailViewController,
               let indexPath = sender as? IndexPath {
                
                let item: Resource
                if !matchedArticles.isEmpty {
                    item = indexPath.section == 0 ? matchedArticles[indexPath.row] : remainingArticles[indexPath.row]
                } else {
                    item = displayedArticles[indexPath.row]
                }
                destination.resource = item
            }
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            guard !matchedArticles.isEmpty else { return nil }
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            label.textColor = UIColor(red: 0.5, green: 0.0, blue: 0.2, alpha: 1.0)
            
            if section == 0 {
                label.text = "👉 Recommended For You"
                label.isHidden = matchedArticles.isEmpty
            } else {
                label.text = "All Resources"
                label.isHidden = remainingArticles.isEmpty
            }
            
            headerView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])
            
            return headerView
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            guard !matchedArticles.isEmpty else { return 0 }
            if section == 0 && matchedArticles.isEmpty { return 0 }
            if section == 1 && remainingArticles.isEmpty { return 0 }
            return 40
        }
    }

