//
//  Task.swift
//  TaskApp
//
//  Created by mba2408.spacegray kyoei.engine on 2024/10/17.
//

import RealmSwift

class Task: Object{
    //PK
    @Persisted(primaryKey: true) var id: ObjectId
    
    //title
    @Persisted var title = ""
    
    //category
    @Persisted var category = ""
    
    //contents
    @Persisted var contents = ""

    //date
    @Persisted var date = Date()
    
}
