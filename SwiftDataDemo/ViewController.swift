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
        
        configureUI()
        self.fetchData()
        
        
    }

    func configureUI(){
        title = "Swift Data Demo"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItem))
    }


    func fetchData(){
        DatabaseService.shared.fetchTasks { data , error  in
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


    @objc func addItem(){
        let avc = UIAlertController(title: "Info", message: "Add new item", preferredStyle: .alert)
        avc.addTextField()
        avc.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action  in
            if let taskName = avc.textFields?.first?.text{
                
                
                DatabaseService.shared.saveTask(taskName: taskName)
                self.fetchData()
            }
        }))
        self.present(avc, animated: true, completion: nil)
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
            
            
            DatabaseService.shared.deleteTask(task: self.tasks[indexpath.row])
            self.fetchData()
            
        }
        let update = UITableViewRowAction(style: .default, title: "Update") { _, indexpath  in
            let avc = UIAlertController(title: "Info", message: "Add new item", preferredStyle: .alert)
            avc.addTextField()
            avc.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action  in
                if let textfield = avc.textFields?.first?.text{
                    
                    DatabaseService.shared.updateTask(task: self.tasks[indexpath.row], newTaskName: textfield)
                    self.fetchData()
                }
            }))
            self.present(avc, animated: true, completion: nil)
        }
        update.backgroundColor = UIColor.green
        return [delete,update]
    }

    }

