//
//  SecureMgr.swift
//  SecureStuff
//
//  Created by Bear Q Cahill

import Foundation

class SecureMgr {

    static func deleteKeychain(query:[String:Any]) -> Bool {
        let result = SecItemDelete(query as CFDictionary)
        return result == errSecSuccess
    }
    
    static func deleteLogin(username: String) -> Bool {
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: username]
        return deleteKeychain(query: query)
    }
    
    static func updateKeychain(query: [String:Any],
                               attrs: [String:Any]) -> Bool {
        let result = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
        return result == errSecSuccess
    }
    
    static func updatePassword(username: String, password: String) -> Bool {
        let pwData = password.data(using: .utf8)!
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: username]
        let attrs : [String:Any] = [kSecValueData as String: pwData]
        return updateKeychain(query: query, attrs: attrs)
    }
    
    static func findInKeychain(query : [String:Any]) -> String? {
        var item: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        guard result == errSecSuccess else { return nil }
        
        let msg = SecCopyErrorMessageString(result, nil)
        print (msg)
        
        if let pwData = item as? Data {
            let password = String(data: pwData, encoding: .utf8)
            return password
        }
        
        guard let theItem = item as? [String:Any],
            let pwData = theItem[kSecValueData as String] as? Data,
            let password = String(data: pwData, encoding: .utf8),
            let account = theItem[kSecAttrAccount as String] as? String
            else { return nil }
        return password
    }
    
    static func retrievePassword(username: String) -> String? {
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: username,
//                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true
        ]
        return findInKeychain(query: query)
    }

    static func addToKeychain(query : [String:Any]) -> Bool {
        let result = SecItemAdd(query as CFDictionary, nil)
        let msg = SecCopyErrorMessageString(result, nil)
        print (msg)
        return result == errSecSuccess
    }
    
    static func storeServerLogin(username : String, password : String,
                                 server: String, userType: String) -> Bool {
        // Store in Keychain
        let pwData = password.data(using: .utf8)!
        let query : [String:Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrLabel as String: userType,
                                    kSecAttrServer as String: server,
                                    kSecAttrAccount as String: username,
                                    kSecValueData as String: pwData
        ]
        return addToKeychain(query: query)
    }

    static func storeLogin(username : String, password : String) -> Bool {
        // Store in Keychain
        let pwData = password.data(using: .utf8)!
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: username,
                                    kSecValueData as String: pwData
        ]
        return addToKeychain(query: query)
    }
    
    static func storeItem(uuid:String, text:String) -> Bool {
        let tData = text.data(using: .utf8)!
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: uuid,
                                    kSecValueData as String: tData,
                                    kSecAttrLabel as String: "note"
        ]
        return addToKeychain(query: query)
    }
    
    static func fetchItems() -> [Note]? {
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: "note",
                                    kSecReturnData as String: true,
                                    kSecReturnAttributes as String: true,
                                    kSecMatchLimit as String : kSecMatchLimitAll]
        
        var item:CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        guard result == errSecSuccess else { return nil }
        
        guard let theItems = item as? [Dictionary<String,Any>] else { return nil }
        
        let items = theItems.compactMap { (dict) -> Note? in
            guard let data = dict[kSecValueData as String] as? Data,
                let text = String(data: data, encoding: .utf8) else { return nil }
            return Note(text: text, uuid: dict[kSecAttrAccount as String] as! String)
        }
        
        return items
    }
    
    static func updateNote(text:String, uuid:String) -> Bool {
        let tData = text.data(using: .utf8)!
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: uuid,
                                    kSecAttrLabel as String: "note"]
        let attrs : [String:Any] = [kSecValueData as String: tData]
        return updateKeychain(query: query, attrs: attrs)
    }
    
    static func removeItem(uuid:String) -> Bool {
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: uuid,
                                    kSecAttrLabel as String: "note"]
        return deleteKeychain(query: query)
    }
}
