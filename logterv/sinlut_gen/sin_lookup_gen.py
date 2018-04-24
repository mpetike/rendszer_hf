import math
import matplotlib.pyplot as plt

BIT_RES = 23
LUT_SIZE = 10
SIN_QUAD_NUM = 1

# Calculations and sin wave generation
SAMPLE_CNT = 2**10

RAD_STEP = ((math.pi / 2) / SAMPLE_CNT) * SIN_QUAD_NUM


sin_lut = []

for i in range(0,SAMPLE_CNT):
    sin_lut.append((2 ** BIT_RES) * math.sin(i * RAD_STEP))

print("Generated plot :")
plt.plot(sin_lut)
plt.grid()
plt.show()

# Convert to fixed point
sin_lut_int = []

for i in range(0,SAMPLE_CNT):
    sin_lut_int.append(int(round(sin_lut[i],0)))

# Print to file
output_txt = open("Sin_lookup_verilog.txt","w")

output_buff = ""

for i in range(0,SAMPLE_CNT):
    output_buff = "10'h" + format(i,"03x") + " : sin_out = 23'h" + format(sin_lut_int[i],"06x") + ";\n"
    output_txt.write(output_buff)

output_txt.close()
