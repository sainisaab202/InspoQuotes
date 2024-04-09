//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    //this is the id of our in-app purchase product
    let productID = "com.sainisaab202.InspoQuotes.PremiumQuotes"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        SKPaymentQueue.default().add(self)
        
        if isPurchased(){
            showPremiumQuotes()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isPurchased(){
            return quotesToShow.count
        }else{
            return quotesToShow.count + 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)

        var content = cell.defaultContentConfiguration()
        
        if indexPath.row < quotesToShow.count{
            content.text = quotesToShow[indexPath.row]
            cell.accessoryType = .none
        }else{
            content.text = "Get More Quotes"
            content.textProperties.color = .systemTeal
            cell.accessoryType = .disclosureIndicator
        }

        cell.contentConfiguration = content
        
        return cell
    }

    //MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count{
            buyPremiumQuotes()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - In-App purchase method
    func buyPremiumQuotes() {
        //to check if user can make in-app purchase payment
        if SKPaymentQueue.canMakePayments(){
            //can make payment
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            
            SKPaymentQueue.default().add(paymentRequest)
            
        }else{
            print("User can't make payments")
        }
    }
    
    func showPremiumQuotes() {
        //adding premium quotes to normal quotes
        quotesToShow.append(contentsOf: premiumQuotes)
        
        //remove bar button
        navigationItem.setRightBarButton(nil, animated: true)
        
        tableView.reloadData()
    }
    
    func isPurchased() -> Bool{
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        return purchaseStatus
    }
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }


}

//MARK: - Observer for SKPaymentTransaction
extension QuoteTableViewController: SKPaymentTransactionObserver{
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            if transaction.transactionState == .purchased{
                //payment succeed
                print("Transaction success")
                
                showPremiumQuotes()
                
                UserDefaults.standard.setValue(true, forKey: productID)
                
                //need to finish transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .failed{
                //payment failed
                if let error = transaction.error{
                    print("Transaction failed: \(error.localizedDescription)")
                }
                
                //need to finish transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            }else if transaction.transactionState == .restored{
                print("transaction restored")
                showPremiumQuotes()
                
                UserDefaults.standard.setValue(true, forKey: productID)
                
                //need to finish transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
}
