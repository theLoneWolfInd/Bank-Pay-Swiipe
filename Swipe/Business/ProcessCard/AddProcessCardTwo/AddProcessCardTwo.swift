//
//  AddProcessCardTwo.swift
//  Swipe
//
//  Created by evs_SSD on 1/23/20.
//  Copyright © 2020 Apple . All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import CRNotifications

import CardScan


class AddProcessCardTwo: UIViewController,UITextFieldDelegate,ScanEvents, ScanDelegate, FullScanStringsDataSource, TestingImageDataSource {
    
    func onNumberRecognized(number: String, expiry: Expiry?, numberBoundingBox: CGRect, expiryBoundingBox: CGRect?, croppedCardSize: CGSize, squareCardImage: CGImage, fullCardImage: CGImage) {
        print("number recognized")
    }
    
    func onScanComplete(scanStats: ScanStats) {
        print("scan complete")
    }
    

    let cellReuseIdentifier = "addProcessCardTwoTableCell"
    
    func scanCard() -> String { return "New Scan Card" }
    func positionCard() -> String { return "New Position Card" }
    func backButton() -> String { return "New Back" }
    func skipButton() -> String { return "New Skip" }
    func denyPermissionTitle() -> String { return "New Deny" }
    func denyPermissionMessage() -> String { return "New Deny Message" }
    func denyPermissionButton() -> String { return "GO" }
    
    var amountIs:String!
    
