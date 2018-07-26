import Foundation

/**
 An object that encodes instances of a data type as MessagePack objects.
 */
final public class MessagePackEncoder {
    public init() {}
    
    /**
     A dictionary you use to customize the encoding process
     by providing contextual information.
    */
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /**
     Returns a MessagePack-encoded representation of the value you supply.
     
     - Parameters:
        - value: The value to encode as MessagePack.
     - Throws: `EncodingError.invalidValue(_:_:)`
                if the value can't be encoded as a MessagePack object.
     */
    public func encode(_ value: Encodable) throws -> Data {
        let encoder = _MessagePackEncoder()
        encoder.userInfo = self.userInfo
        
        try value.encode(to: encoder)
        return encoder.data
    }
}

// MARK: -

protocol MessagePackEncodingContainer {
    var data: Data { get }
}

class _MessagePackEncoder {
    var codingPath: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate var container: MessagePackEncodingContainer?
    
    var data: Data {
        return container?.data ?? Data()
    }
}

extension _MessagePackEncoder: Encoder {
    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()
        
        let container = KeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()
        
        let container = UnkeyedContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()
        
        let container = SingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}
