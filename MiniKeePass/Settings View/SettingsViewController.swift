/*
 * Copyright 2016 Jason Rush and John Flanagan. All rights reserved.
 * Mdified by Frank Hausmann 2020-2021
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit
import AudioToolbox
import LocalAuthentication

class SettingsViewController: UITableViewController {
    @IBOutlet weak var pinEnabledSwitch: UISwitch!
    
    @IBOutlet weak var enableAutofillExtension: UISwitch!
    
    @IBOutlet weak var darkModeEnabledCell: UITableViewCell!
    @IBOutlet weak var darkModeEnabledSwitch: UISwitch!
    
    @IBOutlet weak var touchIdEnabledCell: UITableViewCell!
    @IBOutlet weak var touchIdEnabledSwitch: UISwitch!
    
    @IBOutlet weak var deleteAllDataEnabledCell: UITableViewCell!
    @IBOutlet weak var deleteAllDataEnabledSwitch: UISwitch!
    @IBOutlet weak var deleteAllDataAttemptsCell: UITableViewCell!
    
    @IBOutlet weak var closeDatabaseEnabledSwitch: UISwitch!
    @IBOutlet weak var closeDatabaseTimeoutCell: UITableViewCell!
    
    @IBOutlet weak var rememberDatabasePasswordsEnabledSwitch: UISwitch!
    
    @IBOutlet weak var hidePasswordsEnabledSwitch: UISwitch!

    @IBOutlet weak var sortingEnabledSwitch: UISwitch!

    @IBOutlet weak var searchTitleOnlySwitch: UISwitch!
    
    @IBOutlet weak var passwordEncodingCell: UITableViewCell!
    
    @IBOutlet weak var clearClipboardEnabledSwitch: UISwitch!
    @IBOutlet weak var clearClipboardTimeoutCell: UITableViewCell!
    
    @IBOutlet weak var accountDetailCell: UITableViewCell!
    @IBOutlet weak var excludeFromBackupsEnabledSwitch: UISwitch!
    
    @IBOutlet weak var integratedWebBrowserEnabledSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var autoFillMethod: UISegmentedControl!
    
    
    @IBOutlet weak var analyseData: UISwitch!
    
    fileprivate let deleteAllDataAttempts = ["3", "5", "10", "15"]
    
    fileprivate let closeDatabaseTimeouts = [NSLocalizedString("Immediately", comment: ""),
                                         NSLocalizedString("30 Seconds", comment: ""),
                                         NSLocalizedString("1 Minute", comment: ""),
                                         NSLocalizedString("2 Minutes", comment: ""),
                                         NSLocalizedString("5 Minutes", comment: "")]
    
    fileprivate let passwordEncodings = [NSLocalizedString("UTF-8", comment: ""),
                                     NSLocalizedString("UTF-16 Big Endian", comment: ""),
                                     NSLocalizedString("UTF-16 Little Endian", comment: ""),
                                     NSLocalizedString("Latin 1 (ISO/IEC 8859-1)", comment: ""),
                                     NSLocalizedString("Latin 2 (ISO/IEC 8859-2)", comment: ""),
                                     NSLocalizedString("7-Bit ASCII", comment: ""),
                                     NSLocalizedString("Japanese EUC", comment: ""),
                                     NSLocalizedString("ISO-2022-JP", comment: "")]

    fileprivate let clearClipboardTimeouts = [NSLocalizedString("30 Seconds", comment: ""),
                                          NSLocalizedString("1 Minute", comment: ""),
                                          NSLocalizedString("2 Minutes", comment: ""),
                                          NSLocalizedString("3 Minutes", comment: "")]
    
    fileprivate var appSettings = AppSettings.sharedInstance()
    fileprivate var touchIdSupported = false
    fileprivate var tempPin: String? = nil
    
    override func viewDidLoad() { 
        super.viewDidLoad()
        
        // Get the version number
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        // Check if TouchID is supported
        let laContext = LAContext()
        touchIdSupported = laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Delete the temp pin
        tempPin = nil
        
        if let appSettings = appSettings {
            // Initialize all the controls with their settings
            pinEnabledSwitch.isOn = appSettings.pinEnabled()
           
            autoFillMethod.selectedSegmentIndex = appSettings.autoFillMethod()
            
            darkModeEnabledSwitch.isOn = appSettings.darkEnabled()
            enableAutofillExtension.isOn = appSettings.autofillEnabled()
            touchIdEnabledSwitch.isOn = touchIdSupported && appSettings.touchIdEnabled()
            
            deleteAllDataEnabledSwitch.isOn = appSettings.deleteOnFailureEnabled()
            deleteAllDataAttemptsCell.detailTextLabel!.text = deleteAllDataAttempts[appSettings.deleteOnFailureAttemptsIndex()]
            
            closeDatabaseEnabledSwitch.isOn = appSettings.closeEnabled()
            closeDatabaseTimeoutCell.detailTextLabel!.text = closeDatabaseTimeouts[appSettings.closeTimeoutIndex()]
            
            rememberDatabasePasswordsEnabledSwitch.isOn = appSettings.rememberPasswordsEnabled()
            
            hidePasswordsEnabledSwitch.isOn = appSettings.hidePasswords()
            
            sortingEnabledSwitch.isOn = appSettings.sortAlphabetically()

            searchTitleOnlySwitch.isOn = appSettings.searchTitleOnly()
            
            passwordEncodingCell.detailTextLabel!.text = passwordEncodings[appSettings.passwordEncodingIndex()]
            
            clearClipboardEnabledSwitch.isOn = appSettings.clearClipboardEnabled()
            clearClipboardTimeoutCell.detailTextLabel!.text = clearClipboardTimeouts[appSettings.clearClipboardTimeoutIndex()]
            
            excludeFromBackupsEnabledSwitch.isOn = appSettings.backupEnabled()
            
            
            integratedWebBrowserEnabledSwitch.isOn = appSettings.webBrowserIntegrated()
            
            //analyseData.isOn = appSettings.analyseDataEnabled()
        }
        
        // Update which controls are enabled
        updateEnabledControls()
        
        /*let adb = AutoFillDB()
        adb.GetEntrys()*/
        
    }
    
    fileprivate func updateEnabledControls() {
        guard let appSettings = appSettings else {
            return
        }
        
        let pinEnabled = appSettings.pinEnabled()
        let deleteOnFailureEnabled = appSettings.deleteOnFailureEnabled()
        let closeEnabled = appSettings.closeEnabled()
        let clearClipboardEnabled = appSettings.clearClipboardEnabled()
        let accountEnabled = appSettings.backupEnabled()
        
         // Enable/disable the components dependant on settings
       
        setCellEnabled(touchIdEnabledCell, enabled: touchIdSupported)
        touchIdEnabledSwitch.isEnabled = touchIdSupported
        setCellEnabled(deleteAllDataEnabledCell, enabled: pinEnabled)
        setCellEnabled(deleteAllDataAttemptsCell, enabled: pinEnabled && deleteOnFailureEnabled)
        setCellEnabled(closeDatabaseTimeoutCell, enabled: closeEnabled)
        setCellEnabled(clearClipboardTimeoutCell, enabled: clearClipboardEnabled)
        setCellEnabled(accountDetailCell, enabled: accountEnabled)
    }
    
    fileprivate func setCellEnabled(_ cell: UITableViewCell, enabled: Bool) {
        cell.selectionStyle = enabled ? UITableViewCell.SelectionStyle.blue : UITableViewCell.SelectionStyle.none
        cell.textLabel!.isEnabled = enabled
        cell.detailTextLabel?.isEnabled = enabled
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Only allow these segues if the setting is enabled
        if (identifier == "PIN Lock Timeout") {
            return pinEnabledSwitch.isOn
        } else if (identifier == "Delete All Data Attempts") {
            return deleteAllDataEnabledSwitch.isOn
        } else if (identifier == "Close Database Timeout") {
            return closeDatabaseEnabledSwitch.isOn
        } else if (identifier == "Clear Clipboard Timeout") {
            return clearClipboardEnabledSwitch.isOn
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "CloudAccount"){
            let appSettings = AppSettings.sharedInstance() as AppSettings
            let cloudacountviewcontroller = segue.destination as! CloudAccountViewController
            cloudacountviewcontroller.user = appSettings.cloudUser() ?? "user"
            cloudacountviewcontroller.url = appSettings.cloudURL() ?? "https:"
            cloudacountviewcontroller.pwd = appSettings.cloudPWD() ?? "123"
            cloudacountviewcontroller.selindex = appSettings.cloudType() ?? 0
            
            self.navigationController?.popViewController(animated: true)
        }else{
            let selectionViewController = segue.destination as! SelectionViewController
            if (segue.identifier == "Delete All Data Attempts") {
                selectionViewController.items = deleteAllDataAttempts
                selectionViewController.selectedIndex = (appSettings?.deleteOnFailureAttemptsIndex())!
                selectionViewController.itemSelected = { (selectedIndex) in
                    self.appSettings?.setDeleteOnFailureAttemptsIndex(selectedIndex)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if (segue.identifier == "Close Database Timeout") {
                selectionViewController.items = closeDatabaseTimeouts
                selectionViewController.selectedIndex = (appSettings?.closeTimeoutIndex())!
                selectionViewController.itemSelected = { (selectedIndex) in
                    self.appSettings?.setCloseTimeoutIndex(selectedIndex)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if (segue.identifier == "Password Encoding") {
                selectionViewController.items = passwordEncodings
                selectionViewController.selectedIndex = (appSettings?.passwordEncodingIndex())!
                selectionViewController.itemSelected = { (selectedIndex) in
                    self.appSettings?.setPasswordEncoding(selectedIndex)
                    self.navigationController?.popViewController(animated: true)
                }
            } else if (segue.identifier == "Clear Clipboard Timeout") {
                selectionViewController.items = clearClipboardTimeouts
                selectionViewController.selectedIndex = (appSettings?.clearClipboardTimeoutIndex())!
                selectionViewController.itemSelected = { (selectedIndex) in
                    self.appSettings?.setClearClipboardTimeoutIndex(selectedIndex)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                assertionFailure("Unknown segue")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func SelAutoFilleMethod(_ sender: UISegmentedControl) {
        self.appSettings?.setautoFillMethod(autoFillMethod.selectedSegmentIndex)
    }
    
    @IBAction func donePressedAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
    /*@IBAction func analyseDataChnaged(_ sender: UISwitch) {
        
        if(analyseData.isOn){
            self.appSettings?.setAnalyseDataEnabled(true)
        }else{
           
            //print(retval as Any)
            self.appSettings?.setAnalyseDataEnabled(false)
        }
    }*/
    
    
    
    
    @IBAction func pinEnabledChanged(_ sender: UISwitch) {
        if (pinEnabledSwitch.isOn) {
            self.appSettings?.setPinEnabled(true)
           /* let pinViewController = PinViewController()
            pinViewController.titleLabel.text = NSLocalizedString("Set PIN", comment: "")
            pinViewController.delegate = self
            
            // Background is clear for lock screen blur, set to white to set the pin.
            pinViewController.view.backgroundColor = UIColor.white
            
            present(pinViewController, animated: true, completion: nil)*/
            let mode = ALMode.create
            let appSettings = AppSettings.sharedInstance() as AppSettings
            var col = UIColor.white
           
            if #available(iOS 13.0, *) {
                if (appSettings.darkEnabled()) {
                    
                    col = UIColor.black
                }
            }
            
            let options = ALOptions()
                options.image = UIImage(named: "AppIcon60x60")!
                options.title = "KeePassMini Pin creation"
                options.isSensorsEnabled = false
                options.color = col
                options.onSuccessfulDismiss = { (mode: ALMode?) in
                    if let mode = mode {
                        self.appSettings?.setPinEnabled(true)
                        self.updateEnabledControls()
                        print("Password \(String(describing: mode))d successfully")
                    } else {
                        print("User Cancelled")
                    }
                }
                options.onFailedAttempt = { (mode: ALMode?) in
                    print("Failed to \(String(describing: mode))")
                }

                AppLocker.present(with: mode, and: options, over: self)
            
        } else {
            self.appSettings?.setPinEnabled(false)
            
            // Delete the PIN from the keychain
            //KeychainUtils.deleteString(forKey: "PIN", andServiceName: KEYCHAIN_PIN_SERVICE)
            let mode = ALMode.deactive
            let appSettings = AppSettings.sharedInstance() as AppSettings
            var col = UIColor.white
           
            if #available(iOS 13.0, *) {
                if (appSettings.darkEnabled()) {
                    
                    col = UIColor.black
                }
            }
            
            let options = ALOptions()
               // let img = UIImage(named: "AppIcon")
                
                options.image = UIImage (named:"AppIcon60x60");
                options.title = "KeePassMini Pin deletion"
                options.isSensorsEnabled = false
                options.color = col
                options.onSuccessfulDismiss = { (mode: ALMode?) in
                    if let mode = mode {
                        self.appSettings?.setPinEnabled(false)
                        self.updateEnabledControls()
                        print("Password \(String(describing: mode))d successfully")
                    } else {
                        print("User Cancelled")
                    }
                }
                options.onFailedAttempt = { (mode: ALMode?) in
                    print("Failed to \(String(describing: mode))")
                }

                AppLocker.present(with: mode, and: options, over: self)
            // Update which controls are enabled
            //updateEnabledControls()
        }
        updateEnabledControls()
    }
    
    @IBAction func darkEnabledChanged(_ sender: UISwitch) {
        if(darkModeEnabledSwitch.isOn){
                   self.appSettings?.setDarkEnabled(darkModeEnabledSwitch.isOn)
               }else{
                   self.appSettings?.setDarkEnabled(false);
                   
               }
        
        if #available(iOS 13.0, *) {
            if (self.appSettings?.darkEnabled() == true) {
                       UIApplication.shared.windows.forEach { window in
                           window.overrideUserInterfaceStyle = .dark
                           print("Dark mode")
                       }
                   }else{
                       UIApplication.shared.windows.forEach { window in
                           window.overrideUserInterfaceStyle = .light
                           print("Light mode")
                       }
                   }
               } 
    }
    
    @IBAction func touchIdEnabledChanged(_ sender: UISwitch) {
        if(touchIdEnabledSwitch.isOn){
            self.appSettings?.setTouchIdEnabled(touchIdEnabledSwitch.isOn)
        }else{
            self.appSettings?.setTouchIdEnabled(false);
            KeychainUtils.deleteAll(forServiceName: KEYCHAIN_PASSWORDS_SERVICE)
        }
    }
    
    @IBAction func deleteAllDataEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setDeleteOnFailureEnabled(deleteAllDataEnabledSwitch.isOn)
        
        // Update which controls are enabled
        updateEnabledControls()
    }
    
    @IBAction func closeDatabaseEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setCloseEnabled(closeDatabaseEnabledSwitch.isOn)

        // Update which controls are enabled
        updateEnabledControls()
    }
    
    @IBAction func rememberDatabasePasswordsEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setRememberPasswordsEnabled(rememberDatabasePasswordsEnabledSwitch.isOn)
        
        
        KeychainUtils.deleteAll(forServiceName: KEYCHAIN_PASSWORDS_SERVICE)
        KeychainUtils.deleteAll(forServiceName: KEYCHAIN_KEYFILES_SERVICE)
    }
    
    @IBAction func hidePasswordsEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setHidePasswords(hidePasswordsEnabledSwitch.isOn)
    }
    
    @IBAction func sortingEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setSortAlphabetically(sortingEnabledSwitch.isOn)
    }

    @IBAction func searchTitleOnlyChanged(_ sender: UISwitch) {
        self.appSettings?.setSearchTitleOnly(searchTitleOnlySwitch.isOn)
    }

    @IBAction func clearClipboardEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setClearClipboardEnabled(clearClipboardEnabledSwitch.isOn)
        
        // Update which controls are enabled
        updateEnabledControls()
    }
    
    @IBAction func autfillExtensionEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setAutofillEnabled(enableAutofillExtension.isOn)
        
        if(enableAutofillExtension.isOn == false){
            //Remove Autfille.DB if is possible
            let abd = AutoFillDB()
            abd.RemoveDB()
            
            
        }
    }
    
    @IBAction func excludeFromBackupEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setBackupEnabled(excludeFromBackupsEnabledSwitch.isOn)
        /*if(userText.text != nil){
            self.appSettings?.setCloudUser(userText.text)
        }
        if(pwdText.text != nil){
            self.appSettings?.setCloudPWD(pwdText.text)
        }
        if(urlText.text != nil){
            self.appSettings?.setCloudURL(urlText.text)
        }*/
        updateEnabledControls()
    }
    
    @IBAction func integratedWebBrowserEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setWebBrowserIntegrated(integratedWebBrowserEnabledSwitch.isOn)
    }
    
    // MARK: - Pin view delegate
 /*   func pinViewController(_ pinViewController: PinViewController!, pinEntered: String!) {
        if (tempPin == nil) {
            tempPin = pinEntered
            
            pinViewController.titleLabel.text = NSLocalizedString("Confirm PIN", comment: "")
            
            // Clear the PIN entry for confirmation
            pinViewController.clearPin()
        } else if (tempPin == pinEntered) {
            tempPin = nil
            
            // Hash the pin
            let pinHash = PasswordUtils.hashPassword(pinEntered)
            
            // Set the PIN and enable the PIN enabled setting
            appSettings?.setPin(pinHash)
            appSettings?.setPinEnabled(true)
            
            // Update which controls are enabled
            updateEnabledControls()
            
            // Remove the PIN view
            dismiss(animated: true, completion: nil)
        } else {
            tempPin = nil
            
            // Notify the user the PINs they entered did not match
            pinViewController.titleLabel.text = NSLocalizedString("PINs did not match. Try again", comment: "")
            
            // Vibrate the phone
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            // Clear the PIN entry to let them try again
            pinViewController.clearPin()
        }
    }*/
}
