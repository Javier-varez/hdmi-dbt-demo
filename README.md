# HDMI transmitter for FPGA

Implements an HDMI transmitter for 7-series Xilinx FPGAs. Displays a test pattern.
The `hdmi` component can be parameterized to support multiple display resolutions
and refresh rates.

The demonstration uses a Digilent Zybo board and a resolution of 1280 x 720 @ 60 fps.

## Building

- Install `dbt` using `go`:

```sh
go install github.com/daedaleanai/dbt/v3@latest
```

- Ensure that vivado is intalled and available in your PATH environment variable.
- Synchronize dependencies with:

```sh
dbt sync
```

- Run the synthesis, place, route and bitstream generation with:

```sh
dbt build //hdmi-dbt-demo/demo/Zybo
```

- Find the bitstream in `BUILD/OUTPUT/ZyboHdmiDemo/top.runs/impl_1/top.bit`
