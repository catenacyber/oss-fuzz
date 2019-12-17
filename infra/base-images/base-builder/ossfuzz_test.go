package mypackagebeingfuzzed

import (
	"io/ioutil"
	"os"
	"testing"
)

func TestFuzzCorpus(t *testing.T) {
	dir := os.Getenv("FUZZ_CORPUS_DIR")
	if dir == "" {
		t.Logf("No fuzzing corpus directory set")
		return
	}
	infos, err := ioutil.ReadDir(dir)
	if err != nil {
		t.Logf("Not fuzzing corpus directory %s", err)
		return
	}
	filename := ""
	defer func() {
		if r := recover(); r != nil {
			t.Error("Fuzz panicked in "+filename, r)
		}
	}()
	for i := range infos {
		filename = dir + infos[i].Name()
		data, err := ioutil.ReadFile(filename)
		if err != nil {
			t.Error("Failed to read corpus file", err)
		}
		FuzzFunction(data)
	}
}
