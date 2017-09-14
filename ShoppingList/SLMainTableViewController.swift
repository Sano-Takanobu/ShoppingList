//
//  SLMainTableViewController.swift
//  ShoppingList
//
//  Created by Mac on 2017/09/09.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class SLMainTableViewController: UITableViewController, SLEditViewControllerDelegate, UITabBarControllerDelegate {

    var mainVCArray = [[String : Any]]()//[(status:Bool, data:String)]()
    var selectedIndexPath:IndexPath?
    var editText:String = ""
    var newText = [String]()
    var isEditingMode = false
    var font = UIFont.systemFont(ofSize: 17.0)
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.editText = ""
        self.newText.removeAll()
    }
    
    func changingTrashAndEditButton() {
        let trashButton = self.navigationController?.topViewController?.navigationItem.rightBarButtonItems?[1]
        trashButton?.isEnabled = false
        let editButton = self.navigationController?.topViewController?.navigationItem.leftBarButtonItem
        
        if mainVCArray.count > 0 {
            editButton?.isEnabled = true
            for data in mainVCArray {
                let status = data["status"] as! Bool
                if status {
                    trashButton?.isEnabled = true
                    break
                }
            }
            if UIBarButtonItemStyle.done == self.navigationController?.topViewController?.navigationItem.leftBarButtonItem?.style {
                trashButton?.isEnabled = false
            }
        }else {
            let addButton = self.navigationController?.topViewController?.navigationItem.rightBarButtonItems?[0]
            addButton?.isEnabled = true
            
            self.tableView.allowsSelection = true
            addButton?.isEnabled = true
            trashButton?.isEnabled = false
            let buttom = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(_:)))
            buttom.isEnabled = false
            self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = buttom
            self.setEditing(true, animated: true)

        }
    }
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { action -> Void in
            self.deleteAll()
        }
        actionSheetController.addAction(deleteAction)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        isEditingMode = false
        self.performSegue(withIdentifier: "showEditViewController", sender: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        let addButton = self.navigationController?.topViewController?.navigationItem.rightBarButtonItems?[0]
        let trashButton = self.navigationController?.topViewController?.navigationItem.rightBarButtonItems?[1]

        self.setEditing(false, animated: true)

        if UIBarButtonItemStyle.done == self.navigationController?.topViewController?.navigationItem.leftBarButtonItem?.style {
            self.tableView.allowsSelection = true
            addButton?.isEnabled = true
            trashButton?.isEnabled = true
            let buttom = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed(_:)))
            self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = buttom
            self.setEditing(true, animated: true)
            self.changingTrashAndEditButton()
        }else {
            self.tableView.allowsSelection = false
            addButton?.isEnabled = false
            trashButton?.isEnabled = false
            let buttom = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(editButtonPressed(_:)))
            self.navigationController?.topViewController?.navigationItem.leftBarButtonItem = buttom
            self.setEditing(false, animated: true)
        }
    }
    
    func deleteAll() {
        CATransaction.begin()
        self.tableView.isUserInteractionEnabled = false
        CATransaction.setCompletionBlock {
            SLShoppingListData.sharedInstance.setDataArray(aDataArray: self.mainVCArray)
            SLShoppingListData.sharedInstance.saveData()
            self.changingTrashAndEditButton()
            self.tableView.reloadData()
            self.tableView.isUserInteractionEnabled = true
        }
        
        tableView.beginUpdates()
        
        var arrayForindexSet = [Int]()
        var i = 0
        for data in mainVCArray {
            let status = data["status"] as! Bool
            if status {
                self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .top)
                arrayForindexSet.append(i)
            }
            i += 1
        }
        
        let indexSet = IndexSet(arrayForindexSet)
        mainVCArray.remove(indices: indexSet)
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    func editedList(aEditText: String, aNewText: [String]) {
        editText = aEditText
        for text in aNewText {
            newText.insert(text, at: 0)
        }
    }
    
    func newList(aNewText: [String]) {
        for text in aNewText {
            if !text.isEmpty {
                newText.insert(text, at: 0)
            }
        }
    }
    
    func dataFilePath(saveFileName:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return String(paths[0]) + String(format: "/%@.plist", saveFileName)
    }
    
    func addListData() {
        CATransaction.begin()
        self.tableView.isUserInteractionEnabled = false
        CATransaction.setCompletionBlock {
            SLShoppingListData.sharedInstance.setDataArray(aDataArray: self.mainVCArray)
            SLShoppingListData.sharedInstance.saveData()
            self.changingTrashAndEditButton()
            self.tableView.reloadData()
            self.tableView.isUserInteractionEnabled = true
        }
        
        tableView.beginUpdates()
        if !editText.isEmpty {
            let status = mainVCArray[(selectedIndexPath?.row)!]["status"] as! Bool
            let newDic:[String : Any] = ["status":status, "data":editText]
            mainVCArray[(selectedIndexPath?.row)!] = newDic
            self.tableView.reloadRows(at: [selectedIndexPath!], with: .fade)
        }

        var i = 0
        for text in newText {
            tableView.insertRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            i += 1
            let newDic:[String : Any] = ["status":false, "data":text]
            mainVCArray.insert(newDic, at: 0)
        }
        tableView.endUpdates()
        CATransaction.commit()
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
        DispatchQueue.main.async {
            if .ended == sender.state {
                return
            }
            let p = sender.location(in: self.tableView)
            if (self.tableView.indexPathForRow(at: p) != nil) {
                self.selectedIndexPath = self.tableView.indexPathForRow(at: p)
            }
            self.isEditingMode = true
            self.performSegue(withIdentifier: "showEditViewController", sender: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.setEditing(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SLShoppingListData.sharedInstance.tabBarController?.delegate = self
        
        self.tableView.allowsSelectionDuringEditing = true
        
        let longPressRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(SLMainTableViewController.longPressed(_:)))
        longPressRecognizer.minimumPressDuration = 1.0
        self.tableView.addGestureRecognizer(longPressRecognizer)
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)

        let barButtonItem = self.navigationController?.topViewController?.navigationItem.rightBarButtonItems?[1]
        SLShoppingListData.sharedInstance.trashButtonItem = barButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.title = SLShoppingListData.sharedInstance.tabBarController?.tabBar.items![(SLShoppingListData.sharedInstance.tabBarController?.selectedIndex)!].title

        mainVCArray = SLShoppingListData.sharedInstance.getDataArray()

        if mainVCArray.isEmpty {
            let index = SLShoppingListData.sharedInstance.tabBarController!.selectedIndex
            var fileName:String = ""
            fileName = String(format: "FinalList%d", index)
            
            if let dataArray = NSArray(contentsOfFile: self.dataFilePath(saveFileName: fileName)) {
                SLShoppingListData.sharedInstance.setDataArray(aDataArray: dataArray as! [[String : Any]])
            }else {
                var newDic:[String : Any] = ["status":false, "data":"+ボタンで追加"]
                mainVCArray.append(newDic)
                newDic = ["status":false, "data":"ゴミ箱で全削除"]
                mainVCArray.append(newDic)
                newDic = ["status":true, "data":"編集でスワイプで削除"]
                mainVCArray.append(newDic)
                newDic = ["status":true, "data":"タップで"]
                mainVCArray.append(newDic)
                
                SLShoppingListData.sharedInstance.setDataArray(aDataArray:mainVCArray)
                SLShoppingListData.sharedInstance.saveData()
            }
            mainVCArray = SLShoppingListData.sharedInstance.getDataArray()
        }
        
        if !editText.isEmpty || newText.count > 0 {
            self.addListData()
            return
        }
        
        self.changingTrashAndEditButton()
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainVCArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        
        font = (cell.textLabel?.font)!
        cell.textLabel?.attributedText = nil
        cell.textLabel?.text = nil
        if true == mainVCArray[indexPath.row]["status"] as? Bool {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: mainVCArray[indexPath.row]["data"] as! String)
            attributeString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value:UIColor.lightGray, range: NSMakeRange(0, attributeString.length))
            
            let color = UserDefaults.standard.color(forKey: "globalColor")!
            attributeString.addAttribute(NSAttributedStringKey.strikethroughColor, value:color, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
        }else {
            cell.textLabel?.text = mainVCArray[indexPath.row]["data"] as? String
        }

        return cell
    }
    
    func deletedText(deleteString:String) -> NSAttributedString {
        let attributes = [
            NSAttributedStringKey.font.rawValue: UIFont(name: "HiraKakuProN-W3", size: 15.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            NSAttributedStringKey.strikethroughColor:UIColor.red,
            NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle
        ] as! [NSAttributedStringKey : Any]

        let attributedText = NSAttributedString(string: deleteString, attributes: attributes)
        
        return attributedText
    }

    // https://stackoverflow.com/a/34957350
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if self.tableView.allowsSelection {
            return false
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if self.tableView.allowsSelection {
            return .none
        }
        return .delete
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CATransaction.begin()
            self.tableView.isUserInteractionEnabled = false
            CATransaction.setCompletionBlock {
                SLShoppingListData.sharedInstance.setDataArray(aDataArray: self.mainVCArray)
                SLShoppingListData.sharedInstance.saveData()
                self.changingTrashAndEditButton()
                self.tableView.reloadData()
                self.tableView.isUserInteractionEnabled = true
            }
            
            tableView.beginUpdates()
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            mainVCArray.remove(at: indexPath.row)
            
            tableView.endUpdates()
            CATransaction.commit()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if fromIndexPath != to {
            let toMoveDict = mainVCArray[fromIndexPath.row]
            mainVCArray.remove(at: fromIndexPath.row)
            mainVCArray.insert(toMoveDict, at: to.row)
            SLShoppingListData.sharedInstance.setDataArray(aDataArray: mainVCArray)
            SLShoppingListData.sharedInstance.saveData()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.changingTrashAndEditButton()
                self.tableView.reloadData()
            })
        }
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let status = mainVCArray[indexPath.row]["status"] as! Bool
        
        let selectedText = mainVCArray[indexPath.row]["data"] as! String
        let newDic:[String : Any] = ["status":!status, "data":selectedText]

        CATransaction.begin()
        self.tableView.isUserInteractionEnabled = false
        CATransaction.setCompletionBlock {
            SLShoppingListData.sharedInstance.setDataArray(aDataArray: self.mainVCArray)
            SLShoppingListData.sharedInstance.saveData()
            self.changingTrashAndEditButton()
            self.tableView.reloadData()
            self.tableView.isUserInteractionEnabled = true
        }
        
        tableView.beginUpdates()
        
        if status {
            if 0 == indexPath.row {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }else {
                self.tableView.deleteRows(at: [indexPath], with: .top)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            }
            mainVCArray.remove(at: indexPath.row)
            mainVCArray.insert(newDic, at: 0)
        }else {
            if mainVCArray.count - 1 == indexPath.row{
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.insertRows(at: [IndexPath(row: mainVCArray.count - 1, section: 0)], with: .fade)
            }else {
                self.tableView.deleteRows(at: [indexPath], with: .top)
                self.tableView.insertRows(at: [IndexPath(row: mainVCArray.count - 1, section: 0)], with: .top)
            }
            mainVCArray.remove(at: indexPath.row)
            mainVCArray.append(newDic)
        }
        tableView.endUpdates()
        CATransaction.commit()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if "showEditViewController" == segue.identifier {
            self.editText = ""
            self.newText.removeAll()
            let vc = ((segue.destination as! UINavigationController).topViewController) as! SLEditViewController
            vc.delegate = self
            vc.font = font
            vc.isEditingMode = isEditingMode
            if isEditingMode {
                let selectedText = mainVCArray[(selectedIndexPath?.row)!]["data"] as! String
                vc.text = selectedText
            }
        }
    }
}
