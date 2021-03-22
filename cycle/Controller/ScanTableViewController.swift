//
//  ScanTableViewController.swift
//  BLEDemo
//
//  Created by Rick Smith on 13/07/2016.
//  Copyright © 2016 Rick Smith. All rights reserved.
import UIKit
import CoreBluetooth
class ScanTableViewController: UIViewController,BluetoothDelegate{
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:ViewController? = nil
    var delegate : ScanTableViewDelegate?
    var blueToothTag:Int = 0
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    override func viewDidLoad(){
        super.viewDidLoad()
        searchIndicator.startAnimating()
    }
    override func viewDidAppear(_ animated: Bool) {
        scanBLEDevices()
    }
    // MARK: BLE Scanning
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        manager?.scanForPeripherals(withServices: nil, options: nil)
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.stopScanForBLEDevices()
        }
    }
    func stopScanForBLEDevices() {
        if searchIndicator != nil{
           searchIndicator.stopAnimating()
           searchIndicator.removeFromSuperview()
        }
        manager?.stopScan()
    }
    @IBAction func closeAction(_ sender: Any) {
        self.stopScanForBLEDevices()
        delegate?.closePopup()
       self.dismiss(animated: true, completion: nil)
    }
}
extension ScanTableViewController: CBCentralManagerDelegate,UITableViewDataSource,UITableViewDelegate{
    // MARK: - CBCentralManagerDelegate Methods
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            print("peripheral"+"\(peripheral.identifier.uuidString)"+"\(peripheral.name!)")
            if !peripherals.contains(peripheral) && peripheral.name!.containsIgnoringCase(find:"M2Me"){
                peripherals.append(peripheral)
            }
        }
        self.tableView.reloadData()
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//pass reference to connected peripheral to parent view
         parentView?.leftPeripheral = peripheral
       
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    // MARK: - Table view data sourc
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath) as! ScenTableViewCell
        let peripheral = peripherals[indexPath.row]
        cell.bleName!.text = peripheral.name
        cell.bleId!.text = Util.getBleName(name: peripheral.identifier.uuidString)
        if  parentView!.leftPeripheral == peripheral{
            cell.connectImageView!.image = UIImage(named:"module_conn_btn")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectPeripheral =  peripherals[indexPath.row]
       
        if parentView?.leftPeripheral == nil{
            parentView!.leftPeripheral = selectPeripheral
            manager?.delegate = parentView
            UserDefaults.standard.set(selectPeripheral.identifier.uuidString, forKey:"BleUUID")
            UserDefaults.standard.synchronize()
            stopScanForBLEDevices()
            
        }else{
            Util.Toast.show(message: Util.localString(st: "already_module"), controller: self)
        }
       // BluetoothManager.getInstance().delegate = parentView
    
       
//      let peripheral = peripherals[indexPath.row]
//      if blueToothTag == 0 {
//           if parentView?.leftPeripheral == nil{
//                if parentView?.rightPeripheral == peripheral { Util.Toast.show(message: Util.localString(st: "already_module"), controller: self)}
//                else{
//                    parentView?.leftPeripheral = peripheral
//                    manager?.delegate = parentView
//                    UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "leftBleUUID")
//                    UserDefaults.standard.synchronize()
//                }
//            }
//            else{
//                    Util.Toast.show(message: Util.localString(st: "already_module"), controller: self)
//            }
//        }
//        else if blueToothTag == 1{
//            if  parentView?.rightPeripheral == nil{
//                if parentView?.leftPeripheral == peripheral { Util.Toast.show(message: Util.localString(st: "already_module"), controller: self)}
//                else{
//                    parentView?.rightPeripheral = peripheral
//                    manager?.delegate = parentView
//                    UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "rightBleUUID")
//                    UserDefaults.standard.synchronize()
//                }
//            }
//            else {
//                    Util.Toast.show(message: Util.localString(st: "already_module"), controller: self) 
//            }
//        }
       self.tableView.reloadData()
    }
}
extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
class ScenTableViewCell : UITableViewCell{
    @IBOutlet weak var connectImageView: UIImageView?
    @IBOutlet weak var bleName: UILabel?
    @IBOutlet weak var bleId: UILabel!
}
