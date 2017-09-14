//
//  SLShoppingListData.swift
//  ShoppingList
//
//  Created by Mac on 2017/09/09.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

struct SLShoppingListData {
    
    static var sharedInstance = SLShoppingListData()
    
    var tabBarController:UITabBarController?
    var trashButtonItem:UIBarButtonItem?
    var tabDict = [Int:[[String : Any]]]()
    
    mutating func setDataArray(aDataArray:[[String : Any]]) {
        tabDict[tabBarController!.selectedIndex] = aDataArray
    }
    
    func getDataArray() -> [[String : Any]] {
        
        let keyExists = tabDict[tabBarController!.selectedIndex] != nil
        if keyExists {
            return tabDict[tabBarController!.selectedIndex]!
        }
        return [[String : Any]]()
    }
    
    func saveData() {
        var filePath:String = ""
        filePath = String(format: "FinalList%d", tabBarController!.selectedIndex)

        filePath = self.dataFilePath(saveFileName: filePath)
        let array = tabDict[tabBarController!.selectedIndex]! as NSArray
        let result = array.write(toFile: filePath, atomically: true)
        if result {
            print("good!")
        }else {
            print("error")
        }
        
//        let result = NSKeyedArchiver.archiveRootObject(tabDict[tabBarController!.selectedIndex]!, toFile: filePath)
//        if result {
//            print("good!")
//        }else {
//            print("error")
//        }
    }
    
    func dataFilePath(saveFileName:String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return String(paths[0]) + String(format: "/%@.plist", saveFileName)
    }

}
