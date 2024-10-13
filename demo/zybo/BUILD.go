package zybo

import (
	"dbt-rules/RULES/hdl"
	"dbt-rules/RULES/xilinx"
	"hdmi-dbt-demo/RULES/fpga"

	"hdmi-dbt-demo/hdmi"
)

var Project = hdl.Fpga{
	Name: "ZyboHdmiDemo",
	Top:  "top",
	Part: "xc7z010clg400-1",
	Library: hdl.Library{
		Srcs: ins(
			"top.sv",
			"video_mmcm.sv",
			"zybo.xdc",
		),
		IpDeps: []hdl.Ip{hdmi.HdmiLib},
	},
}

var Bitstream = xilinx.Bitstream{
	Name:        "top",
	Src:         in("top.sv"),
	Constraints: in("zybo.xdc"),
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
	Out:       out("flash_script_zybo.tcl"),
	Bitstream: Bitstream,
	Target:    "xc7z010_1",
}
