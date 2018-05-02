import Foundation

extension _MessagePackDecoder {
    final class SingleValueContainer {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var data: Data
        var index: Data.Index

        init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.data = data
            self.index = self.data.startIndex
        }
        
        func checkCanDecode<T>(_ type: T.Type, format: UInt8) throws {
            guard self.index <= self.data.endIndex else {
                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of data")
            }
            
            guard self.data[self.index] == format else {
                let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
                throw DecodingError.typeMismatch(type, context)
            }
        }
    }
}

extension _MessagePackDecoder.SingleValueContainer: SingleValueDecodingContainer {    
    func decodeNil() -> Bool {
        let format = try? readByte()
        return format == 0xc0
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        let format = try readByte()
        switch format {
        case 0xc2: return false
        case 0xc3: return true
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }
    
    func decode(_ type: String.Type) throws -> String {
        let length: Int
        let format = try readByte()
        switch format {
        case 0xa0...0xbf:
            length = Int(format - 0xa0)
        case 0xd9:
            length = Int(try read(UInt8.self))
        case 0xda:
            length = Int(try read(UInt16.self))
        case 0xdb:
            length = Int(try read(UInt32.self))
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(Double.self, context)
        }
        
        let data = try read(length)
        guard let string = String(data: data, encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Couldn't decode string with UTF-8 encoding")
            throw DecodingError.dataCorrupted(context)
        }
        
        return string
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        let format = try readByte()
        switch format {
        case 0xca:
            let bitPattern = try read(UInt32.self)
            return Double(bitPattern: UInt64(bitPattern.bigEndian))
        case 0xcb:
            let bitPattern = try read(UInt64.self)
            return Double(bitPattern: bitPattern.bigEndian)
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        let format = try readByte()
        switch format {
        case 0xca:
            let bitPattern = try read(UInt32.self)
            return Float(bitPattern: bitPattern.bigEndian)
        case 0xcb:
            guard let bitPattern = UInt32(exactly: try read(UInt32.self)) else {
                fallthrough
            }
            return Float(bitPattern: bitPattern.bigEndian)
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(Double.self, context)
        }
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        let format = try readByte()
        switch format {
        case 0x00...0x7f:
            return Int(format)
        case 0xe0...0xff:
            return Int(0x1f & (format - 0xe0))
        case 0xd0:
            return Int(try read(Int8.self))
        case 0xd1:
            return Int(try read(Int16.self))
        case 0xd2:
            return Int(try read(Int32.self))
        case 0xd3:
            return Int(try read(Int64.self))
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(Int.self, context)
        }
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try checkCanDecode(type, format: 0xd0)
        return try read(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try checkCanDecode(type, format: 0xd1)
        return try read(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try checkCanDecode(type, format: 0xd2)
        return try read(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try checkCanDecode(type, format: 0xd3)
        return try read(type)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        let format = try readByte()
        switch format {
        case 0x00...0x7f:
            return UInt(format)
        case 0xcc:
            return UInt(try read(UInt8.self))
        case 0xcd:
            return UInt(try read(UInt16.self))
        case 0xce:
            return UInt(try read(UInt32.self))
        case 0xcf:
            return UInt(try read(UInt64.self))
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(UInt.self, context)
        }
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try checkCanDecode(type, format: 0xcc)
        return try read(type)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try checkCanDecode(type, format: 0xcd)
        return try read(type)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try checkCanDecode(type, format: 0xce)
        return try read(type)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try checkCanDecode(type, format: 0xcf)
        return try read(type)
    }
    
    func decode(_ type: Data.Type) throws -> Data {
        let length: Int
        let format = try readByte()
        switch format {
        case 0xc4:
            length = Int(try read(UInt8.self))
        case 0xc5:
            length = Int(try read(UInt16.self))
        case 0xc6:
            length = Int(try read(UInt32.self))
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid format: \(format)")
            throw DecodingError.typeMismatch(UInt.self, context)
        }
        
        return self.data.subdata(in: self.index..<self.index.advanced(by: length))
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = _MessagePackDecoder(data: self.data)
        let value = try T(from: decoder)
        if let nextIndex = decoder.container?.index {
            self.index = nextIndex
        }
        
        return value
    }
}

extension _MessagePackDecoder.SingleValueContainer: MessagePackDecodingContainer {}
