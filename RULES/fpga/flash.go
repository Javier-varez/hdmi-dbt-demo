package fpga

import (
	"dbt-rules/RULES/core"
	"dbt-rules/RULES/xilinx"
	"fmt"
)

func init() {
	core.AssertIsRunnableTarget(&FlashFpga{})
	core.AssertIsBuildableTarget(&FlashFpga{})
}

var flashScriptTemplate string = `#!/bin/bash
set -eu -o pipefail

cat > {{ .ScriptFile }} <<EOF

set bitfile {{ .Bitfile }}

open_hw_manager
connect_hw_server -allow_non_jtag

open_hw_target
current_hw_device [get_hw_devices {{ .Target }}]

set_property PROGRAM.FILE \$bitfile [get_hw_devices {{ .Target }}]
program_hw_devices [get_hw_devices {{ .Target }}]

EOF
`

// Programs the FPGA via jtag
type FlashFpga struct {
	Out       core.OutPath
	Bitstream xilinx.Bitstream
	Target    string
}

func (f *FlashFpga) outBitstream() core.OutPath {
	// A bit hacky that this is not exported by the xilinx module in dbt-rules
	return f.Bitstream.Src.WithExt("bit")
}

func (f *FlashFpga) Build(ctx core.Context) {
	outBitstream := f.outBitstream()

	type templateParams struct {
		Bitfile    string
		ScriptFile string
		Target     string
	}

	buildStep := core.BuildStep{
		In:  outBitstream,
		Out: f.Out,
		Script: core.CompileTemplate(flashScriptTemplate, "flash_script", templateParams{
			Bitfile:    outBitstream.Absolute(),
			ScriptFile: f.Out.Absolute(),
			Target:     f.Target,
		}),
		Descr: fmt.Sprintf("Generating flash script %q", f.Out.Relative()),
	}
	ctx.AddBuildStep(buildStep)
}

func (f *FlashFpga) Run(args []string) string {
	outBitstream := f.outBitstream()
	logFile := outBitstream.WithExt("log").Absolute()
	return fmt.Sprintf("/usr/bin/env -S vivado -nolog -nojournal -mode batch -log %q -source %q", logFile, f.Out.Absolute())
}
