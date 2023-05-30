//
//  LoginController.swift
//  Project_Map
//
//  Created by CNTT on 5/23/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate{

    // mark: prototype
    @IBOutlet weak var edtUserName: UITextField!
    @IBOutlet weak var edtPassword: UITextField!
    private var dao: Database!
    
    // mark: Login
    @IBAction func btnLogin(_ sender: UIButton) {
        if check() {
            
        } else {
            let alertController = UIAlertController(title: "Thông báo", message: "Mật khẩu hoặc tài khoản không đúng vui lòng nhập lại", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dao = Database()
    }
    
    // B2: Dinh nghia cac ham uy quyen can thiet
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        edtPassword.resignFirstResponder();
        return true;
    }
    
    func check() -> Bool {
        var ok = false
        
        let email = edtUserName.text ?? ""
        let pass = edtPassword.text ?? ""
        
        let user = dao.getUserByEmail(email: email, pass: pass)
        if user.first?.getEmail() == email && user.first?.getPass() == pass {
            ok = true
        }
        
        dao.getAllUser()
        
        return ok
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
