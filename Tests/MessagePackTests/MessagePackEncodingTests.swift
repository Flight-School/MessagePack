@testable import MessagePack
import XCTest

class MessagePackEncodingTests: XCTestCase {
    var encoder: MessagePackEncoder!
    
    override func setUp() {
        encoder = MessagePackEncoder()
    }
    
    func testEncodeNil() {
        let value = try! encoder.encode(nil as Int?)
        XCTAssertEqual(value, Data([0xc0]))
    }
    
    func testEncodeFalse() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data([0xc2]))
    }
    
    func testEncodeTrue() {
        let value = try! encoder.encode(true)
        XCTAssertEqual(value, Data([0xc3]))
    }
    
    func testEncodeInt() {
        let value = try! encoder.encode(42 as Int)
        XCTAssertEqual(value, Data([0x2a]))
    }
    
    func testEncodeUInt() {
        let value = try! encoder.encode(128 as UInt)
        XCTAssertEqual(value, Data([0xcc, 0x80]))
    }
    
    func testEncodeFloat() {
        let value = try! encoder.encode(3.14 as Float)
        XCTAssertEqual(value, Data([0xca, 0x40, 0x48, 0xf5, 0xc3]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159 as Double)
        XCTAssertEqual(value, Data([0xcb, 0x40, 0x09, 0x21, 0xf9, 0xf0, 0x1b, 0x86, 0x6e]))
    }
    
    func testEncodeString() {
        let value = try! encoder.encode("hello")
        XCTAssertEqual(value, Data([0xa5, 0x68, 0x65, 0x6c, 0x6c, 0x6f]))
    }
    
    func testEncodeFixedArray() {
        let value = try! encoder.encode([1, 2, 3])
        XCTAssertEqual(value, Data([0x93, 0x01, 0x02, 0x03]))
    }

    func testEncodeVariableArray() {
        let value = try! encoder.encode(Array(1...16))
        XCTAssertEqual(value, Data([0xdc] + [0x00, 0x10] + Array(0x01...0x10)))
    }
    
    func testEncodeFixedDictionary() {
        let value = try! encoder.encode(["a": 1])
        XCTAssertEqual(value, Data([0x81, 0xa1, 0x61, 0x01]))
    }

    func testEncodeVariableDictionary() {
        let letters = "abcdefghijklmnopqrstuvwxyz".unicodeScalars
        let dictionary = Dictionary(uniqueKeysWithValues: zip(letters.map { String($0) }, 1...26))
        let value = try! encoder.encode(dictionary)
        XCTAssertEqual(value.count, 81)
        XCTAssert(value.starts(with: [0xde] + [0x00, 0x1a]))
    }
    
    func testEncodeData() {
        let data = "hello".data(using: .utf8)
        let value = try! encoder.encode(data)
        XCTAssertEqual(value, Data([0xc4, 0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f]))
    }
    
    func testEncodeDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data([0xd6, 0xff, 0x00, 0x00, 0x00, 0x01]))
    }

    func testEncodeDistantPast() {
        let date = Date.distantPast
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data([0xc7, 0x0c, 0xff, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xf1, 0x88, 0x6b, 0x66, 0x00]))
    }

    func testEncodeDistantFuture() {
        let date = Date.distantFuture
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data([0xc7, 0x0c, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0e, 0xec, 0x31, 0x88, 0x00]))
    }

    func testEncodeArrayWithDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode([date])
        XCTAssertEqual(value, Data([0x91, 0xd6, 0xff, 0x00, 0x00, 0x00, 0x01]))
    }
    
    func testEncodeDictionaryWithDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode(["1": date])
        XCTAssertEqual(value, Data([0x81, 0xa1, 0x31, 0xd6, 0xff, 0x00, 0x00, 0x00, 0x01]))
    }

    static var allTests = [
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeInt", testEncodeInt),
        ("testEncodeUInt", testEncodeUInt),
        ("testEncodeFloat", testEncodeFloat),
        ("testEncodeDouble", testEncodeDouble),
        ("testEncodeFixedArray", testEncodeFixedArray),
        ("testEncodeVariableArray", testEncodeVariableArray),
        ("testEncodeFixedDictionary", testEncodeFixedDictionary),
        ("testEncodeVariableDictionary", testEncodeVariableDictionary),
        ("testEncodeDate", testEncodeDate),
        ("testEncodeDistantPast", testEncodeDistantPast),
        ("testEncodeDistantFuture", testEncodeDistantFuture),
        ("testEncodeArrayWithDate", testEncodeArrayWithDate),
        ("testEncodeDictionaryWithDate", testEncodeDictionaryWithDate)
    ]
}
