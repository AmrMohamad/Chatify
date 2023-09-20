//
//  AddNewUserCell.swift
//  Chatify
//
//  Created by Amr Mohamad on 20/09/2023.
//

import UIKit

class AddNewUserCell: UITableViewCell {

    static let identifier = "AddUserCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
