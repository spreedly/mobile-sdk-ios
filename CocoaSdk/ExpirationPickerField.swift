//
//  ExpirationPickerField.swift
//  CocoaSdk
//
//  Created by Eli Thompson on 6/19/20.
//

import UIKit

public class DateParts: NSObject {
    @objc let month: Int
    @objc let year: Int

    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
}

@objc(SPRExpirationDateProvider) public protocol ExpirationDateProvider: class {
    func dateParts() -> DateParts?
}

class ExpirationPickerField: ValidatedTextField {
    private lazy var doneToolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))

        let items = [flexSpace, doneButton]
        toolbar.items = items
        toolbar.sizeToFit()

        return toolbar
    }()

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()

    let items: [[String]] = {
        let months = (1...12).map {
            String(format: "%02d", $0)
        }
        let date = Date()
        let year = Calendar.current.dateComponents([.year], from: date).year ?? 2020
        let years = (year...year + 50).map {
            String($0)
        }
        return [months, ["/"], years]
    }()
    var didSelectItem: (([String]) -> Void)?

    private var selectedItems = ["", "", ""]

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        inputView = pickerView
        inputAccessoryView = doneToolbar
    }

    @objc private func doneButtonTapped() {
        didSelectItem?(selectedItems)
        resignFirstResponder()
    }

    func showPicker() {
        becomeFirstResponder()
    }
}

extension ExpirationPickerField: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        items.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        items[component].count
    }
}

extension ExpirationPickerField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        items[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItems[component] = items[component][row]
        text = "\(selectedItems[0])/\(selectedItems[2])"
        unsetError()
    }
}

extension ExpirationPickerField: ExpirationDateProvider {
    func dateParts() -> DateParts? {
        guard let month = Int(selectedItems[0]),
              let year = Int(selectedItems[2]) else {
            return nil
        }
        return DateParts(month: month, year: year)
    }
}
