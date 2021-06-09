//
//  ViewController.swift
//  Threading Demo
//
//  Created by unthinkable-mac-0025 on 18/05/21.
//

import UIKit

var accountBalance = 5000
let lock = NSLock()

protocol Banking {
    func withDrawAmount(amount: Int) throws;
}

class ViewController: UIViewController {
    
    var apiArray :[TimeInterval] = [
        1, 3, 5, 7, 2, 7
    ]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

        dispatchSemaphore()
        
    }
    
    //MARK: - Dependecies management using operationQueue Demo
    func dependencyWithOperationQueue()  {
        
        //mocking the dependency managment using serial Queue
        let serialQueue = DispatchQueue.init(label: "serailQueue")
        //order here defines the priority of operation
        serialQueue.async {
            syncOfflineEmployeeRecords()
        }
        serialQueue.async {
            syncOfflineDepartmentRecords()
        }
        
        //mocking the dependency managment using Operation Queue
        let employeeSyncOperation = BlockOperation()
        employeeSyncOperation.addExecutionBlock {
            syncOfflineEmployeeRecords()
        }
        let departmentSyncOperation = BlockOperation()
        departmentSyncOperation.addExecutionBlock {
            syncOfflineDepartmentRecords()
        }
        
        //adding dependencies of employeeSync to departmentSync
        departmentSyncOperation.addDependency(employeeSyncOperation)
        
        let operationQueue = OperationQueue()
        operationQueue.addOperation(employeeSyncOperation)
        operationQueue.addOperation(departmentSyncOperation)
        
        
        //functions mocking api call to sync data to server
        func syncOfflineEmployeeRecords(){
            print("Syncing offline records for employee started")
            Thread.sleep(forTimeInterval: 2)
            print("Syncing completed for employee")
        }
        func syncOfflineDepartmentRecords(){
            print("Syncing offline records for department started")
            Thread.sleep(forTimeInterval: 2)
            print("Syncing completed for department")
        }
    }
    
    //MARK: - Operation Queue Demo
    func operationQueueDemo()  {
        let blockOperation1 = BlockOperation()
        //blockOperation1.qualityOfService = .utility   //better to define qos in OpeartionQueue
        
        blockOperation1.addExecutionBlock {
            print("Hello")
        }
        blockOperation1.addExecutionBlock {
            print("My Name is")
        }
        blockOperation1.addExecutionBlock {
            print("Dhanajit")
        }
        
        //blockOperation1.start()     //individual control of blockOperation
        
        let blockOperation2 = BlockOperation()
        blockOperation2.addExecutionBlock{
            print("Another block operation")
        }
        
        //creating the QperationQueue
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        //operationQueue.addOperation(blockOperation1)
        //operationQueue.addOperation(blockOperation2)
        //or
        operationQueue.addOperations([blockOperation1, blockOperation2], waitUntilFinished: false)
    }
    
    //MARK: - Dispatch Group Demo
    func dispatchGroupDemo(){
        let group = DispatchGroup()
        
        for number in apiArray{
            group.enter()
            print("Calling the Api \(number)")
            //calling the api
            DispatchQueue.global().asyncAfter(deadline: .now() + number, execute: {
                group.leave()
                let time = Date()
                print("leaving the group for \(number) at \(time)")
            })
        }//:for loop
        
        group.notify(queue: .main, execute: {
            print("Done with all Apis")
            self.view.backgroundColor = .blue
        })
        
    }
    
    
    //MARK: - DispatchWorkItem Demo
    func dispatchWotkItem()  {
        //dispatch work item
        var dispatchWorkItem : DispatchWorkItem?
        dispatchWorkItem = DispatchWorkItem {
            for i in 1...10{
                guard let workItem = dispatchWorkItem, !workItem.isCancelled else{
                    print("WorkItem is cancelled")
                    break
                }
                print("Executing the WorkItem \(i)")
                sleep(1)
            }
        }
        dispatchWorkItem?.notify(queue: .main){
            print("Done executing WorkItem")
        }
        //dispatchWorkItem.perform()
        //or
        let queue = DispatchQueue.global(qos: .utility)
        queue.async(execute: dispatchWorkItem!)
        queue.asyncAfter(deadline: .now() + .seconds(3)){   //cancelling the task after some time
            dispatchWorkItem!.cancel()
        }
    }
    
    //MARK: - delayedExecution for a time interval Demo
    func delayedExecution() {
        let queue = DispatchQueue(label: "com.gcd.simpleQueue")
        let delayedInteraval = DispatchTimeInterval.seconds(5) //.seconds(Int), .milliseconds(Int), .microseconds(Int), .nanoseconds(Int) , to specify time delay
        print(Date())
        // Execute after the delay of 5 seconds
        queue.asyncAfter(deadline: .now() + delayedInteraval) {
            print(Date())
        }
    }
    
    //MARK: - main queue Demo
    func mainQueue() {
      
      let mainQueue = DispatchQueue.main
        
        // Task1
        mainQueue.async {
            for i in 0 ..< 5 {
             print("🐢 @ \(i+1) Km. \(Thread.current) ")        //by some thread say 3
            }
          }
        // Task2
        mainQueue.async {
           for i in 0 ..< 5 {
            print("🐇 @ \(i+1) Km. \(Thread.current)")          //by some thread say 7
           }
          }
      

        mainQueue.async {
       for i in 0 ..< 5 {
        print("\(i) \(Thread.current) ")
       }
      }
    
    }
    
    //MARK: - global queue Demo
    func globalQueue() {
      
      let globalQueue = DispatchQueue.global()
        
        // Task1
          globalQueue.async {
            for i in 0 ..< 5 {
             print("🐢 @ \(i+1) Km. \(Thread.current) ")        //by some thread say 3
            }
          }
        // Task2
         globalQueue.async {
           for i in 0 ..< 5 {
            print("🐇 @ \(i+1) Km. \(Thread.current)")          //by same thread say 3
           }
          }
      

      globalQueue.async {                                   //by same thread say 3
       for i in 0 ..< 5 {
        print("\(i) \(Thread.current) ")
       }
      }
    
    }
    
    //MARK: - Concurrent Async Demo
    //multiple thread will be created
    func concurrentExecution() {
    let queue = DispatchQueue(label: "com.gcd.simpleQueue", qos: .userInitiated, attributes: .concurrent)
      
      print("Start Race:")
    // Task1
      queue.async {
        for i in 0 ..< 5 {
         print("🐢 @ \(i+1) Km. \(Thread.current) ")        //by some thread say 3
        }
      }
    // Task2
     queue.async {
       for i in 0 ..< 5 {
        print("🐇 @ \(i+1) Km. \(Thread.current)")          //by some thread say 7
       }
      }
    }
    
    //MARK: - Serail Async Demo
    //one thread will be created by serial
    func serialExecution() {
        let queue = DispatchQueue(label: "com.gcd.simpleQueue")     //dy deafult its serial
      print("Start Race:")
    // Task1
      queue.async {
       for i in 0 ..< 5 {
        print("🐢 @ \(i+1) Km. \(Thread.current)")      //by some thread say 4
       }
      }
    // Task2
     queue.async {
       for i in 0 ..< 5 {
        print("🐇 @ \(i+1) Km. \(Thread.current)")      //will be executed by the same thread say 4
       }
     }
    }
    
    //MARK: - Serial Sync Demo
    //in Async mode
    func executeAsync() {
        let queue = DispatchQueue(label: "com.gcd.simpleQueue")
    print("Start Race:")
    // Run on queue in async mode
      queue.async {
        for i in 0 ..< 5 {
            print("🐢 @ \(i+1) Km. by \(Thread.current)")       //by some other thread
        }
      }
    // Run on UI thread
      for i in 0 ..< 5 {
        print("🐇 @ \(i+1) Km. \(Thread.current)")              //by main thread
      }
    }
    
    //MARK: - Concurrent Async Demo
    //in sync mode
    func executeSync() {
        let queue = DispatchQueue(label: "com.gcd.simpleQueue", attributes: .concurrent)
    print("Start Race:")
    // Run on queue in sync mode
      queue.sync {
        for i in 0 ..< 5 {
            print("🐢 @ \(i+1) Km. by \(Thread.current)")
        }
      }
    // Run on UI thread
      for i in 0 ..< 5 {
        print("🐇 @ \(i+1) Km. \(Thread.current)")
      }
    }
    
    
    //MARK: - Race Condition Demo
    func raceConditionDemo() {
        let queue = DispatchQueue(label: "WithdrawalQueue", attributes: .concurrent)
        
        queue.async {
            let netBankingInterface = FromBank(withDrawMethod: "Netbanking")
            netBankingInterface.doTransaction(amount: 3000)
        }
        queue.async {
            let bankAtm = FromBank(withDrawMethod: "Bank Atm")
            bankAtm.doTransaction(amount: 4000)
        }
    }
    //to test race condition in threads
    struct FromBank{
        let withDrawMethod : String
        
        func doTransaction(amount : Int){
            
            lock.lock()
            //cheking for sufficient balance in the bank account
            if accountBalance > amount{
                print("\(self.withDrawMethod)Balance is sufficient , proceeding with transaction")
                
                //thread sleep
                Thread.sleep(forTimeInterval: Double.random(in: 0...4))
                
                //deduct the amount balance
                accountBalance -= amount
                print("\(self.withDrawMethod) Done \(amount) has been withdrawn")
                print("\(self.withDrawMethod) Current Balance is \(accountBalance)")
            }else{
                print("\(self.withDrawMethod) Can't Withdraw Money, Insufficent Balance")
            }
            lock.unlock()
            
        }//: doTransaction()
    }//: Bank Struct
    
    
    //MARK: - Parameter Dependencies Demo
    func parameterDependencies() {
        let syncResource = SyncResource()
        syncResource.syncDataResources()
    }
    
    struct SyncResource
    {
        func syncDataResources()
        {

            let group = DispatchGroup()

            // employee block operation
            let employeeBlockOperation = BlockOperation()
            employeeBlockOperation.addExecutionBlock {

                let employeeDataResource = EmployeeDataResource()
                employeeDataResource.getEmployee { (employeeData) in
                    employeeData?.forEach({ (employee) in
                        debugPrint(employee.name)
                    })
                }
            }

            // project block operation
            let projectBlockOperation = BlockOperation()
            projectBlockOperation.addExecutionBlock {
                group.enter()
                let projectResource = ProjectDataResource()
                projectResource.getProject { (projectData) in
                    projectData?.forEach({ (project) in
                        debugPrint(project.name)
                    })
                    group.leave()
                }

                group.wait()
            }

            // adding dependency
            employeeBlockOperation.addDependency(projectBlockOperation)

            // creating the operation queue
            let operationQueue = OperationQueue()
            operationQueue.addOperation(employeeBlockOperation)
            operationQueue.addOperation(projectBlockOperation)
        }
    }

    struct HttpUtility
    {
        static let shared = HttpUtility()
        private init(){}
        func getData<T:Decodable>(request: URLRequest, response: T.Type, handler:@escaping(_ result: T?)-> Void)
        {
            URLSession.shared.dataTask(with: request) { (data, httpUrlResponse, error) in
                if(error == nil && data != nil && data?.count != 0) {
                    do {
                       let decoder = JSONDecoder()
                        // for date formatting
                        decoder.dateDecodingStrategy = .iso8601
                        let result = try decoder.decode(response, from: data!)
                        handler(result)
                    } catch  {
                        debugPrint(error.localizedDescription)
                    }

                }}.resume()
        }
    }
    
    struct EmployeeResponse: Decodable {
        let errorMessage: String?
        let data: [EmployeeData]?
    }
    struct EmployeeData: Decodable {
        let name, email, id,joining: String
    }
    
    struct EmployeeDataResource
    {
        func getEmployee(handler:@escaping(_ result: [EmployeeData]?)-> Void)
        {
            print("inside the get employee function")

            //creating the request with URL
            var urlRequest = URLRequest(url: URL(string: "https://api-dev-scus-demo.azurewebsites.net/api/Employee/GetEmployee?Department=mobile&UserId=15")!)
            urlRequest.httpMethod = "get"
            print("going to call the http utility for employee request")

            HttpUtility.shared.getData(request: urlRequest, response: EmployeeResponse.self) { (result) in
                if(result != nil) {
                    debugPrint("got the emloyee response from api")
                    handler(result?.data)
                }
            }
        }
    }
    
    struct Project: Decodable {
        let id: Int
        let name, description: String
        let isActive: Bool
        let startDate: Date
        let endDate: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case name,description
            case isActive, startDate, endDate
        }
    }
    
    struct ProjectDataResource
    {
        func getProject(handler:@escaping(_ result: [Project]?)-> Void)
        {
            debugPrint("inside the get project function")

            var urlRequest = URLRequest(url: URL(string: "https://api-dev-scus-demo.azurewebsites.net/api/Project/GetProjects")!)
            urlRequest.httpMethod = "get"

            debugPrint("going to call the http utility for Project request")

            HttpUtility.shared.getData(request: urlRequest, response: [Project].self) { (result) in
                if(result != nil) {
                    debugPrint("got the project response from api")
                    handler(result)
                }
            }
        }
    }//: Parameter Dependencies Demo
    
    
    //MARK: - Dispatch Semaphore Demo
    func dispatchSemaphore()  {
        let queue1 = DispatchQueue(label: "semaphoreDemo", qos: .utility, attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1)
        
        queue1.async {
            // Money withdrawal from ATM
            do {
                semaphore.wait()
                let atm = Atm()
                try atm.withDrawAmount(amount: 4000) // withdraw 10K
                atm.printMessage()
                semaphore.signal()

            } catch WithdrawalError.inSufficientAccountBalance {
                semaphore.signal()
                debugPrint("ATM withdrawal failure: The account balance is less than the amount you want to withdraw, transaction cancelled")
            }
            catch {
                semaphore.signal()
                debugPrint("Error")
            }
        }

        queue1.async {
            // Money withdrawal from Bank
            do {
                semaphore.wait()
                let bank = Bank()
                try bank.withDrawAmount(amount: 3000) // withdraw 25K
                bank.printMessage()
                semaphore.signal()

            } catch WithdrawalError.inSufficientAccountBalance  {
                semaphore.signal()
                debugPrint("Bank withdrawal failure: The account balance is less than the amount you want to withdraw, transaction cancelled")
            }
            catch{
                semaphore.signal()
                debugPrint("Error")
            }
        }
    }
    
    enum WithdrawalError : Error {
        case inSufficientAccountBalance
    }

    struct Atm : Banking {

        func withDrawAmount(amount: Int) throws {
            debugPrint("inside atm")

            guard accountBalance > amount else { throw WithdrawalError.inSufficientAccountBalance }

            // Intentional pause : ATM doing some calculation before it can dispense money
            Thread.sleep(forTimeInterval: Double.random(in: 1...3))
            accountBalance -= amount
        }

        func printMessage() {
            debugPrint("ATM withdrawal successful, new account balance = \(accountBalance)")
        }
    }

    struct Bank : Banking {

        func withDrawAmount(amount: Int) throws {
            debugPrint("inside bank")

            guard accountBalance > amount else { throw WithdrawalError.inSufficientAccountBalance }

            // Intentional pause : Bank person counting the money before handing it over
            Thread.sleep(forTimeInterval: Double.random(in: 1...3))
            accountBalance -= amount
        }

        func printMessage() {
            debugPrint("Bank withdrawal successful, new account balance = \(accountBalance)")
        }
    }

    

   


    
    
    

    
    
    
}//:ViewController



