//
//  WalletController.swift
//  Pangolin
//
//  Created by wsli on 2019/8/27.
//  Copyright © 2019年 com.nbs. All rights reserved.
//

import Cocoa

class WalletController: NSWindowController {
        
        @IBOutlet weak var MainAddressField: NSTextField!
        @IBOutlet weak var SubAddressField: NSTextField!
        @IBOutlet weak var EthBalanceField: NSTextField!
        @IBOutlet weak var TokenBalanceField: NSTextField!
        @IBOutlet weak var WaitingTip: NSProgressIndicator!
        @IBOutlet weak var DataBalanceField: NSTextField!
        @IBOutlet weak var DataUsedField: NSTextField!
        @IBOutlet weak var DataAvgPriceField: NSTextField!
        @IBOutlet weak var MinerDescField: NSScrollView!
        
        var queue = DispatchQueue(label: "smart contract queue")
        
        override func windowDidLoad() {
                super.windowDidLoad()
                updateWallet()
        }
        
        func updateWallet(){
                MainAddressField.stringValue = Wallet.sharedInstance.MainAddress
                SubAddressField.stringValue = Wallet.sharedInstance.SubAddress
                loadBalance()
        }
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        @IBAction func CreateWalletAction(_ sender: Any) {
                if !Wallet.sharedInstance.IsEmpty(){
                        let ok = dialogOKCancel(question: "Replace This Wallet?", text: "Current wallet will be replaced by new created one!")
                        if !ok{
                                return
                        }
                }
                
                let (pwd1, pwd2, ok) = show2PasswordDialog()
                if !ok{
                        return
                }
                
                if pwd1 != pwd2{
                        dialogOK(question: "Error", text: "The 2 Passwords are different")
                        return
                }
                
                let success = Wallet.sharedInstance.CreateNewWallet(passPhrase: pwd1)
                if success{
                        updateWallet()
                }
        }
        
        @IBAction func ImportWalletAction(_ sender: Any) {
                if !Wallet.sharedInstance.IsEmpty(){
                        let ok = dialogOKCancel(question: "Replace This Wallet?", text: "Current wallet will be replaced by imported one!")
                        if !ok{
                                return
                        }
                }
                
                let openPanel = NSOpenPanel()
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.canChooseFiles = true
                NSApp.activate(ignoringOtherApps: true)
                openPanel.allowedFileTypes=["text", "txt", "json"]
                openPanel.begin { (result) -> Void in
                        if result.rawValue != NSFileHandlingPanelOKButton {
                                return
                        }
                        
                        let password = showPasswordDialog()
                        if password == ""{
                                return
                        }
                        
                        do {
                                let jsonStr = try String.init(contentsOf: openPanel.url!)
                                try Wallet.sharedInstance.ImportWallet(json:jsonStr , password: password)
                                dialogOK(question: "Success", text: "Import wallet success!")
                                self.updateWallet()
                                
                        }catch{
                                dialogOK(question: "Warn", text:error.localizedDescription)
                                return
                        }
                }
        }
        
        @IBAction func ExportWalletAction(_ sender: Any) {
                
                if Wallet.sharedInstance.IsEmpty(){
                        dialogOK(question: "Tips", text: "No account to export")
                        return
                }
                let FS = NSSavePanel()
                FS.canCreateDirectories = true
                FS.allowedFileTypes = ["text", "txt", "json"]
                FS.canCreateDirectories = true
                FS.isExtensionHidden = false
                FS.nameFieldStringValue = Wallet.sharedInstance.KEY_FOR_WALLET_FILE
                NSApp.activate(ignoringOtherApps: true)
                FS.begin { result in
                        if result.rawValue != NSFileHandlingPanelOKButton {
                                return
                        }
                        do {
                                try Wallet.sharedInstance.ExportWallet(dst:FS.url)
                                dialogOK(question: "Success", text: "Export account success!")
                        }catch{
                                dialogOK(question: "Error", text: error.localizedDescription)
                                return
                        }
                }
        }
        
        @IBAction func SyncEthereumAction(_ sender: Any) {
                loadBalance()
        }
        
        @IBAction func ReloadMinerPoolActin(_ sender: Any) {
        }
        
        func loadBalance(){
                WaitingTip.isHidden = false
                queue.async {
                        Wallet.sharedInstance.syncBlockChainBalance()
                        DispatchQueue.main.async {
                                self.WaitingTip.isHidden = true
                                self.EthBalanceField.stringValue = Wallet.sharedInstance.EthBalance
                                self.TokenBalanceField.stringValue = Wallet.sharedInstance.TokenBalance
                        }
                }
        }
}

extension WalletController:NSTableViewDelegate{
        func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
                let mp = Wallet.sharedInstance.SMP[row]
                return mp.Name
        }
}

extension WalletController:NSTableViewDataSource{
        func numberOfRows(in tableView: NSTableView) -> Int {
                return Wallet.sharedInstance.SMP.count
        }
}

