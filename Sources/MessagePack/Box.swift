import Foundation

struct Box<Value> {
    let value: Value
    init(_ value: Value) {
        self.value = value
    }
}

extension Box: Encodable where Value: Encodable {
    func encode(to encoder: Encoder) throws {
        try self.value.encode(to: encoder)
    }
}

extension Box: Decodable where Value: Decodable {
    init(from decoder: Decoder) throws {
        self.init(try Value(from: decoder))
    }
}

extension Box where Value == Data {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Value.self))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

extension Box where Value == Date {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Value.self))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

extension Box where Value == URL {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(Value.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
