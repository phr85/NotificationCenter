import Foundation

/**
 ########################################
 SwiftNotificationCenter
 Home brewed Broadcast System in Swift :-)
 ########################################
 */

class SwiftNotificationCenter : NSObject {

    let notifications:NSMutableDictionary = NSMutableDictionary()

    
    /**
     return singelton of SwiftNotificationCenter
    */
    static let defaultCenter: SwiftNotificationCenter = {
        
        let instance = SwiftNotificationCenter()
        return instance
    }()
    
    /**
     Subscribe to given observer name and Object and block who should be executed
     */
    func addObserverForName(_ name: String, object obj: AnyObject?, usingBlock block: @escaping (String) -> Void) {
        
        let objects = [name, obj as Any, block]
        let keys = ["name", "object", "block"]
        let notificationObject = NSDictionary(objects: objects,
                                              forKeys: keys
                                                as [NSCopying]) as! [String:Any]
        
        let notificationArray:NSMutableArray = self.notifications.object(forKey: name) as? NSMutableArray ?? NSMutableArray()
        notificationArray.add(notificationObject)
        self.notifications.setValue(notificationArray, forKey: name)
    }
    
    /**
     Post given notification name the given notification
     */
    func postNotificationName(_ aName: String) {
        
        let notificationsArray:NSMutableArray = self.notifications.object(forKey: aName) as! NSMutableArray
        for case let notificationObject as NSDictionary in notificationsArray {
            let completionHandlers: (String) -> Void = notificationObject.object(forKey: "block") as! (String) -> Void
            completionHandlers(aName)
        }
    }
    
    /**
     Remove observed object with given notification name from observing.
     */
    func removeObserver(_ observer: AnyObject, notificationName name:String) {
        
        let notificationsArray:NSMutableArray = self.notifications.object(forKey: name) as! NSMutableArray
        for case let notificationObject as NSDictionary in notificationsArray {
            
            let observedObject = notificationObject.object(forKey: "object") as AnyObject
            
            if observedObject.isEqual(observer) {
                    notificationsArray.remove(notificationObject)
            }
        }
        
    }
    
}

/*
########################################
 Sample usage of SwiftNotificationCenter
########################################
*/

class ClassA : NSObject {
    
    let notificationCenter = SwiftNotificationCenter.defaultCenter
    
    override init() {
        
        super.init()
        notificationCenter.addObserverForName("notificationEvent1", object: self) { (name) in
            print("I’m ClassA and I have been raised by \(name)")
        }
        notificationCenter.addObserverForName("notificationEvent2", object: self) { (name) in
            print("I’m ClassA and I have been raised by \(name)")
        }
    }
    
    func removeObserver() {
        notificationCenter.removeObserver(self, notificationName: "notificationEvent1")
        notificationCenter.removeObserver(self, notificationName: "notificationEvent2")
    }
    
}

class ClassB : NSObject {
    
    let notificationCenter = SwiftNotificationCenter.defaultCenter
    
    override init() {
        
        super.init()
        let notificationCenter = SwiftNotificationCenter.defaultCenter
        notificationCenter.addObserverForName("notificationEvent1", object: self) { (name) in
            print("I’m ClassB and I have been raised by \(name)")
        }
        notificationCenter.addObserverForName("notificationEvent2", object: self) { (name) in
            print("I’m ClassA and I have been raised by \(name)")
        }
    }
    
    func removeObserver() {
        notificationCenter.removeObserver(self, notificationName: "notificationEvent1")
        notificationCenter.removeObserver(self, notificationName: "notificationEvent2")
    }
    
}

class MainClass : NSObject {
    
    override init() {
        
        SwiftNotificationCenter.defaultCenter.postNotificationName("notificationEvent1")
        SwiftNotificationCenter.defaultCenter.postNotificationName("notificationEvent2")
    }
    
}

func createSample() {
    let classA:ClassA = ClassA()
    let classB:ClassB = ClassB()
    _ = MainClass()
    
    classA.removeObserver()
    classB.removeObserver()
}

createSample()