    var percentageIs:String!
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "results") as! ResultViewController
        vc.scanStats = scanViewController.getScanStats()
        vc.number = creditCard.number
        vc.cardImage = creditCard.image
        vc.expiration = creditCard.expiryForDisplay()
        
        self.dismiss(animated: true)
        self.present(vc, animated: true)
    }

    func userDidScanQrCode(_ scanViewController: ScanViewController, payload: String) {
        self.dismiss(animated: true)
        print(payload)
    }
    
    @IBOutlet weak var navigationBar:UIView! {
              didSet {
                  navigationBar.backgroundColor = NAVIGATION_BUSINESS_BACKGROUND_COLOR
              }
          }
          
          @IBOutlet weak var lblNavigationTitle:UILabel! {
              didSet {
                  lblNavigationTitle.text = "PROCEED CARD"
                  lblNavigationTitle.textColor = .white
              }
          }

       
       @IBOutlet weak var btnSubmit:UIButton! {
           didSet {
               // setButtonUI(btnUiDesign: btnSubmit, strText: "Submit")
               // btnSubmit.addTarget(self, action: #selector(pushToInvoice), for: .touchUpInside)
           }
       }
       
       
       
       @IBOutlet weak var tbleView: UITableView! {
               didSet
               {
                   tbleView.delegate = self
                   tbleView.dataSource = self
                   self.tbleView.backgroundColor = .white
                   self.tbleView.tableFooterView = UIView.init(frame: CGRect(origin: .zero, size: .zero))

               }
       }
       
       @IBOutlet weak var lblCardNumber:UILabel!
       
       
       
       @IBOutlet weak var btnBack:UIButton! {
           didSet {
               btnBack.addTarget(self, action: #selector(backClick), for: .touchUpInside)
           }
       }
       
    
    
    @IBOutlet weak var cameraImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.cameraImage.image = ScanViewController.cameraImage()
        
    
        // var sendPhoneNumber = ""

        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
        
        cell.txtEnterEmount.text = amountIs
        cell.txtEnterEmount.isUserInteractionEnabled = false
        
        cell.txtCreditCardNumber.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        
        // setPaddingWithImage(image: UIImage(named:"dollarCashout")!, textField: cell.txtPhoneNumber)
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
             print(countryCode)

            if countryCode != "" {
               let getCode = self.getCountryPhonceCode(countryCode)

                // print(getCode)
                
                cell.txtPhoneNumber.text = "+"+String(getCode)
                
                if getCode != "" {
                    // sendPhoneNumber = getCode + tfMobileNumber.text!
                    // getOTP(getPhoneNumber: sendPhoneNumber)
                }
            }
        }
        
        
    }
    @objc func didChangeText(textField:UITextField) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
        
        cell.txtCreditCardNumber.text = self.modifyCreditCardString(creditCardString: textField.text!)
    }
    func modifyCreditCardString(creditCardString : String) -> String {
        let trimmedString = creditCardString.components(separatedBy: .whitespaces).joined()

        let arrOfCharacters = Array(trimmedString)
        var modifiedCreditCardString = ""

        if(arrOfCharacters.count > 0) {
            for i in 0...arrOfCharacters.count-1 {
                modifiedCreditCardString.append(arrOfCharacters[i])
                if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count){
                    modifiedCreditCardString.append(" ")
                }
            }
        }
        return modifiedCreditCardString
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
        
         let newLength = (textField.text ?? "").count + string.count - range.length
         if(textField == cell.txtCreditCardNumber) {
             return newLength <= 19
         }
        
        if(textField == cell.txtCVV) {
            return newLength <= 3
        }
        // exp date
        if textField == cell.txtExpDate {
        if range.length > 0 {
          return true
        }
        if string == "" {
          return false
        }
        if range.location > 4 {
          return false
        }
        var originalText = textField.text
        let replacementText = string.replacingOccurrences(of: " ", with: "")

        //Verify entered text is a numeric value
        if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: replacementText)) {
          return false
        }

        //Put / after 2 digit
        if range.location == 2 {
          originalText?.append("/")
          textField.text = originalText
        }
          }
        
         return true
    }
    
    @objc func backClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var currentTestImages: [CGImage]?
    
    func nextSquareAndFullImage() -> (CGImage, CGImage)? {
        guard let fullCardImage = self.currentTestImages?.first else {
            print("could not get full size test image")
            return nil
        }
        
        let squareCropImage = fullCardImage
        let width = CGFloat(squareCropImage.width)
        let height = width
        let x = CGFloat(0)
        let y = CGFloat(squareCropImage.height) * 0.5 - height * 0.5
        
        guard let squareCardImage = squareCropImage.cropping(to: CGRect(x: x, y: y, width: width, height: height)) else {
            print("could not crop test image")
            return nil
        }
    
        self.currentTestImages = self.currentTestImages?.dropFirst().map { $0 }
        return (squareCardImage, fullCardImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // sideBarMenuClick()
        
        if let myLoadedString = UserDefaults.standard.string(forKey: "KeySaveCardNumber") {
            print(myLoadedString) // "Hello World"
            
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
            
            cell.txtCreditCardNumber.text = String(myLoadedString)
            
            UserDefaults.standard.set("", forKey: "KeySaveCardNumber")
            UserDefaults.standard.set(nil, forKey: "KeySaveCardNumber")
        }
        if let myLoadedString = UserDefaults.standard.string(forKey: "keySaveExpDate") {
            print(myLoadedString) // "Hello World"
            
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
            
            cell.txtExpDate.text = String(myLoadedString)
            
            UserDefaults.standard.set("", forKey: "keySaveExpDate")
            UserDefaults.standard.set(nil, forKey: "keySaveExpDate")
        }
        
        
        
        
        if !ScanViewController.isCompatible() {
            // self.scanCardButton.isHidden = true
        }
        
    }
    
    @objc func scanCardClick() {
        guard let vc = ScanViewController.createViewController(withDelegate: self) else {
            print("scan view controller not supported on this hardware")
            return
        }
        
        vc.allowSkip = true
        self.present(vc, animated: true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    
    
    func getCountryPhonceCode (_ country : String) -> String {
        let countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        if countryDictionary[country] != nil {
            return countryDictionary[country]!
        }

        else {
            return ""
        }

    }
    
    
    func setPaddingWithImage(image: UIImage, textField: UITextField){
        
        //let lblPhoneCode =
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        imageView.frame = CGRect(x: 13.0, y: 13.0, width: 24.0, height: 24.0)
        //For Setting extra padding other than Icon.
        let seperatorView = UIView(frame: CGRect(x: 50, y: 0, width: 2, height: 50))
        seperatorView.backgroundColor = UIColor(red: 80/255, green: 89/255, blue: 94/255, alpha: 1)
        view.addSubview(seperatorView)
        textField.leftViewMode = .always
        view.addSubview(imageView)
        view.backgroundColor = .clear
        textField.leftViewMode = UITextField.ViewMode.always
        textField.leftView = view
    }
    
    
    
  /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
        
        if textField == cell.txtExpDate {
      if range.length > 0 {
        return true
      }
      if string == "" {
        return false
      }
      if range.location > 4 {
        return false
      }
      var originalText = textField.text
      let replacementText = string.replacingOccurrences(of: " ", with: "")

      //Verify entered text is a numeric value
      if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: replacementText)) {
        return false
      }

      //Put / after 2 digit
      if range.location == 2 {
        originalText?.append("/")
        textField.text = originalText
      }
        }
      return true
    }
}
*/

    
    
    @objc func addWB() {
        
               // ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
               
            let defaults = UserDefaults.standard
            let userName = defaults.string(forKey: "KeyLoginPersonal")
            if userName == "loginViaPersonal" {
                // personal user
                 ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
                
            }
            else {
                 ERProgressHud.sharedInstance.showDarkBackgroundView(withTitle: "Please wait...")
            }
            let urlString = BASE_URL_SWIIPE
                   
            var parameters:Dictionary<AnyHashable, Any>!
            
             let indexPath = IndexPath(row: 0, section: 0)
             let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
            
            if let person = UserDefaults.standard.value(forKey: "keyLoginFullData") as? [String:Any]
            {
                let x : Int = (person["userId"] as! Int)
                let myString = String(x)
                
                       parameters = [
                           "action"        : "addcardprocessing",
                           "vendorId"           : String(myString),
                           "TransactionID"      : "735451245",
                           "Phone"              : String(cell.txtPhoneNumber.text!),
                           "email"              : String(cell.txtEmailAddress.text!),
                           "cardNo"             : String(cell.txtCreditCardNumber.text!),
                           "nameOnCard"        : String(cell.txtNameOnCard.text!),
                           "percentage"        : String(percentageIs),
                           "processingCharge"   : String(percentageIs),
                           "Amount"             : String(cell.txtEnterEmount.text!),
                           "Total"          : String(amountIs),
                       ]
            }
                    
                       print("parameters-------\(String(describing: parameters))")
                       
                       Alamofire.request(urlString, method: .post, parameters: parameters as? Parameters).responseJSON
                           {
                               response in
                   
                               switch(response.result) {
                               case .success(_):
                                  if let data = response.result.value {

                                   
                                   let JSON = data as! NSDictionary
                                       print(JSON)
                                   
                                   var strSuccess : String!
                                   strSuccess = JSON["status"]as Any as? String
                                   
                                   var strSuccessAlert : String!
                                   strSuccessAlert = JSON["msg"]as Any as? String
                                   
                                   if strSuccess == "success" //true
                                   {
                                    // var strPercentage : String!
                                    // strPercentage = JSON["percentage"]as Any as? String
                                    // print(strPercentage as Any)
                                    // self.strSavePercentage = strPercentage
                                    
                                    // let indexPath = IndexPath(row: 0, section: 0)
                                    // let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTableCell
                                    
                                    // cell.lblInvoiceAmount.text = "INVOICE AMOUNT : $0"
                                    // cell.lblProcessingFee.text = "PROCESSING FEE( 0% ): $0"
                                    // cell.lblTotalAmount.text = "TOTAL AMOUNT : $0"
                                    
                                    // self.navigationController?.popViewController(animated: true)
                                    
                                    
                                    
                                    
                                    let settingsVCId = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProcessingCardListId") as? ProcessingCardList
                                    self.navigationController?.pushViewController(settingsVCId!, animated: true)
                                    
                                    ERProgressHud.sharedInstance.hide()
                                   }
                                   else
                                   {
                                       // self.indicator.stopAnimating()
                                       // self.enableService()
                                    CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:strSuccessAlert, dismissDelay: 1.5, completion:{})
                                       ERProgressHud.sharedInstance.hide()
                                   }
                                   
                               }

                               case .failure(_):
                                   print("Error message:\(String(describing: response.result.error))")
                                   // self.indicator.stopAnimating()
                                   // self.enableService()
                                   ERProgressHud.sharedInstance.hide()
                                   
                                   let alertController = UIAlertController(title: nil, message: SERVER_ISSUE_MESSAGE_ONE+"\n"+SERVER_ISSUE_MESSAGE_TWO, preferredStyle: .actionSheet)
                                   
                                   let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                           UIAlertAction in
                                           NSLog("OK Pressed")
                                       }
                                   
                                   alertController.addAction(okAction)
                                   
                                   self.present(alertController, animated: true, completion: nil)
                                   
                                   break
                                }
                           }
            
            
        
   }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // searchController.searchBar.resignFirstResponder()//self.searchBar?.endEditing(true)
        self.view.endEditing(true)
    }

}
extension AddProcessCardTwo: UITableViewDataSource
        {
            func numberOfSections(in tableView: UITableView) -> Int
            {
                return 1
            }
            
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
            {
                return 1
            }
            
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
 {
    let cell:AddProcessCardTwoTableCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! AddProcessCardTwoTableCell
                
    cell.backgroundColor = .white
    
    /*
    cell.txtInvoiceAmount.delegate = self
    
    setPaddingWithImage(textField: cell.txtCustomerName, strPlaceholder: "Customer Name")
    setPaddingWithImage(textField: cell.txtEmail, strPlaceholder: "Email Address")
    setPaddingWithImage(textField: cell.txtCardNumber, strPlaceholder: "Card Number")
    setPaddingWithImage(textField: cell.txtCardExpDate, strPlaceholder: "Card Expiry Date");
    setPaddingWithImage(textField: cell.txtTotalPayableAmount, strPlaceholder: "Payable Amount")
    setPaddingWithImage(textField: cell.txtFeeOnOff, strPlaceholder: "On/Off")
    setPaddingWithImage(textField: cell.txtInvoiceAmount, strPlaceholder: "Invoice Amount")
    setPaddingWithImage(textField: cell.txtPhoneNumber, strPlaceholder: "Phone Number")
    setPaddingWithImage(textField: cell.txtCVV, strPlaceholder: "CVV")
    */
    
    cell.txtNameOnCard.delegate = self
    cell.txtEmailAddress.delegate = self
    
    cell.txtExpDate.delegate = self
    
    cell.btnChargeAmount.setTitle("Submit", for: .normal)
    cell.btnChargeAmount.addTarget(self, action: #selector(pushToChargeCardTwo), for: .touchUpInside)
    
    cell.txtCreditCardNumber.delegate = self
    cell.txtCVV.delegate = self
    
    cell.btnScanCard.addTarget(self, action: #selector(scanCardClick), for: .touchUpInside)
    
    let backgroundView = UIView()
    backgroundView.backgroundColor = .clear
    cell.selectedBackgroundView = backgroundView
    
    
    return cell
    }
    
    @objc func pushToChargeCardTwo() {
         let indexPath = IndexPath(row: 0, section: 0)
         let cell = self.tbleView.cellForRow(at: indexPath) as! AddProcessCardTwoTableCell
        
        if cell.txtNameOnCard.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"Card holder name should not be Empty", dismissDelay: 1.5, completion:{})
        }
        /*else
        if cell.txtEmailAddress.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"Email should not be Empty", dismissDelay: 1.5, completion:{})
        }*/
        else
        if cell.txtCreditCardNumber.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"Card Number should not be Empty", dismissDelay: 1.5, completion:{})
        }
        else
        if cell.txtExpDate.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"Exp. Date should not be Empty", dismissDelay: 1.5, completion:{})
        }
        else
        if cell.txtCVV.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"CVV should not be Empty", dismissDelay: 1.5, completion:{})
        }
        else
        if cell.txtZipCode.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"Zipcode should not be Empty", dismissDelay: 1.5, completion:{})
        }
        /*else if cell.txtPhoneNumber.text == "" {
            CRNotifications.showNotification(type: CRNotifications.error, title: "Error!", message:"Phone number should not be Empty", dismissDelay: 1.5, completion:{})
        }*/
        else {
            addWB()
            /*
            let settingsVCId = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProcessCardPageTwoId") as? ProcessCardPageTwo
            // settingsVCId!.strGetPriceFromAddProcessCard = cell.txtEnterEmount.text
            
            settingsVCId!.strGetNameOnCardFromAddProcessCard = cell.txtNameOnCard.text
            settingsVCId!.strGetEmailFromAddProcessCard = cell.txtEmailAddress.text
            settingsVCId!.strGetCreditCardNumberFromAddProcessCard = cell.txtCreditCardNumber.text
            settingsVCId!.strGetExpDateFromAddProcessCard = cell.txtExpDate.text
            settingsVCId!.strGetCVVFromAddProcessCard = cell.txtCVV.text
            settingsVCId!.strGetZipcodeFromAddProcessCard = cell.txtZipCode.text
            settingsVCId!.strGetPhoneNumberFromAddProcessCard = cell.txtPhoneNumber.text
            self.navigationController?.pushViewController(settingsVCId!, animated: true)
 */
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1200
    }
            
}

extension AddProcessCardTwo: UITableViewDelegate {
            
}
