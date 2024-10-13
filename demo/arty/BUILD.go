package demo

import (
	"dbt-rules/RULES/hdl"
	"dbt-rules/RULES/xilinx"
	"hdmi-dbt-demo/RULES/fpga"

	"hdmi-dbt-demo/hdmi"
)

var Project = hdl.Fpga{
	Name: "ArtyHdmiDemo",
	Top:  "top",
	Part: "xc7a100tcsg324-1",
	Library: hdl.Library{
		Srcs: ins(
			"top.sv",
			"video_mmcm.sv",
			"arty.xdc",
		),
		IpDeps: []hdl.Ip{hdmi.HdmiLib},
	},
}

var Bitstream = xilinx.Bitstream{
	Name:        "top",
	Src:         in("top.sv"),
	Constraints: in("arty.xdc"),
	Ips: []hdl.Ip{
		hdl.Library{
			Srcs: ins(
				"video_mmcm.sv",
			),
		},
		hdmi.HdmiLib,
	},
}

var FlashBitstream = fpga.FlashFpga{
	Out:       out("flash_script_arty.tcl"),
	Bitstream: Bitstream,
	Target:    "xc7a100t_0",
}
