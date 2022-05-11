//
//  ViewController.swift
//  BluetoothLE
//  iOS 10
//
//  Created by Juan Cruz Guidi on 16/10/16.
//  Copyright © 2016 Juan Cruz Guidi. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    var manager : CBCentralManager!
    var myBluetoothPeripheral : CBPeripheral!
    var myCharacteristic : CBCharacteristic!
    
    var isMyPeripheralConected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var msg = ""
        
        switch central.state {
            
        case .poweredOff:
            msg = "Bluetooth is Off"
        case .poweredOn:
            msg = "Bluetooth is On"
            manager.scanForPeripherals(withServices: nil, options: nil)
        case .unsupported:
            msg = "Not Supported"
        default:
            msg = "😔"
            
        }
        
        print("STATE: " + msg)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Name: \(peripheral.name)") //print the names of all peripherals connected.
        
        //you are going to use the name here down here ⇩
        
      //  if peripheral.name == "VTM 20F" { //if is it my peripheral, then connect
        if peripheral.name == "A&D_UA-651BLE_86FB2F"{
            self.myBluetoothPeripheral = peripheral     //save peripheral
            self.myBluetoothPeripheral.delegate = self
            
            manager.stopScan()                          //stop scanning for peripherals
            manager.connect(myBluetoothPeripheral, options: nil) //connect to my peripheral
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isMyPeripheralConected = true //when connected change to true
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isMyPeripheralConected = false //and to falso when disconnected
        self.manager.cancelPeripheralConnection(self.myBluetoothPeripheral)
        self.manager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let servicePeripheral = peripheral.services as [CBService]? { //get the services of the perifereal
            
            for service in servicePeripheral {
                
                //Then look for the characteristics of the services
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]? {
            
            for characteristic in characterArray {
                
                if(characteristic.uuid.uuidString == "2A35") { //properties: read, write
                    //if you have another BLE module, you should print or look for the characteristic you need.
                    myCharacteristic = characteristic //saved it to send data in another function.
                    peripheral.readValue(for: characteristic) //to read the value of the characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.uuid.uuidString == "2A35") {
            
            let readValue = characteristic.value
            print("length is :\(readValue?.count)")
            let arrayBytes = readValue?.bytes
            print("BP BYTES ARE :\(arrayBytes)")
//            if readValue?.count == 10{
//                let arrayBytes = readValue?.bytes
//                if let sp02 = arrayBytes?[5], let byte3 = arrayBytes?[3], let byte4 = arrayBytes?[4]{
//                    let pr = (8 * Int(byte3)) + Int(byte4)
//                    print("sp02 is :\(sp02) and pr is :\(pr)")
//                }
//            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}
