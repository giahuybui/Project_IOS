//
//  SignupController.swift
//  Project_Map
//
//  Created by CNTT on 5/26/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import UIKit

class SignupController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var edtEmail: UITextField!
    @IBOutlet weak var edtPass: UITextField!
    @IBOutlet weak var edtRePass: UITextField!
    private var dao: Database!
    private var user: User!
    
    @IBAction func btnSignUp(_ sender: UIButton) {
        if check() {
            dao.insert(user: user)
            dismiss(animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "Thông báo", message: "Mật khẩu hoặc tài khoản không đúng vui lòng nhập lại", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Mark: Text Field Delegate function
    // B2: Dinh nghia cac ham uy quyen can thiet
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        edtName.resignFirstResponder();
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edtName.delegate = self
        
        dao = Database()
    }
    
    func check() -> Bool {
        var ok = false
        
        let name = edtName.text ?? ""
        let email = edtEmail.text ?? ""
        let pass = edtPass.text ?? ""
        let repass = edtRePass.text ?? ""
        
        if repass == pass {
            if name != "" || email != "" || pass != "" || repass != "" {
                user = User(name: name, email: email, pass: pass)
                ok = true
            }
        }
        
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
