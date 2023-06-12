//
//  DatabaseService.swift
//  SwiftDataDemo
//
//  Created by Sai Balaji on 12/06/23.
//

import Foundation
import SwiftData

class DatabaseService{
    static var shared = DatabaseService()
    var container: ModelContainer?
    var context: ModelContext?
    
    init(){
        do{
             container = try ModelContainer(for: [TodoModel.self])
            if let container{
                context = ModelContext(container)
            }
             
        }
        catch{
            print(error)
        }
    }
    
    func saveTask(taskName: String?){
        guard let taskName else{return }
        if let context{
            let taskToBeSaved = TodoModel(id: UUID().uuidString, taskname: taskName, time: Date().timeIntervalSince1970)
            context.insert(object: taskToBeSaved)
        }
    }
    
    func fetchTasks(onCompletion:@escaping([TodoModel]?,Error?)->(Void)){
        let descriptor = FetchDescriptor<TodoModel>(sortBy: [SortDescriptor<TodoModel>(\.time)])
        if let context{
            do{
                let data = try context.fetch(descriptor)
                onCompletion(data,nil)
            }
            catch{
                onCompletion(nil,error)
            }
        }
    }
    
    func updateTask(task: TodoModel,newTaskName: String){
        let taskToBeUpdated = task
        if let context{
            taskToBeUpdated.taskname = newTaskName
            do{
                try context.save()
            }
            catch{
                print(error)
            }
        }
      
    }
    
    func deleteTask(task: TodoModel){
        let taskToBeDeleted = task
        if let context{
            context.delete(taskToBeDeleted)
        }
    }
    
}
