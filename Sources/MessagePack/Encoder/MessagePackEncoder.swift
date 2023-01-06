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
    public func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let encoder = _MessagePackEncoder()
        encoder.userInfo = self.userInfo
        encoder.userInfo[MessagePackEncoder.sortKeysKey] = sortKeys
        
        switch value {
        case let data as Data:
            try Box<Data>(data).encode(to: encoder)
        case let date as Date:
            try Box<Date>(date).encode(to: encoder)
        default:
            try value.encode(to: encoder)
        }
        
        return encoder.data
    }

    /**
     An option used by the encoder whether to sort keys while encoding keyed containers to achieve a deterministic output
     */
    public var sortKeys: Bool = false

    internal static var sortKeysKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "sortKeysKey")!
    }
}

// MARK: - TopLevelEncoder

#if canImport(Combine)
import Combine

extension MessagePackEncoder: TopLevelEncoder {
    public typealias Input = Data
}
#endif

// MARK: -

protocol _MessagePackEncodingContainer {
    var data: Data { get }
}

class _MessagePackEncoder {
    var codingPath: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate var container: _MessagePackEncodingContainer?
    
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
