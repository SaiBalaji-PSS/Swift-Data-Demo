//
//  ViewController.swift
//  SwiftDataDemo
//
//  Created by Sai Balaji on 11/06/23.
//

import UIKit
import SwiftData



class ViewController: UIViewController {

    @IBOutlet weak var taskTableView: UITableView!
    var container: ModelContainer?
    var context: ModelContext?
    
  
    var tasks = [TodoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UITableViewCell.self,forCellReuseIdentifier: "CELL")
        configureSwiftData()
        configureUI()
        self.fetchData { data , error  in
            if let error{
                print(error)
            }
            if let data{
                self.tasks = data
                DispatchQueue.main.async {
                    self.taskTableView.reloadData()
                }
            }
        }
        
      
    }
    
    func configureUI(){
        title = "Swift Data Demo"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
    }
    
    func configureSwiftData(){
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
    
    
    @objc func addItem(){
        let avc = UIAlertController(title: "Info", message: "Add new item", preferredStyle: .alert)
        avc.addTextField()
        avc.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action  in
            if let textfield = avc.textFields?.first{
                print(textfield.text ?? "")
                self.saveTask(task: textfield.text)
            }
        }))
        self.present(avc, animated: true, completion: nil)
    }


}



extension ViewController{
    func saveTask(task: String?){
 
        guard let task else{return }
        
        if let context{
            let taskToBeSaved = TodoModel(id:UUID().uuidString,taskname:"\(task)", time: Date().timeIntervalSince1970)
            context.insert(object: taskToBeSaved)
            self.fetchData { data , error  in
                if let error{
                    print(error)
                }
                if let data{
                    self.tasks = data
                    print(self.tasks.last?.taskname)
                    DispatchQueue.main.async {
                        self.taskTableView.reloadData()
                    }
                }
            }
            

        }
        
        
        
    }
    
    func deleteData(index: IndexPath){
        let taskToBeDeleted = self.tasks[index.row]
       
            if let context{
                context.delete(taskToBeDeleted)
                self.tasks.remove(at: index.row)
                self.taskTableView.reloadData()
            }
        
      
    }
    
    func fetchData(onCompletion:@escaping([TodoModel]?,Error?)->(Void)){
       
        
        let descriptor = FetchDescriptor<TodoModel>(sortBy: [SortDescriptor<TodoModel>(\.time)])
        do{
            if let context{
                let data = try context.fetch(descriptor)
             
                onCompletion(data,nil)
            }
        }
        catch{
            print(error)
            onCompletion(nil,error)
        }
    }
    
    func update(index: IndexPath,taskname: String){
        var taskToBeUpdated = self.tasks[index.row]
        if let context{
            taskToBeUpdated.taskname = taskname
            
            do{
                try context.save()
                self.fetchData { data , error  in
                    if let error{
                        print(error)
                    }
                    if let data{
                        self.tasks = data
                        DispatchQueue.main.async {
                            self.taskTableView.reloadData()
                        }
                    }
                }
            }
            catch{
                print(error)
            }
        }
    }
    

    
   
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = "\(self.tasks[indexPath.row].taskname)"
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { _, indexpath  in
            self.deleteData(index: indexPath)
        }
        let update = UITableViewRowAction(style: .default, title: "Update") { _, indexpath  in
            let avc = UIAlertController(title: "Info", message: "Add new item", preferredStyle: .alert)
            avc.addTextField()
            avc.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action  in
                if let textfield = avc.textFields?.first?.text{
                   
                    self.update(index: indexPath, taskname: textfield)
                }
            }))
            self.present(avc, animated: true, completion: nil)
        }
        update.backgroundColor = UIColor.green
        return [delete,update]
    }
    
}

