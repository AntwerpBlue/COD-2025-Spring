# Complete Pipelined Processor

---

In this Lab, we solve the Hazard promblems of the pipelined processor. There are three types of hazards:
* Structural Hazard: When the instruction and data share a common memory, instruction fetching and data writing will conflict. In our processor, we use Havard Structure, which means the instruction and data are stored in different memory. So we don't have this kind of hazard.
* Data Hazard: When the instruction depends on the data that has not been written back into the register, it will cause a data hazard. In our processor, we use register forwarding to solve this problem. While if the instruction is a load instruction (Load-Use Hazard), we use a bubble to solve this problem, that is, insert a nop instruction.
* Control Hazard: When the instruction is a branch instruction, it will cause a control hazard. In our processor, we use two bubbles to solve this problem.