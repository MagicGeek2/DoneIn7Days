[TOC]

# 计算机组成原理课程设计报告

## 硬件环境描述

## 题目分析

## 指令级架构

### 基本指令集 (12)

<table>
   <tr>
      <td>名称</td>
      <td>功能</td>
      <td>IR7 IR6 IR5 IR4</td>
      <td>IR3 IR2</td>
      <td>IR1 IR0</td>
   </tr>
   <tr>
      <td>ADD Rd, Rs</td>
      <td>Rd<-Rd+Rs</td>
      <td>0001</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>SUB Rd, Rs</td>
      <td>Rd<-Rd-Rs</td>
      <td>0010</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>AND Rd, Rs</td>
      <td>Rd<-Rd and Rs</td>
      <td>0011</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>INC Rd</td>
      <td>Rd<-Rd+1</td>
      <td>0100</td>
      <td>Rd</td>
      <td>XX</td>
   </tr>
   <tr>
      <td>LD Rd, [Rs]</td>
      <td>Rd<-[Rs]</td>
      <td>0101</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>ST Rd, [Rs]</td>
      <td>[Rs]<-Rd</td>
      <td>0110</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>JC offset</td>
      <td>若C=1, 则PC<-@+offset</td>
      <td>0111</td>
      <td colspan="2">offset</td>
   </tr>
   <tr>
      <td>JZ offset</td>
      <td>若Z=1, 则PC<-@+offset</td>
      <td>1000</td>
      <td colspan="2">offset</td>
   </tr>
   <tr>
      <td>JMP Rd</td>
      <td>PC<-Rd</td>
      <td>1001</td>
      <td>Rd</td>
      <td>XX</td>
   </tr>
   <tr>
      <td>OUT Rs</td>
      <td>DBUS<-Rs</td>
      <td>1010</td>
      <td>XX</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>STP</td>
      <td>暂停运行程序</td>
      <td>1111</td>
      <td>XX</td>
      <td>XX</td>
   </tr>
    <tr>
      <td>NOP</td>
      <td>什么也不做</td>
      <td>0000</td>
      <td>XX</td>
      <td>XX</td>
   </tr>
</table>

基本指令集满足了课程设计的指令集要求。

1. 由于STP指令的特殊性，我们修改了**STP**指令的代码，由原来的**1110**修改成**1111**，使其更具有辨识性。
2. 指令集要求中隐含了**NOP**指令，这里我们将NOP指令显式地列出，代码为**0000**。

### 扩展指令集 (4)     （提出更有创意的附加指令）

<table>
   <tr>
      <td>名称</td>
      <td>功能</td>
      <td>IR7 IR6 IR5 IR4</td>
      <td>IR3 IR2</td>
      <td>IR1 IR0</td>
   </tr>
   <tr>
      <td>NOT Rd</td>
      <td>Rd<-not Rd</td>
      <td>1011</td>
      <td>Rd</td>
      <td>XX</td>
   </tr>
   <tr>
      <td>XOR Rd, Rs</td>
      <td>Rd<-Rd xor Rs</td>
      <td>1100</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>OR Rd, Rs</td>
      <td>Rd<-Rd or Rs</td>
      <td>1101</td>
      <td>Rd</td>
      <td>Rs</td>
   </tr>
   <tr>
      <td>DEC Rd</td>
      <td>Rd<-Rd-1</td>
      <td>1110</td>
      <td>Rd</td>
      <td>XX</td>
   </tr>
</table>

我们充分利用了4位的指令代码，添加了4条扩展指令：**NOT, XOR, OR, DEC.** 

## 非流水线硬布线控制器详解

### 指令译码表(非流水线版本)

|        | RUN 000     | WMEM 001    | RMEM 010    | RREG 011  | WREG 100             |
| ------ | ----------- | ----------- | ----------- | --------- | -------------------- |
| SBUS   | $!ST_0*W_1$ | $W_1$       | $!ST_0*W_1$ |           | $W_1+W_2$            |
| SELCTL |             | $W_1$       | $W_1$       | $W_1+W_2$ | $W_1+W_2$            |
| SEL3   |             |             |             | $W_2$     | $ST_0*(W_1+W_2)$     |
| SEL2   |             |             |             |           | $W_2$                |
| SEL1   |             |             |             | $W_2$     | $ST_0*W_2+!ST_0*W_1$ |
| SEL0   |             |             |             | $W_1+W_2$ | $W_1$                |
| DRW    |             |             |             |           | $W_1+W_2$            |
| SHORT  | $!ST_0*W_1$ | $W_1$       | $W_1$       |           |                      |
| STOP   | $!ST_0*W_1$ | $W_1$       | $W_1$       | $W_1+W_2$ | $W_1+W_2$            |
| LAR    |             | $!ST_0*W_1$ | $!ST_0*W_1$ |           |                      |
| SST0   | $!ST_0*W_1$ | $!ST_0*W_1$ | $!ST_0*W_1$ |           | $!ST_0*W_2$          |
| LPC    | $!ST_0*W_1$ |             |             |           |                      |
| MEMW   |             | $ST_0*W_1$  |             |           |                      |
| ARINC  |             | $ST_0*W_1$  | $ST_0*W_1$  |           |                      |
| MBUS   |             |             | $ST_0*W_1$  |           |                      |



