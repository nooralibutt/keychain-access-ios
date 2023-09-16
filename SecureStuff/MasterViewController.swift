//
//  MasterViewController.swift
//  SecureStuff
//
//  Created by Bear Cahill

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var notes = [Note]()
    var userlogin : UserLogin?
    var selectedIndexPath : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                    
//        guard let ud = UserDefaults(suiteName: "group.com.somesite.Sharing") else { return }
//        ud.set("test", forKey: "Word")
//        print (ud.object(forKey: "Word"))
        
//        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.somesite.Sharing")
        
//        let result = SecureMgr.storeServerLogin(username: "test", password: "1234", server: "www.example.com", userType: "admin")
//        let result = SecureMgr.updatePassword(username: "bear", password: "asdf")
//        let password = SecureMgr.retrievePassword(username: "bear")
        
    //    let _ = SecureMgr.storeLogin(username: "test1", password: "9999")
//        let pw = SecureMgr.retrievePassword(username: "test1")
//        let r = SecureMgr.deleteLogin(username: "test1")
//        let pw2 = SecureMgr.retrievePassword(username: "test1")
        
        // login if necessary
        if (self.isUserLoggedIn() == false) {
            self.login(completion: { (uLogin) in
                self.userlogin = uLogin
                
                if (self.isUserLoggedIn()) {
                    // handle user logged in or not
                    self.loadItems()
                }
            })
        } else if let vc = detailViewController {
            if let note = vc.noteText, note.count > 0 {
                if let ip = selectedIndexPath {
                    let updateNote = Note(text: note, uuid: notes[ip.row].uuid)
                    notes[ip.row] = updateNote
                    let _ = SecureMgr.updateNote(text: note, uuid: updateNote.uuid)
                    self.tableView.reloadRows(at: [ip], with: .automatic)
                } else {
                    // new note
                    let newNote = Note(text: note, uuid: UUID().uuidString)
                    notes.append(newNote)
                    let _ = SecureMgr.storeItem(uuid: newNote.uuid, text: newNote.text)
                    selectedIndexPath = IndexPath(row: notes.count-1, section: 0)
                    self.tableView.insertRows(at: [selectedIndexPath!],
                                              with: .automatic)
                }
            }
        }
    }
    
    func loadItems() {
        if let fetchedNotes = SecureMgr.fetchItems() {
            self.notes = fetchedNotes
            self.tableView.reloadData()
        }
    }

    @objc
    func insertNewObject(_ sender: Any) {
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            // keep a pointer to the VC to get the note when coming back
            detailViewController = (segue.destination as! UINavigationController).topViewController as? DetailViewController
            guard let vc = detailViewController else { return }
            
            // set the note if they selected one
            if let indexPath = tableView.indexPathForSelectedRow {
                self.selectedIndexPath = indexPath
                let object = notes[indexPath.row]
                vc.noteText = object.text
            } else {
                selectedIndexPath = nil
            }
            
            vc.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            vc.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let object = notes[indexPath.row]
        cell.textLabel!.text = object.text
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let _ = SecureMgr.removeItem(uuid: notes[indexPath.row].uuid)
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

