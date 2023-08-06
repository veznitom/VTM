| VýLet Tasks | Status |
| ----------- | :----: |
| M-set       |   O    |
| Zicsr-set   |   X    |
| 64?         |   X    |

| Fixes                                                                               | Status |
| ----------------------------------------------------------------------------------- | :----: |
| Change the intstruction pipeline to properly separate the stages in Dispatch module |   C    |
| Proper cache writes (commit from ROB insted LS)                                     |   X    |
| Res. station queue issue ready                                                      |   X    |
| Bus granted advances res. st. queue                                                 |   X    |
| Move instr. issue, so Dispach does not hold any reg. values until issue             |   C    |
| Create custom queue modules (for rezervation station and for register renaming)     |   X    |
| Modify instruction cache addressing to reflect "best practise"                      |   C    |
| Potentially modify MMU so it uses standart communication protocol                   |   C    |
| Change data cache to accept blocks                                                  |   C    |
| Redesign access to CDB (simple arbiter scales poorly)                               |   X    |

- X = Barely touched
- C = Completed?
- O = Ongoing