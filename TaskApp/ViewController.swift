//
//  ViewController.swift
//  TaskApp
//
//  Created by mba2408.spacegray kyoei.engine on 2024/10/15.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    //Realm Instance
    let realm = try!Realm()
    //get DataList, Sort by Date, ascending
    var taskArray = try!Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.filtering(searchBar.text, searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        self.filtering(searchText, searchBar)
    }
    
    func filtering(_ text:String!, _ searchBar:UISearchBar){
        if text?.count == 0 { // 検索されている文字列がない時
            configureTableView()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            //taskArrayにフィルタリングした結果を格納する
            let tasks = realm.objects(Task.self)
            self.taskArray = tasks.where{ $0.category.contains(text!) }
        }
        tableView.reloadData()
    }

    func configureTableView() {
        self.taskArray = realm.objects(Task.self)
        self.tableView.reloadData()
    }
    
    //データの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    //各セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //set values at cell
        let task = taskArray[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title + "[" + task.category + "]"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        content.secondaryText = dateString
        cell.contentConfiguration = content
        return cell
    }
    
    //各セルを選択した時に実行
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //get target task
            let task = self.taskArray[indexPath.row]
            // cancel local notification
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [task.id.stringValue])
            //remove row at realm
            try! realm.write{
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            // print logs pendingNotifications
            center.getPendingNotificationRequests{
                (requests:[UNNotificationRequest]) in
                for request in requests {
                    print("/--------------------------")
                    print(request)
                    print("--------------------------/")
                }
            }
        }
    }
    
    // will be called by segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            inputViewController.task = Task()
        }
    }
    
    // refresh tableview when go back from task-entry
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

