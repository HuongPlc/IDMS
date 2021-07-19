//
//  ConfigViewController.swift
//  iDMS2018
//
//  Created by Huong on 7/18/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet var EDMSTextField: UITextField!
    @IBOutlet var companyTextField: UITextField!
    @IBOutlet var separateEDMSView: UIView!
    @IBOutlet var separateCompanyCodeView: UIView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var logoutButton: UIButton!

    var edms: String?

    var companyCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configSeparateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EDMSTextField.text = edms
        companyTextField.text = companyCode
    }

    private func configSeparateView() {
        EDMSTextField.becomeFirstResponder()
        EDMSTextField.delegate = self
        companyTextField.delegate = self
        separateEDMSView.backgroundColor = .green

        saveButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
    }

    private func validate() -> ConfigInfo? {
        if EDMSTextField.text?.isEmpty == true || companyTextField.text?.isEmpty == true {
            let myalert = UIAlertController(title: "Không hợp lệ", message: "Điền đầy đủ thông tin vào các trường bên trên", preferredStyle: .alert)

            myalert.addAction(UIAlertAction(title: "Ok", style: .default) { (_: UIAlertAction!) in
                print("Selected")
            })

            present(myalert, animated: true)

            return nil
        }
        let edms = EDMSTextField.text ?? ""
        let companyCode = companyTextField.text ?? ""
        return ConfigInfo(edms: edms, companyCode: companyCode)
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if let configInfo = validate() {
            ConfigInfoService.shared.saveInfo(info: configInfo, forKey: Constants.ConfigInfo.name)
            let vc = ViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func logoutButtonTapped(_ sender: Any) {
    }
}

extension ConfigViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == EDMSTextField {
            separateEDMSView.backgroundColor = .green
            separateCompanyCodeView.backgroundColor = .gray
        } else {
            separateEDMSView.backgroundColor = .gray
            separateCompanyCodeView.backgroundColor = .green
        }
        return true
    }
}
