package demo

import (
	"dbt-rules/RULES/hdl"

	"hdmi-dbt-demo/hdmi"
)

var Zybo = hdl.Fpga{
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
