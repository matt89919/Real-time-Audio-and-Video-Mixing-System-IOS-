//
//  Extensions.swift
//  mixer
//
//  Created by 蔡汎昀 on 2022/3/29.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
