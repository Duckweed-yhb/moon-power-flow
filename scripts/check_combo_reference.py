"""Independent reference for case_tx_oltc_open using nodal KCL and Newton steps.

Run with Python 3 (standard library). Branch impedances are diagonal, so each
phase is solved in its own reference frame with slack voltage 1+0j. The open
terminal on phase b is removed from the nodal equations. Voltages are in pu.
"""


LINE_Z = 0.01 + 0.02j
LEAKAGE_Z = 0.02 + 0.04j
LOAD3 = (0.06 + 0.02j, 0.04 + 0.015j, 0.05 + 0.015j)
LOAD4 = (0.05 + 0.015j, 0.03 + 0.01j, 0.04 + 0.012j)


def solve_linear(matrix, rhs):
    """Small real linear system with partial pivoting."""
    rows = [row + [value] for row, value in zip(matrix, rhs)]
    n = len(rhs)
    for col in range(n):
        pivot = max(range(col, n), key=lambda i: abs(rows[i][col]))
        rows[col], rows[pivot] = rows[pivot], rows[col]
        if abs(rows[col][col]) < 1e-14:
            raise ValueError("singular Newton system")
        for i in range(col + 1, n):
            factor = rows[i][col] / rows[col][col]
            for j in range(col + 1, n + 1):
                rows[i][j] -= factor * rows[col][j]
    x = [0.0] * n
    for i in reversed(range(n)):
        x[i] = (rows[i][-1] - sum(rows[i][j] * x[j] for j in range(i + 1, n))) / rows[i][i]
    return x


def phase_voltages(tap, phase):
    k = 1.0 + 0.0125 * tap
    branch_closed = phase != 1
    n = 3 if branch_closed else 2
    voltage = [1.0 + 0j] * n

    def residual(v):
        # Unknown nodes are 2, 3, and (when connected) 4. At node 2 the
        # transformer primary draws k times its secondary current.
        i23 = (k * v[0] - v[1]) / LEAKAGE_Z
        i34 = (v[1] - v[2]) / LINE_Z if branch_closed else 0j
        current = [(v[0] - 1) / LINE_Z + k * i23,
                   -i23 + i34 + (LOAD3[phase] / v[1]).conjugate()]
        if branch_closed:
            current.append(-i34 + (LOAD4[phase] / v[2]).conjugate())
        return [x for c in current for x in (c.real, c.imag)]

    for _ in range(12):
        f = residual(voltage)
        if max(map(abs, f)) < 1e-12:
            return voltage[1], voltage[2] if branch_closed else 0j
        columns = []
        for j in range(2 * n):
            trial = voltage.copy()
            h = 1e-6
            trial[j // 2] += h if j % 2 == 0 else h * 1j
            columns.append([(a - b) / h for a, b in zip(residual(trial), f)])
        step = solve_linear([list(row) for row in zip(*columns)], [-x for x in f])
        voltage = [v + complex(step[2*i], step[2*i+1]) for i, v in enumerate(voltage)]
    raise RuntimeError(f"KCL did not converge at tap {tap}, phase {phase}")


if __name__ == "__main__":
    print("tap  |V3a|  |V3b|  |V3c|  |V4a|  |V4b|  |V4c|")
    for tap in (0, -1, -2, 1):
        voltages = [phase_voltages(tap, ph) for ph in range(3)]
        print(tap, *(f"{abs(v):.12f}" for bus in zip(*voltages) for v in bus))
