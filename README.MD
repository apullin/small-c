# small-c compiler

This repo contains the "small-c" compiler, as-published in Volume 5 of "Dr. Dobb's Journal". Authorship is attributed to Ron Cain.

The original PDF is avaialble here: https://archive.org/details/dr_dobbs_journal_vol_05_201803

with the pertinent content starting on page 190 (of the PDF), or document-numbered page 176.

## Status

This is an exploratory and incomplete project!

# Goals

I just wanted to see if I could get this up and running.

Milestones:
[ ] port it to modern C, something that gcc/clang will accept
[ ] Get it working & running as an 8080 small-c cross-compiler
[ ] produce some working 8080 asm code that can be ingested by `naken_asm` or similar assembler
[ ] run it on a JS 8080 emulator
[ ] run it on a synthesized 8080 core with `iveriog` or `veriltor`
[ ] run it on FPGA

Branches:
[ ] can the small-c compiler be modified to be self-hosting?
[ ] retarget the "backend" to TMS9900?
[ ] produce code that can be ingested by TI Editor/Assembler?
[ ] produce a working self-hosted small-c compiler program for TI-99/4a?

### Dreams

(should "dreams" be a subsection of "Goals"? hmm)
After attending the Vintage Computer Festival at the Computer History Museum this year (2025), I've become interested in old computer tech. It's so interested because it's still _mostly_ transparent - address and data busses clearly avaialble, little to no abstrations, and no resources to have any abstractions.

As I am _supposedly_ a firmware engineer by trade, and I find that heavy overlaps with what is now considered embedded engineering. But I've always had C. As I understand it, back in the day, the sheer difficulty of producing complex software in asm was the way of life but the arrival of higher level languages cause a Cambraian Explosion in technology, complexity, and productivity.

So, the dream-story I have in my head is something like:
- a hypothetical 1980's guy owns a Commodore64 or a TI-99/4a
- they see Ron Cain's "small-c" code in the journal
- the code is transcribed and ported to that CPU asm backend
- using a professional C compiler

The even wilder fantasy is a true bootstrap:
- "hand-compile" the code to ASM for TI-99/4a (w/ 32K RAM expansion)
- assemble with Editor/Assembler
- now you have a working small-c compiler
- modify it to be self-hosted, now you have a self-hosted small-c compiler
- add features until it is a "big C" compiler