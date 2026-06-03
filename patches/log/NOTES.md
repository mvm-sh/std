# log

`log_test.go` (internal `package log` tests) is removed via `.delete`: mvm's
`mvm test` loads one compilation unit and prefers internal test files over
external ones, which would suppress the external `example_test.go`. Those
examples (ExampleLogger*) verify log's `runtime.Caller` file:line output and are
the motivation for interpreting log, so we keep the examples and drop the
internal tests. Running both would need mvm to load internal+external test
packages together.
