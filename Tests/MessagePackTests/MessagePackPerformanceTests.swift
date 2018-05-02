import XCTest
@testable import MessagePack

class MessagePackPerformanceTests: XCTestCase {
    var encoder: MessagePackEncoder!
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        self.encoder = MessagePackEncoder()
        self.decoder = MessagePackDecoder()
    }
    
    func testPerformance() {
        let value = Airport(name: "Portland International Airport", iata: "PDX", icao: "KPDX", coordinates: [-122.5975, 45.5886111111111], runways: [Airport.Runway(direction: "3/21", distance: 1829, surface: .flexible)])
        let count = 100
        let values = [Airport](repeating: value, count: count)
        
        self.measure {
            let encoded = try! encoder.encode(values)
            let decoded = try! decoder.decode([Airport].self, from: encoded)
            XCTAssertEqual(decoded.count, count)
        }
    }
}
