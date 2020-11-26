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
}

// MARK: - TopLevelEncoder

#if canImport(Combine)
import Combine

extension MessagePackEncoder: TopLevelEncoder {
    public typealias Input = Data
}
#endif

// MARK: -

protocol _MessagePackEncodingContainer: class {
    var data: Data { get }
}

final class _MessagePackEncoder {
    var codingPath: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate var container: _MessagePackEncodingContainer?
    
    var data: Data {
        return container?.data ?? Data()
    }
}

extension _MessagePackEncoder: Encoder {
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        precondition(self.container == nil)
        
        let container = KeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        precondition(self.container == nil)
        
        let container = UnkeyedContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        precondition(self.container == nil)
        
        let container = SingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}
