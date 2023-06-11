//
//  TodoModel.swift
//  SwiftDataDemo
//
//  Created by Sai Balaji on 11/06/23.
//

import Foundation
import SwiftData

@Model
class TodoModel{
    @Attribute(.unique) var id: String
    var taskname: String
    var time: Double
    
    init(id: String, taskname: String,time: Double) {
        self.id = id
        self.taskname = taskname
        self.time = time
    }
    
}
