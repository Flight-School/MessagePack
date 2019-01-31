# MessagePack

[![Build Status][build status badge]][build status]

A [MessagePack](https://msgpack.org/) encoder and decoder for `Codable` types.

This functionality is discussed in Chapter 7 of
[Flight School Guide to Swift Codable](https://flight.school/books/codable).

## MessagePackEncoder

```swift
let encoder = MessagePackEncoder()
let value = try! encoder.encode(["a": 1, "b": 2, "c": 3])
// [0x83, 0xA1, 0x62, 0x02, 0xA1, 0x61, 0x01, 0xA1, 0x63, 0x03]
```

## MessagePackDecoder

```swift
let decoder = MessagePackDecoder()
let data = Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E])
let value = try! decoder.decode(Double.self, from: data)
// 3.14159
```

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[build status]: https://travis-ci.com/Flight-School/MessagePack
[build status badge]: https://api.travis-ci.com/Flight-School/MessagePack.svg?branch=master
