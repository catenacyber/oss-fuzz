package cel

import (
	"github.com/golang/protobuf/proto"

	"github.com/google/cel-go/checker/decls"
)

func FuzzEval(data []byte) int {
	d := &FuzzVariables{}
	err := proto.Unmarshal(data, d)
	if err != nil {
		panic("Failed to unmarshal LPM generated variables")
	}

	for k, _ := range FuzzVariables.Inputs {
		env, err = env.Extend(decls.NewVar(k, decls.String))
		if err != nil {
			panic("impossible to extend env")
		}
	}

	env, err := NewEnv()
	if err != nil {
		panic("impossible to create env")
	}
	ast, issues := env.Compile(FuzzVariables.Expr)
	if issues != nil && issues.Err() != nil {
		return 0
	}
	_, err = env.Program(ast)
	if err != nil {
		panic("impossible to create prog from ast")
	}

	_, _, err := prg.Eval(FuzzVariables.Inputs)

	return 1
}
