"""10-Hz-Sinus mit Amplitude 5: 80 Samples und ihre DFT."""

from pathlib import Path

import numpy as np
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def compute_dft(x):
    N = x.size
    n = np.arange(N)
    k = n.reshape(N, 1)
    # X[k] = Summe über n von x[n] * exp(-j * 2π * k * n / N)
    return np.exp(-2j * np.pi * k * n / N) @ x


def main():
    amplitude = 5
    signal_freq = 10      # Hz
    sampling_rate = 80    # Hz: 80 Samples pro Sekunde
    N = 80               # Anzahl der Samples, unabhängig von der Abtastrate

    T_s = 1 / sampling_rate
    T = N * T_s          # Blockdauer: 1 Sekunde
    delta_f = 1 / T      # DFT-Frequenzabstand: 1 Hz

    n = np.arange(N)     # 0 bis 79; der Endpunkt bei t = 1 s fehlt bewusst
    t = n * T_s
    x = amplitude * np.sin(2 * np.pi * signal_freq * t)
    X_k = compute_dft(x)

    # Vollständige DFT in ihrer ursprünglichen Reihenfolge: k = 0 bis 79.
    freq = n * delta_f
    # Die zweite Hälfte entspricht den negativen Frequenzen.
    signed_freq = np.fft.fftfreq(N, d=T_s)

    # Einseitiges Amplitudenspektrum: DC und Nyquist nicht verdoppeln.
    f_oneside = freq[:N // 2 + 1]
    amplitudes = np.abs(X_k[:N // 2 + 1]) / N
    amplitudes[1:-1] *= 2

    print(f"N = {N}, fs = {sampling_rate} Hz, Ts = {T_s:g} s")
    print(f"T = {T:g} s, Δf = {delta_f:g} Hz")
    print("8 Samples pro Periode; 10 Perioden im Sampleblock.\n")
    print("Alle DFT-Koeffizienten (ohne Normierung):")
    for k, coefficient in enumerate(X_k):
        # Nur für die Textausgabe winzige Rundungsreste als null anzeigen.
        real = 0.0 if abs(coefficient.real) < 1e-10 else coefficient.real
        imag = 0.0 if abs(coefficient.imag) < 1e-10 else coefficient.imag
        print(f"X[{k:2d}] = {real:10.6f}{imag:+11.6f}j"
              f"    f = {signed_freq[k]:+g} Hz")

    fig, axes = plt.subplots(3, 1, figsize=(12, 11), layout="constrained")

    # Die feine Kurve dient als Referenz; nur die 80 Punkte gehen in die DFT ein.
    t_fine = np.linspace(0, T, 2001)
    axes[0].plot(t_fine, amplitude * np.sin(2 * np.pi * signal_freq * t_fine),
                 color="0.65", label="Sinus als Referenz")
    axes[0].plot(t, x, "o", markersize=4, label="80 Abtastpunkte")
    axes[0].set(title="x[n] = 5 sin(2π · 10 · n/80)",
                xlabel="Zeit (s)", ylabel="Signalwert", xlim=(0, T))
    axes[0].legend(loc="upper right")

    axes[1].stem(freq, np.abs(X_k), basefmt=" ")
    axes[1].set(title="Vollständige DFT: alle 80 Koeffizienten, ohne Normierung",
                xlabel="Frequenz k · fs/N (Hz), periodisch mit fs = 80 Hz",
                ylabel="|X[k]|", ylim=(0, 250))
    axes[1].annotate("X[10] = −200j\n+10 Hz", (10, 200),
                     xytext=(10, 12), textcoords="offset points")
    axes[1].annotate("X[70] = +200j\n70 Hz entspricht −10 Hz", (70, 200),
                     xytext=(-10, 12), textcoords="offset points", ha="right")

    axes[2].stem(f_oneside, amplitudes, basefmt=" ")
    axes[2].set(title="Einseitiges Amplitudenspektrum: 2|X[k]|/N (außer DC/Nyquist)",
                xlabel="Frequenz (Hz)", ylabel="Sinusamplitude", ylim=(0, 6))
    axes[2].annotate("10 Hz: Amplitude 5", (10, 5),
                     xytext=(12, 12), textcoords="offset points")
    for ax in axes:
        ax.grid(True, alpha=0.3)

    output_path = Path(__file__).with_name("sinus_10hz_spektrum.png")
    fig.savefig(output_path, dpi=150)
    plt.close(fig)
    print(f"\nSpektrum gespeichert: {output_path}")


if __name__ == "__main__":
    main()
