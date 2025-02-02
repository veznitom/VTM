MEMORY
{
    ram     : ORIGIN = 0x0, LENGTH = 0x10000
}

ENTRY(_start)
SECTIONS
{
    . = 0x0;
    .text : 
    {
      . = ALIGN(4);
      *(.text.init)
    }
}