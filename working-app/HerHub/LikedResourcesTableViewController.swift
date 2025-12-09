//
//  LikedResourcesTableViewController.swift
//  HerHub
//
//  Created by mahika behal on 21/11/25.
//

import UIKit

class LikedResourcesTableViewController: UITableViewController {
    
    private var likedResources: [Resource] = []

    
    // TEMP user ID (replace later with real logged-in user's ID)
    private let userId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Liked Articles"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Fetch all articles and filter liked ones
        let allResources = ResourceManager.shared.getAllResources()
        likedResources = allResources.filter { $0.isLiked?.contains(userId) == true }
    
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return likedResources.count
    }



    override func tableView(_ tableView: UITableView,
                               cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCellIdentifier",
                                                    for: indexPath) as! ResourceCell

           let item = likedResources[indexPath.row]
           cell.configure(with: item)   // same UI as Resources screen
           return cell
       }
    //When user taps a liked card → open detail page
      override func tableView(_ tableView: UITableView,
                              didSelectRowAt indexPath: IndexPath) {

          let selected = likedResources[indexPath.row]

          if let detailVC = storyboard?.instantiateViewController(
              withIdentifier: "ArticleDetailViewController"
          ) as? ArticleDetailViewController {

              detailVC.resource = selected
              navigationController?.pushViewController(detailVC, animated: true)
          }
      }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280
    }
   
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
