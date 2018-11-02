//
//  mainDisplayViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

import UIKit
import CoreData

class mainDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var arrLabel = [String]()
    var arrImg = [UIImage]()
    var addedImages = [NSManagedObject]()
    
    var hotspots = [HotspotMO]()
    var photo: PhotosMO?
    
    var mainEditIsTapped : Bool = false;
    let headerID = "headerID"
    
    @IBOutlet weak var collectionView: UICollectionView! // = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
    
    let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    func load () {
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["photos"]

        do {
            let hotspots = try PersistenceService.context.fetch(fetchRequest)
            self.hotspots = hotspots

            for data in hotspots as [NSManagedObject]{
                if(data.value(forKey: "name") != nil) {
                    arrLabel.append(data.value(forKey: "name") as! String)
                }
                // pictures obtained in collection view
                /*
                if(data.value(forKey: "picture") != nil) {
                    let image = data.value(forKey: "picture") as? NSData
                    arrImg.append(UIImage(data: image! as Data)!)
                    // arrImg.append(data.value(forKey: "picture") as! UIImage)
                } else {
                    arrImg.append(UIImage(named: "home")!)
                }*/
            
            }
        } catch {
            print("failed fetching")
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
        if(mainEditIsTapped) {
            collectionView.reloadData()
        }
        mainEditIsTapped = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func mainEditTapped(_ sender: UIButton) {
        mainEditIsTapped = !mainEditIsTapped
        collectionView.reloadData()
        print("MainEditTapped")
        
    
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotspots.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        let photosMO = hotspots[indexPath.row].photos.allObjects
        let photo = (photosMO[0] as AnyObject).value(forKey: "photo")
        cell.image.image = (UIImage(data: photo as! Data))
        cell.label.text = arrLabel[indexPath.row]

        // Check if editing is enabled, if it is, show a white border around all hotspots and show a gear icon
        if(mainEditIsTapped) {
            cell.cellEditButton.isHidden = false
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 3
        } else {
            cell.cellEditButton.isHidden = true
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
 
    // checks which hotspot user selected
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(String(indexPath.row))
        print("tapped hotspot")
        
        let overviewVC = storyboard?.instantiateViewController(withIdentifier: "HotspotOverviewViewController") as! HotspotOverviewViewController
        overviewVC.selectedHotspot = hotspots[indexPath.row]
        
   
        for photos in hotspots[indexPath.row].photos {
            addedImages.append(photos as! NSManagedObject)
        }
        
        overviewVC.addedImages = addedImages
        
        navigationController?.pushViewController(overviewVC, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
