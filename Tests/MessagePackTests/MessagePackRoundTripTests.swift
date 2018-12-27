import XCTest
@testable import MessagePack

class MessagePackRoundTripTests: XCTestCase {
    var encoder: MessagePackEncoder!
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        self.encoder = MessagePackEncoder()
        self.decoder = MessagePackDecoder()
    }

    func testRoundTrip() {
        let value = Airport.example
        let encoded = try! encoder.encode(value)
        let decoded = try! decoder.decode(Airport.self, from: encoded)
        
        XCTAssertEqual(value.name, decoded.name)
        XCTAssertEqual(value.iata, decoded.iata)
        XCTAssertEqual(value.icao, decoded.icao)
        XCTAssertEqual(value.coordinates[0], decoded.coordinates[0], accuracy: 0.01)
        XCTAssertEqual(value.coordinates[1], decoded.coordinates[1], accuracy: 0.01)
        XCTAssertEqual(value.runways[0].direction, decoded.runways[0].direction)
        XCTAssertEqual(value.runways[0].distance, decoded.runways[0].distance)
        XCTAssertEqual(value.runways[0].surface, decoded.runways[0].surface)
    }

    func testRoundTripArray() {
        let count: UInt8 = 100
        var bytes: [UInt8] = [0xdc, 0x00, count]
        var encoded: [Int] = []
        for n in 1...count {
            bytes.append(n)
            encoded.append(Int(n))
        }

        let data = Data(bytes: bytes)
        let decoded = try! decoder.decode([Int].self, from: data)
        XCTAssertEqual(encoded, decoded)
    }

    func testTripDictionary() {
        let (a, z): (UInt8, UInt8) = (0x61, 0x7a)
        var bytes: [UInt8] = [0xde, 0x00, 0x1A]
        var encoded: [String: Int] = [:]
        for n in a...z {
            bytes.append(contentsOf: [0xA1, n, n])
            encoded[String(Unicode.Scalar(n))] = Int(n)
        }

        let data = Data(bytes: bytes)
        let decoded = try! decoder.decode([String: Int].self, from: data)
        XCTAssertEqual(encoded, decoded)
    }
    
    static var allTests = [
        ("testRoundTrip", testRoundTrip)
    ]
}