|       | ADD 0001 | SUB 0010 | AND 0011 | XOR 1100 | OR 1101 |
| ----- | -------- | -------- | -------- | -------- | ------- |
| LIR   | $W_1$    | $W_1$    | $W_1$    | $W_1$    | $W_1$   |
| PCINC | $W_1$    | $W_1$    | $W_1$    | $W_1$    | $W_1$   |
| M     |          |          | $W_2$    | $W_2$    | $W_2$   |
| CIN   | $W_2$    |          |          |          |         |
| S3    | $W_2$    |          | $W_2$    |          | $W_2$   |
| S2    |          | $W_2$    |          | $W_2$    | $W_2$   |
| S1    |          | $W_2$    | $W_2$    | $W_2$    | $W_2$   |
| S0    | $W_2$    |          | $W_2$    |          |         |
| ABUS  | $W_2$    | $W_2$    | $W_2$    | $W_2$    | $W_2$   |
| DRW   | $W_2$    | $W_2$    | $W_2$    | $W_2$    | $W_2$   |
| LDZ   | $W_2$    | $W_2$    | $W_2$    | $W_2$    | $W_2$   |
| LDC   | $W_2$    | $W_2$    |          |          |         |
| LONG  |          |          |          |          |         |
| LAR   |          |          |          |          |         |
| MBUS  |          |          |          |          |         |
| MEMW  |          |          |          |          |         |
| PCADD |          |          |          |          |         |
| LPC   |          |          |          |          |         |
| STOP  |          |          |          |          |         |



|       | INC 0100 | DEC 1110 | LD 0101 | ST 0110   | NOT 1011 |
| ----- | -------- | -------- | ------- | --------- | -------- |
| LIR   | $W_1$    | $W_1$    | $W_1$   | $W_1$     | $W_1$    |
| PCINC | $W_1$    | $W_1$    | $W_1$   | $W_1$     | $W_1$    |
| M     |          |          | $W_2$   | $W_2+W_3$ | $W_2$    |
| CIN   |          | $W_2$    |         |           |          |
| S3    |          | $W_2$    | $W_2$   | $W_2+W_3$ |          |
| S2    |          | $W_2$    |         | $W_2$     |          |
| S1    |          | $W_2$    | $W_2$   | $W_2+W_3$ |          |
| S0    |          | $W_2$    |         | $W_2$     |          |
| ABUS  | $W_2$    | $W_2$    | $W_2$   | $W_2+W_3$ | $W_2$    |
| DRW   | $W_2$    | $W_2$    | $W_3$   |           | $W_2$    |
| LDZ   | $W_2$    | $W_2$    |         |           | $W_2$    |
| LDC   | $W_2$    | $W_2$    |         |           |          |
| LONG  |          |          | $W_2$   | $W_2$     |          |
| LAR   |          |          | $W_2$   | $W_2$     |          |
| MBUS  |          |          | $W_3$   |           |          |
| MEMW  |          |          |         | $W_3$     |          |
| PCADD |          |          |         |           |          |
| LPC   |          |          |         |           |          |
| STOP  |          |          |         |           |          |



|       | JC 0111 | JZ 1000 | JMP 1001 | OUT 1010 | STP 1111 | NOP 0000 |
| ----- | ------- | ------- | -------- | -------- | -------- | -------- |
| LIR   | $W_1$   | $W_1$   | $W_1$    | $W_1$    | $W_1$    | $W_1$    |
| PCINC | $W_1$   | $W_1$   | $W_1$    | $W_1$    | $W_1$    | $W_1$    |
| M     |         |         | $W_2$    | $W_2$    |          |          |
| CIN   |         |         |          |          |          |          |
| S3    |         |         | $W_2$    | $W_2$    |          |          |
| S2    |         |         | $W_2$    |          |          |          |
| S1    |         |         | $W_2$    | $W_2$    |          |          |
| S0    |         |         | $W_2$    |          |          |          |
| ABUS  |         |         | $W_2$    | $W_2$    |          |          |
| DRW   |         |         |          |          |          |          |
| LDZ   |         |         |          |          |          |          |
| LDC   |         |         |          |          |          |          |
| LONG  |         |         |          |          |          |          |
| LAR   |         |         |          |          |          |          |
| MBUS  |         |         |          |          |          |          |
| MEMW  |         |         |          |          |          |          |
| PCADD | $C*W_2$ | $Z*W_2$ |          |          |          |          |
| LPC   |         |         | $W_2$    |          |          |          |
| STOP  |         |         |          |          | $W_2$    |          |





## 流水线硬布线控制器详解

重点放在流水线部分的实现方式上，其余部分和非流水线版本基本没有区别

## 调试，问题与改进

### st0是什么？ 

st0是一个特殊的信号，用来区分阶段。

1. 写寄存器的时候，用st0将四个寄存器的写入分成两条指令。st0=0时，写入寄存器R0, R1;  st0=1时，写入寄存器R2, R3. 
2. 读写存储器和运行程序时，都需要st0来进行一些前置准备。st0=0时，程序打开SBUS, 写AR或者PC. st0=1的时候，连续读/写内存或者运行存储在内存中的指令。

st0是一个内部信号，不作为输入或者输出出现在芯片的引脚上。

收到clr指令的时候，st0被设置成0。

## 工程进度日志

### 暑假

### Day1



## 小组成员，分工及心得体会

### 小组成员名单

| 姓名   | 学号       | 班级       |
| ------ | ---------- | ---------- |
| 金浩男 | 2018211121 | 2018211318 |
| 苟志斌 | 2018213292 | 2018211318 |
| 周鹏飞 | 2018211123 | 2018211318 |






