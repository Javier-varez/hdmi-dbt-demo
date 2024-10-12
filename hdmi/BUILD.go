package hdmi

import (
	"dbt-rules/RULES/hdl"
)

var HdmiLib = hdl.Library{
	Srcs: ins(
		"hdmi.sv",
		"tmds_encoder.sv",
		"serializer.sv",
	),
}
