import Foundation

extension _MessagePackEncoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        private var storage: [AnyCodingKey: _MessagePackEncodingContainer] = [:]
        
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
            return self.codingPath + [key]
        }
        
        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        var sortKeys: Bool {
            return userInfo[MessagePackEncoder.sortKeysKey] as? Bool ?? false
        }
    }
}

extension _MessagePackEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key)
        try container.encodeNil()
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        var container = self.nestedSingleValueContainer(forKey: key)
        try container.encode(value)
    }
    
    private func nestedSingleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
        let container = _MessagePackEncoder.SingleValueContainer(codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        self.storage[AnyCodingKey(key)] = container
        return container
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = _MessagePackEncoder.UnkeyedContainer(codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        self.storage[AnyCodingKey(key)] = container

        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = _MessagePackEncoder.KeyedContainer<NestedKey>(codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        self.storage[AnyCodingKey(key)] = container

        return KeyedEncodingContainer(container)
    }
    
    func superEncoder() -> Encoder {
        fatalError("Unimplemented") // FIXME
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Unimplemented") // FIXME
    }
}

extension _MessagePackEncoder.KeyedContainer: _MessagePackEncodingContainer {
    var data: Data {
        var data = Data()
        
        let length = storage.count
        if let uint16 = UInt16(exactly: length) {
            if length <= 15 {
                data.append(0x80 + UInt8(length))
            } else {
                data.append(0xde)
                data.append(contentsOf: uint16.bytes)
            }
        } else if let uint32 = UInt32(exactly: length) {
            data.append(0xdf)
            data.append(contentsOf: uint32.bytes)
        } else {
            fatalError()
        }
        
        var storageToEncode = Array(self.storage)
        if sortKeys {
            storageToEncode.sort { $0.key.stringValue < $1.key.stringValue }
        }

        for (key, container) in storageToEncode {
            let keyContainer = _MessagePackEncoder.SingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
            try! keyContainer.encode(key.stringValue)
            data.append(keyContainer.data)
            
            data.append(container.data)
        }
        
        return data
    }
}
