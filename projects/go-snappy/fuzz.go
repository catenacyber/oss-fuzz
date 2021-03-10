// +build gofuzz

package snappy

func FuzzRoundTrip(data []byte) int {
	encoded := Encode(nil, data)
	decoded, err := snappy.Decode(nil, encoded)
	if err != nil {
		panic("Error decoding snappy-encoded")
	}
	if decoded != data {
		panic("Different result on roundtrip encode/decode")
	}
	return 1
}

func FuzzDecode(data []byte) int {
	_, err := snappy.Decode(nil, data)
	if err != nil {
		return 0
	}
	return 1
}
