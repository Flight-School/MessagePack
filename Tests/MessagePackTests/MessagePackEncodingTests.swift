import XCTest
@testable import MessagePack

class MessagePackEncodingTests: XCTestCase {
    var encoder: MessagePackEncoder!
    
    override func setUp() {
        self.encoder = MessagePackEncoder()
    }
    
    func testEncodeNil() {
        let value = try! encoder.encode(nil as Int?)
        XCTAssertEqual(value, Data(bytes: [0xc0]))
    }
    
    func testEncodeFalse() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data(bytes: [0xc2]))
    }
    
    func testEncodeTrue() {
        let value = try! encoder.encode(true)
        XCTAssertEqual(value, Data(bytes: [0xc3]))
    }
    
    func testEncodeInt() {
        let value = try! encoder.encode(42 as Int)
        XCTAssertEqual(value, Data(bytes: [0x2A]))
    }
    
    func testEncodeUInt() {
        let value = try! encoder.encode(128 as UInt)
        XCTAssertEqual(value, Data(bytes: [0xCC, 0x80]))
    }
    
    func testEncodeFloat() {
        let value = try! encoder.encode(3.14 as Float)
        XCTAssertEqual(value, Data(bytes: [0xCA, 0x40, 0x48, 0xF5, 0xC3]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159 as Double)
        XCTAssertEqual(value, Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E]))
    }
    
    func testEncodeString() {
        let value = try! encoder.encode("hello")
        XCTAssertEqual(value, Data(bytes: [0xA5, 0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    }
    
    func testEncodeArray() {
        let value = try! encoder.encode([1, 2, 3])
        XCTAssertEqual(value, Data(bytes: [0x93, 0x01, 0x02, 0x03]))
    }
    
    func testEncodeDictionary() {
        let value = try! encoder.encode(["a": 1])
        XCTAssertEqual(value, Data(bytes: [0x81, 0xA1, 0x61, 0x01]))
    }
    
    func testEncodeData() {
        let data = "hello".data(using: .utf8)
        let value = try! encoder.encode(data)
        XCTAssertEqual(value, Data(bytes: [0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    }
    
    func testEncodeDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode(date)
        XCTAssertEqual(value, Data(bytes: [0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]))
    }
    
    func testEncodeArrayWithDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode([date])
        XCTAssertEqual(value, Data(bytes: [0x91, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]))
    }
    
    func testEncodeDictionaryWithDate() {
        let date = Date(timeIntervalSince1970: 1)
        let value = try! encoder.encode(["1": date])
        XCTAssertEqual(value, Data(bytes: [0x81, 0xA1, 0x31, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01]))
    }

    static var allTests = [
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeInt", testEncodeInt),
        ("testEncodeUInt", testEncodeUInt),
        ("testEncodeFloat", testEncodeFloat),
        ("testEncodeDouble", testEncodeDouble),
        ("testEncodeArray", testEncodeArray),
        ("testEncodeDictionary", testEncodeDictionary),
        ("testEncodeDate", testEncodeDate),
        ("testEncodeArrayWithDate", testEncodeArrayWithDate),
        ("testEncodeDictionaryWithDate", testEncodeDictionaryWithDate)
    ]
}
