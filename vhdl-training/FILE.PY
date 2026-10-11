import numpy as np

fmt = "{:04X}"

def generateLUT(num_points, max_amplitude):

    if not 0 < max_amplitude <= 32767  or isinstance(max_amplitude, str) or isinstance(num_points, str) or num_points <= 0:
        raise ValueError("Number of points must be a positive integer.")

    t = np.linspace(0, 2 * np.pi, num_points, endpoint=False)
    A = max_amplitude
    lut = A*np.sin(t)

    with open("sinus_lut.coe", "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, val in enumerate(lut):
            val = round(val)
            if val < 0:
                val = val + (1 << 16)
                f.write(str(fmt.format(val)))
            else:
                f.write(str(fmt.format(val)))
            if i != num_points - 1:
                f.write(",\n")
            else:
                f.write(";\n")



if __name__ == "__main__":
    generateLUT(1024, 32767)
