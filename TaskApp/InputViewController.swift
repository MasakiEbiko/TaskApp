//
//  InputViewController.swift
//  TaskApp
//
//  Created by mba2408.spacegray kyoei.engine on 2024/10/15.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textCatogory: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    var task: Task!
    
    let realm = try!Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        textField.text = task.title
        textView.text = task.contents
        textCatogory.text = task.category
        datePicker.date = task.date
        // Do any additional setup after loading the view.
    }
    
    // writes data to realm when go back tasklist
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.textField.text!
            self.task.contents = self.textView.text
            print("cat="+self.textCatogory.text!)
            self.task.category = self.textCatogory.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        self.setNotification(task)
        super.viewWillDisappear(animated)
    }

    // setNotification
    func setNotification(_ task:Task){
        let content = UNMutableNotificationContent()
        // set Notification Title
        if task.title == "" {
            content.title = "(No Title)"
        } else {
            content.title = task.title
        }
        // set Notification Body
        if task.title == "" {
            content.body = "(No Contents)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        // set trigger
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // set notification request from identifier,contents,trigger
        let request = UNNotificationRequest(identifier: task.id.stringValue, content: content, trigger: trigger)
        // regist local notification
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in print(error ?? "local notification OK.")}
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
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
