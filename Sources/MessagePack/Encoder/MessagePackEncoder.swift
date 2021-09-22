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

protocol _MessagePackEncodingContainer: KeyedStorage {
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
//        assertCanCreateContainer()

        guard let container = container else {
            let container = KeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
            self.container = container

            return KeyedEncodingContainer(container)
        }

        let newContainer = KeyedContainer<Key>(keyStorage: container.keyStorage)
        self.container = newContainer


        return KeyedEncodingContainer(newContainer)
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
