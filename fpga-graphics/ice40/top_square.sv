// Project F: Top Square (iCEBreaker with 12-bit DVI Pmod)
// (C)2020 Will Green, Open Source Hardware released under the MIT License
// Learn more at https://projectf.io/posts/fpga-graphics/

`default_nettype none

module top_square (
    input  wire logic clk_12m,      // 12 MHz clock
    input  wire logic btn_rst,      // reset button (active low)
    output      logic dvi_clk,      // DVI pixel clock
    output      logic dvi_hsync,    // DVI horizontal sync
    output      logic dvi_vsync,    // DVI vertical sync
    output      logic dvi_de,       // DVI data enable
    output      logic dvi_r0, dvi_r1, dvi_r2, dvi_r3,   // 4-bit DVI red
    output      logic dvi_g0, dvi_g1, dvi_g2, dvi_g3,   // 4-bit DVI green
    output      logic dvi_b0, dvi_b1, dvi_b2, dvi_b3    // 4-bit DVI blue
    );

    // generate pixel clock
    logic clk_pix;
    logic clk_locked;
    clock_gen clock_640x480 (
       .clk(clk_12m),
       .rst(btn_rst),  // reset button is active low
       .clk_pix,
       .clk_locked
    );

    // display timings
    logic [9:0] sx, sy;
    logic de;
    display_timings timings_640x480 (
        .clk_pix,
        .rst(!clk_locked),  // wait for clock lock
        .sx,
        .sy,
        .hsync(dvi_hsync),
        .vsync(dvi_vsync),
        .de
    );

    // 32 x 32 pixel square
    logic q_draw;
    always_comb q_draw = (sx < 32 && sy < 32) ? 1 : 0;

    // DVI output
    always_comb begin
        dvi_clk = clk_pix;
        dvi_de  = de;
        {dvi_r3, dvi_r2, dvi_r1, dvi_r0} = !de ? 4'h0 : (q_draw ? 4'hD : 4'h3);
        {dvi_g3, dvi_g2, dvi_g1, dvi_g0} = !de ? 4'h0 : (q_draw ? 4'hA : 4'h7);
        {dvi_b3, dvi_b2, dvi_b1, dvi_b0} = !de ? 4'h0 : (q_draw ? 4'h3 : 4'hD);
    end
endmodule
