package fuzzproto

import (
"fmt"
	"github.com/google/pprof/profile"
)

func Fuzz(data []byte) int {
	prof, err := profile.ParseData(data)
fmt.Printf("lola %v\nlolb %s: %#+v\n", data, err, prof);
	if err != nil {
		return 1
		//panic("Failed to unmarshal profile")
	}
	prof.CheckValid()
	return 0
}
