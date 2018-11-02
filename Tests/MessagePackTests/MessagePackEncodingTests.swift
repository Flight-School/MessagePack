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
        let value = try! encoder.encode(42)
        XCTAssertEqual(value, Data(bytes: [0x2A]))
    }
    
    func testEncodeIntAsUInt() {
        let value = try! encoder.encode(128)
        XCTAssertEqual(value, Data(bytes: [0xCC, 0x80]))
    }
    
    func testEncodeFloat() {
        let value = try! encoder.encode(3.14 as Float)
        XCTAssertEqual(value, Data(bytes: [0xCA, 0x40, 0x48, 0xF5, 0xC3]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159)
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

    static var allTests = [
        ("testEncodeFalse", testEncodeFalse),
        ("testEncodeTrue", testEncodeTrue),
        ("testEncodeInt", testEncodeInt),
        ("testEncodeDouble", testEncodeDouble),
        ("testEncodeArray", testEncodeArray),
        ("testEncodeDictionary", testEncodeDictionary)
    ]
}
