
#! These are for dbht's
W = [
    [
        1.20202093e-01,
        4.02042317e-02,
        1.28496057e-01,
        6.95742525e-02,
        1.24004115e-02,
        8.16266500e-02,
        3.66733582e-03,
        3.10374239e-03,
        1.36028644e-01,
        6.69478092e-04,
    ],
    [
        9.51005747e-03,
        2.23513373e-01,
        4.87351570e-04,
        3.65340977e-03,
        1.41932587e-02,
        2.10774862e-02,
        1.12624033e-01,
        7.02997873e-03,
        1.46566243e-02,
        4.15707468e-03,
    ],
    [
        9.83741613e-02,
        8.04663293e-02,
        2.68705463e-02,
        9.46554370e-04,
        1.46382397e-01,
        3.19545042e-05,
        5.05235646e-02,
        6.63930317e-02,
        3.45070917e-02,
        1.33121245e-01,
    ],
    [
        6.88385466e-03,
        6.79838807e-02,
        4.59351430e-05,
        1.57147668e-01,
        3.40612095e-02,
        2.72236053e-02,
        1.24246216e-01,
        2.00923127e-01,
        4.74999610e-03,
        1.03607924e-02,
    ],
    [
        3.00193251e-02,
        9.12872065e-05,
        3.29370106e-01,
        7.47322393e-03,
        7.89953874e-02,
        1.61193847e-02,
        1.40559094e-02,
        5.81328574e-02,
        4.33815180e-04,
        5.15883246e-03,
    ],
    [
        6.96948397e-04,
        7.87561342e-03,
        3.39337798e-03,
        4.63980910e-03,
        7.75965229e-03,
        1.50668358e-03,
        2.62109756e-04,
        1.48861774e-01,
        2.21126272e-04,
        1.19464112e-02,
    ],
    [
        3.84706737e-01,
        1.41334789e-01,
        7.86871719e-03,
        6.22137060e-03,
        1.51409198e-01,
        9.78762574e-02,
        7.79573407e-02,
        3.18530695e-01,
        1.09014051e-01,
        1.34124473e-03,
    ],
    [
        5.02069695e-02,
        8.71951129e-02,
        3.97871011e-02,
        1.33532640e-03,
        9.91407924e-03,
        3.73728707e-01,
        6.41149949e-02,
        5.78278006e-02,
        8.25357521e-02,
        5.62590586e-03,
    ],
    [
        3.00568611e-02,
        1.20943354e-01,
        5.60817549e-03,
        1.01724319e-01,
        6.02089174e-02,
        4.72095538e-03,
        2.80662756e-02,
        7.28021118e-03,
        3.44928337e-03,
        2.94055400e-02,
    ],
    [
        2.04704395e-01,
        2.16533115e-02,
        1.31214342e-01,
        1.47466120e-02,
        4.13595533e-06,
        7.11734929e-03,
        1.17860351e-02,
        2.20397286e-02,
        7.36285939e-03,
        5.08474637e-02,
    ],
]
W = transpose(hcat(W...))

d = [
    [
        0.0,
        0.04020423,
        0.04289084,
        0.00443907,
        0.01240041,
        0.00778683,
        0.00366734,
        0.00310374,
        0.00803234,
        0.00066948,
    ],
    [
        0.00951006,
        0.0,
        0.04681708,
        0.00836531,
        0.01694406,
        0.01729688,
        0.01317739,
        0.00702998,
        0.0131153,
        0.01017954,
    ],
    [
        0.07461221,
        0.11481644,
        0.0,
        0.06772836,
        0.07630711,
        0.07913629,
        0.07827955,
        0.06639303,
        0.07247835,
        0.07201894,
    ],
    [
        0.00688385,
        0.04708809,
        0.0497747,
        0.0,
        0.01928427,
        0.01467068,
        0.01055119,
        0.0099876,
        0.00475,
        0.00755333,
    ],
    [
        0.03001933,
        0.07022356,
        0.07291017,
        0.03445839,
        0.0,
        0.03780615,
        0.03368666,
        0.03312307,
        0.03805166,
        0.0306888,
    ],
    [
        0.01152366,
        0.0517279,
        0.05441451,
        0.00463981,
        0.02392408,
        0.0,
        0.015191,
        0.01462741,
        0.00938981,
        0.01194641,
    ],
    [
        0.01310523,
        0.05330946,
        0.05599607,
        0.00622137,
        0.02550564,
        0.02089205,
        0.0,
        0.01620897,
        0.01097137,
        0.0137747,
    ],
    [
        0.00821918,
        0.04842341,
        0.0397871,
        0.00133533,
        0.00991408,
        0.01274326,
        0.01188652,
        0.0,
        0.00608532,
        0.00562591,
    ],
    [
        0.03005686,
        0.07026109,
        0.0729477,
        0.03449593,
        0.04245727,
        0.03652289,
        0.0337242,
        0.0331606,
        0.0,
        0.02940554,
    ],
    [
        0.01864101,
        0.05884524,
        0.06153186,
        0.01175716,
        0.03104142,
        0.00711735,
        0.02230835,
        0.02174476,
        0.00736286,
        0.0,
    ],
]

d = transpose(hcat(d...))

b = [
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
]

b = transpose(hcat(b...))
