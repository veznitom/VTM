.section ".text.init"
  .globl   _start

_start:
  lw x0, 0x0(x0)
  lw x1, 0x4(x0)
  lw x2, 0x8(x0)
  lw x3, 0xc(x0)
  lw x4, 0x10(x0)
  lw x5, 0x14(x0)
  lw x6, 0x18(x0)
  lw x7, 0x1c(x0)
  lw x8, 0x20(x0)
  lw x9, 0x24(x0)

store:
  li x10, 0x400
  lw x11, 0(x10)
  li x11, 0x69
  sw x11, 0(x10)
  lw x11, 0(x10)

end_loop:
  j        end_loop