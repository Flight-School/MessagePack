//import Foundation
//
//
//extension _MessagePackEncoder {
//    class _SingleValueDecodingContainer {//}: SingleValueDecodingContainer {
//        var storage: Data = Data()
//        var index: Data.Index = 0
//        
//        fileprivate func peek() -> UInt8? {
//            return storage[index]
//        }
//        
//        fileprivate func next(_ n: Int) throws -> Data {
//            guard index.advanced(by: n) <= storage.endIndex else {
//                fatalError()
////                throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of buffer")
//            }
//            
//            let range = Range<Data.Index>(uncheckedBounds: (index, index.advanced(by: n)))
//            
//            return storage.subdata(in: range)
//        }
//        
//        func decodeNil() -> Bool {
//            guard let nextByte = peek() else {
//               return false
//            }
//            
//            return nextByte == 0xc0
//        }
//        
//        func decode(_ type: Bool.Type) throws -> Bool {
//            switch self.peek() {
//            case 0xc2?:
//                return false
//            case 0xc3?:
//                return true
//            default:
//                fatalError()
//            }
//        }
//        
//        func decode(_ type: String.Type) throws -> String {
//            var length: Int
//            let nextByte = self.peek()!
//            switch nextByte {
//            case 0xa0...0xbf:
//                length = Int(nextByte >> 4) // FIXME?
//                return ""
//            case 0xd9:
//                return ""
//            case 0xda:
//                return ""
//            case 0xdb:
//                return ""
//            default:
//                fatalError()
//        }
//        
//        func decode(_ type: Double.Type) throws -> Double {
//            <#code#>
//        }
//        
//        func decode(_ type: Float.Type) throws -> Float {
//            <#code#>
//        }
//        
//        func decode(_ type: Int.Type) throws -> Int {
//            <#code#>
//        }
//        
//        func decode(_ type: Int8.Type) throws -> Int8 {
//            <#code#>
//        }
//        
//        func decode(_ type: Int16.Type) throws -> Int16 {
//            <#code#>
//        }
//        
//        func decode(_ type: Int32.Type) throws -> Int32 {
//            <#code#>
//        }
//        
//        func decode(_ type: Int64.Type) throws -> Int64 {
//            <#code#>
//        }
//        
//        func decode(_ type: UInt.Type) throws -> UInt {
//            <#code#>
//        }
//        
//        func decode(_ type: UInt8.Type) throws -> UInt8 {
//            <#code#>
//        }
//        
//        func decode(_ type: UInt16.Type) throws -> UInt16 {
//            <#code#>
//        }
//        
//        func decode(_ type: UInt32.Type) throws -> UInt32 {
//            <#code#>
//        }
//        
//        func decode(_ type: UInt64.Type) throws -> UInt64 {
//            <#code#>
//        }
//        
//        func decode(_ type: Date.type) throws -> Date {
//            
//        }
//            
//        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
//            <#code#>
//        }
//
//        
////        var storage: Data? = nil // TODO
//        // TODO: precondition that storage is nil when setting new value
//        
//        
//    
// 
//        
//        // TODO add property for user Info
//        
//        init(codingPath: [CodingKey]) {
//            self.codingPath = codingPath
//            self.storage = Data()
//        }
//        
//        var codingPath: [CodingKey]
//
//        /*
//        func encodeNil() throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//            
//            try write([MessagePack.`nil`.rawValue])
//        }
//        
//        func encode(_ value: Bool) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            switch value {
//            case true:
//                self.storage.append(0xc3)
//            case false:
//                self.storage.append(0xc2)
//            }
//        }
//        
//        func encode(_ value: String) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//            
//            guard let data = value.data(using: .utf8) else {
//                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string using UTF-8 encoding.")
//                throw EncodingError.invalidValue(value, context)
//            }
//            
//            let length = data.count
//            switch length {
//            case 0..<31:
//                self.storage.append(0xa0 + UInt8(length))
//            case ...Int(UInt8.max):
//                self.storage.append(0xd9)
//                self.storage.append(contentsOf: UInt8(length).bytes)
//            case ...Int(UInt16.max):
//                self.storage.append(0xda)
//                self.storage.append(contentsOf: UInt16(length).bytes)
//            case ...Int(UInt32.max):
//                self.storage.append(0xdb)
//                self.storage.append(contentsOf: UInt32(length).bytes)
//            default:
//                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode string with length \(length).")
//                throw EncodingError.invalidValue(value, context)
//            }
//            
//            self.storage.append(data)
//        }
//        
//        func encode(_ value: Double) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xcb)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: Float) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xca)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: Int) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            if ((0...127).contains(value)) {
//                self.storage.append(UInt8(value))
//            } else if ((-31..<0).contains(value)) {
//                self.storage.append(0xe0 + UInt8(-value))
//            } else if let int8 = Int8(exactly: value) {
//                try encode(int8)
//            } else if let int16 = Int16(exactly: value) {
//                try encode(int16)
//            } else if let int32 = Int32(exactly: value) {
//                try encode(int32)
//            } else if let int64 = Int64(exactly: value) {
//                try encode(int64)
//            } else {
//                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode integer \(value).")
//                throw EncodingError.invalidValue(value, context)
//            }
//        }
//        
//        func encode(_ value: Int8) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xd0)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: Int16) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xd1)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: Int32) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xd2)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: Int64) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xd3)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: UInt) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//            
//            if ((0...127).contains(value)) {
//                self.storage.append(UInt8(value))
//            } else if let uint8 = UInt8(exactly: value) {
//                try encode(uint8)
//            } else if let uint16 = UInt16(exactly: value) {
//                try encode(uint16)
//            } else if let uint32 = UInt32(exactly: value) {
//                try encode(uint32)
//            } else if let uint64 = UInt64(exactly: value) {
//                try encode(uint64)
//            } else {
//                let context = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot encode unsigned integer \(value).")
//                throw EncodingError.invalidValue(value, context)
//            }
//        }
//        
//        func encode(_ value: UInt8) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xcc)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: UInt16) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xcd)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: UInt32) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xce)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: UInt64) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            self.storage.append(0xcf)
//            self.storage.append(contentsOf: value.bytes)
//        }
//        
//        func encode(_ value: Date) throws {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//            
//            // FIXME sub-second precision
//            self.storage.append(0xd6)
//            try encode(-1 as Int)
//            try encode(UInt32(value.timeIntervalSince1970))
//        }
//        
//        // TODO encode date as extension
//        
//        func encode<T>(_ value: T) throws where T : Encodable {
//            try checkCanEncode(value: nil)
//            defer { self.canEncodeNewValue = false }
//
//            let encoder = _MessagePackEncoder()
//            try value.encode(to: encoder)
//            self.storage.append(encoder.data)
//        }
// */
//    }
//}
//
////extension _MessagePackDecoder._SingleValueDecodingContainer: _MessagePackDecoderContainer {}
