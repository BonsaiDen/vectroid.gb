SECTION "AngleTable",ROM0[$2A00]
angle_table:
    ; lookup: sin(l * 256 + r) / cos(l * 256 + 64 + r)
    ; table starts at length 1
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3, -3, -3, -3, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3, -3, -4, -4, -4, -4, -4, -4, -4, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -6, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -4, -4, -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3, -3, -3, -3, -4, -4, -4, -4, -4, -4, -5, -5, -5, -5, -5, -5, -5, -6, -6, -6, -6, -6, -6, -6, -6, -6, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -6, -6, -6, -6, -6, -6, -6, -6, -5, -5, -5, -5, -5, -5, -5, -4, -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -3, -3, -4, -4, -4, -4, -4, -4, -5, -5, -5, -5, -5, -5, -6, -6, -6, -6, -6, -6, -7, -7, -7, -7, -7, -7, -7, -7, -7, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -6, -6, -6, -6, -6, -5, -5, -5, -5, -5, -5, -4, -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, -1, -1, 0, 0, 0, 0
    DB 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 8, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -3, -4, -4, -4, -4, -4, -5, -5, -5, -5, -5, -6, -6, -6, -6, -6, -7, -7, -7, -7, -7, -7, -7, -8, -8, -8, -8, -8, -8, -8, -8, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -9, -8, -8, -8, -8, -8, -8, -8, -8, -7, -7, -7, -7, -7, -7, -7, -6, -6, -6, -6, -6, -5, -5, -5, -5, -5, -4, -4, -4, -4, -4, -3, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, -1, 0, 0, 0, 0
    DB 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 9, 9, 9, 9, 9, 9, 9, 9, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -3, -4, -4, -4, -4, -5, -5, -5, -5, -6, -6, -6, -6, -6, -7, -7, -7, -7, -7, -8, -8, -8, -8, -8, -8, -9, -9, -9, -9, -9, -9, -9, -9, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -10, -9, -9, -9, -9, -9, -9, -9, -9, -8, -8, -8, -8, -8, -8, -7, -7, -7, -7, -7, -6, -6, -6, -6, -6, -5, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, -1, 0, 0, 0
    DB 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 10, 10, 10, 10, 10, 10, 10, 10, 9, 9, 9, 9, 9, 9, 8, 8, 8, 8, 7, 7, 7, 7, 7, 6, 6, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -4, -4, -4, -4, -5, -5, -5, -5, -6, -6, -6, -6, -7, -7, -7, -7, -7, -8, -8, -8, -8, -9, -9, -9, -9, -9, -9, -10, -10, -10, -10, -10, -10, -10, -10, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -11, -10, -10, -10, -10, -10, -10, -10, -10, -9, -9, -9, -9, -9, -9, -8, -8, -8, -8, -7, -7, -7, -7, -7, -6, -6, -6, -6, -5, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, 0, 0, 0
    DB 0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 11, 11, 11, 11, 11, 11, 11, 10, 10, 10, 10, 10, 9, 9, 9, 9, 9, 8, 8, 8, 8, 7, 7, 7, 7, 6, 6, 6, 6, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3, -3, -4, -4, -4, -4, -5, -5, -5, -6, -6, -6, -6, -7, -7, -7, -7, -8, -8, -8, -8, -9, -9, -9, -9, -9, -10, -10, -10, -10, -10, -11, -11, -11, -11, -11, -11, -11, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -12, -11, -11, -11, -11, -11, -11, -11, -10, -10, -10, -10, -10, -9, -9, -9, -9, -9, -8, -8, -8, -8, -7, -7, -7, -7, -6, -6, -6, -6, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -2, -2, -2, -1, -1, -1, 0, 0, 0
    DB 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 12, 12, 12, 12, 12, 12, 12, 11, 11, 11, 11, 11, 10, 10, 10, 10, 10, 9, 9, 9, 9, 8, 8, 8, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3, -3, -4, -4, -4, -4, -5, -5, -5, -6, -6, -6, -7, -7, -7, -7, -8, -8, -8, -9, -9, -9, -9, -10, -10, -10, -10, -10, -11, -11, -11, -11, -11, -12, -12, -12, -12, -12, -12, -12, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -13, -12, -12, -12, -12, -12, -12, -12, -11, -11, -11, -11, -11, -10, -10, -10, -10, -10, -9, -9, -9, -9, -8, -8, -8, -7, -7, -7, -7, -6, -6, -6, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -2, -2, -2, -1, -1, -1, 0, 0
    DB 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 13, 13, 13, 13, 13, 13, 12, 12, 12, 12, 12, 11, 11, 11, 11, 11, 10, 10, 10, 9, 9, 9, 9, 8, 8, 8, 7, 7, 7, 7, 6, 6, 6, 5, 5, 5, 4, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, -1, -1, -1, -2, -2, -2, -3, -3, -3, -4, -4, -5, -5, -5, -6, -6, -6, -7, -7, -7, -7, -8, -8, -8, -9, -9, -9, -9, -10, -10, -10, -11, -11, -11, -11, -11, -12, -12, -12, -12, -12, -13, -13, -13, -13, -13, -13, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -14, -13, -13, -13, -13, -13, -13, -12, -12, -12, -12, -12, -11, -11, -11, -11, -11, -10, -10, -10, -9, -9, -9, -9, -8, -8, -8, -7, -7, -7, -7, -6, -6, -6, -5, -5, -5, -4, -4, -3, -3, -3, -2, -2, -2, -1, -1, -1, 0, 0
    DB 0, 0, 0, 1, 1, 1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 14, 14, 14, 14, 14, 14, 14, 13, 13, 13, 13, 12, 12, 12, 12, 12, 11, 11, 11, 10, 10, 10, 10, 9, 9, 9, 8, 8, 8, 7, 7, 7, 6, 6, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, -1, -1, -1, -2, -2, -3, -3, -3, -4, -4, -4, -5, -5, -6, -6, -6, -7, -7, -7, -8, -8, -8, -9, -9, -9, -10, -10, -10, -10, -11, -11, -11, -12, -12, -12, -12, -12, -13, -13, -13, -13, -14, -14, -14, -14, -14, -14, -14, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -15, -14, -14, -14, -14, -14, -14, -14, -13, -13, -13, -13, -12, -12, -12, -12, -12, -11, -11, -11, -10, -10, -10, -10, -9, -9, -9, -8, -8, -8, -7, -7, -7, -6, -6, -6, -5, -5, -4, -4, -4, -3, -3, -3, -2, -2, -1, -1, -1, 0, 0
    DB 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 15, 15, 15, 15, 15, 15, 14, 14, 14, 14, 14, 13, 13, 13, 13, 12, 12, 12, 11, 11, 11, 11, 10, 10, 10, 9, 9, 9, 8, 8, 7, 7, 7, 6, 6, 6, 5, 5, 4, 4, 4, 3, 3, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, -1, -1, -2, -2, -2, -3, -3, -4, -4, -4, -5, -5, -6, -6, -6, -7, -7, -7, -8, -8, -9, -9, -9, -10, -10, -10, -11, -11, -11, -11, -12, -12, -12, -13, -13, -13, -13, -14, -14, -14, -14, -14, -15, -15, -15, -15, -15, -15, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -16, -15, -15, -15, -15, -15, -15, -14, -14, -14, -14, -14, -13, -13, -13, -13, -12, -12, -12, -11, -11, -11, -11, -10, -10, -10, -9, -9, -9, -8, -8, -7, -7, -7, -6, -6, -6, -5, -5, -4, -4, -4, -3, -3, -2, -2, -2, -1, -1, 0, 0

SECTION "SqrtTable",ROM0
sqrt_table:
    DB 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 2, 2, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 3, 3, 3, 4, 5, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 4, 4, 4, 5, 5, 6, 7, 8, 8, 9, 10, 11, 12, 13, 14, 15, 5, 5, 5, 5, 6, 7, 7, 8, 9, 10, 11, 12, 13, 13, 14, 15, 6, 6, 6, 6, 7, 7, 8, 9, 10, 10, 11, 12, 13, 14, 15, 16, 7, 7, 7, 7, 8, 8, 9, 9, 10, 11, 12, 13, 13, 14, 15, 16, 8, 8, 8, 8, 8, 9, 10, 10, 11, 12, 12, 13, 14, 15, 16, 17, 9, 9, 9, 9, 9, 10, 10, 11, 12, 12, 13, 14, 15, 15, 16, 17, 10, 10, 10, 10, 10, 11, 11, 12, 12, 13, 14, 14, 15, 16, 17, 18, 11, 11, 11, 11, 11, 12, 12, 13, 13, 14, 14, 15, 16, 17, 17, 18, 12, 12, 12, 12, 12, 13, 13, 13, 14, 15, 15, 16, 16, 17, 18, 19, 13, 13, 13, 13, 13, 13, 14, 14, 15, 15, 16, 17, 17, 18, 19, 19, 14, 14, 14, 14, 14, 14, 15, 15, 16, 16, 17, 17, 18, 19, 19, 20, 15, 15, 15, 15, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 21

SECTION "Atan2Table",ROM0
atan2_table:
    DB 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 64, 32, 19, 13, 10, 8, 7, 6, 5, 5, 4, 4, 3, 3, 3, 3, 64, 45, 32, 24, 19, 16, 13, 11, 10, 9, 8, 7, 7, 6, 6, 5, 64, 51, 40, 32, 26, 22, 19, 16, 15, 13, 12, 11, 10, 9, 9, 8, 64, 54, 45, 38, 32, 27, 24, 21, 19, 17, 16, 14, 13, 12, 11, 11, 64, 56, 48, 42, 37, 32, 28, 25, 23, 21, 19, 17, 16, 15, 14, 13, 64, 57, 51, 45, 40, 36, 32, 29, 26, 24, 22, 20, 19, 18, 16, 16, 64, 58, 53, 48, 43, 39, 35, 32, 29, 27, 25, 23, 22, 20, 19, 18, 64, 59, 54, 49, 45, 41, 38, 35, 32, 30, 27, 26, 24, 22, 21, 20, 64, 59, 55, 51, 47, 43, 40, 37, 34, 32, 30, 28, 26, 25, 23, 22, 64, 60, 56, 52, 48, 45, 42, 39, 37, 34, 32, 30, 28, 27, 25, 24, 64, 60, 57, 53, 50, 47, 44, 41, 38, 36, 34, 32, 30, 29, 27, 26, 64, 61, 57, 54, 51, 48, 45, 42, 40, 38, 36, 34, 32, 30, 29, 27, 64, 61, 58, 55, 52, 49, 46, 44, 42, 39, 37, 35, 34, 32, 30, 29, 64, 61, 58, 55, 53, 50, 48, 45, 43, 41, 39, 37, 35, 34, 32, 31, 64, 61, 59, 56, 53, 51, 48, 46, 44, 42, 40, 38, 37, 35, 33, 32

; Pixel Mask Lookup Table
SECTION "PixelBitTable",ROM0
bit_table:
    DB %1000_0000
    DB %0100_0000
    DB %0010_0000
    DB %0001_0000
    DB %0000_1000
    DB %0000_0100
    DB %0000_0010
    DB %0000_0001

SECTION "TileIndexTable",ROM0
tile_index_table:
    ; i = x + y * 4 + spriteSize * 16

    ; 0  .  .  .
    ; .  .  .  .
    ; .  .  .  .

    ; 0  2  .  .
    ; 1  3  .  .
    ; .  .  .  .

    ; 0  2  4  .
    ; 1  3  5  .
    ; 6  8 10  .
    ; .  .  .  .

    ; 0  2  4  6
    ; 1  3  5  7
    ; 8 10 12 14
    ; 9 11 13 15
    DB 0 * 16,0 * 16,0 * 16,0 * 16, 0 * 16,0 * 16,0 * 16,0 * 16, 0 * 16, 0 * 16,  0 * 16, 0 * 16, 0 * 16, 0 * 16, 0 * 16, 0 * 16
    DB 0 * 16,2 * 16,0 * 16,0 * 16, 1 * 16,3 * 16,0 * 16,0 * 16, 0 * 16, 0 * 16,  0 * 16, 0 * 16, 0 * 16, 0 * 16, 0 * 16, 0 * 16
    DB 0 * 16,2 * 16,4 * 16,0 * 16, 1 * 16,3 * 16,5 * 16,0 * 16, 6 * 16, 8 * 16, 10 * 16, 0 * 16, 0 * 16, 0 * 16, 0 * 16, 0 * 16
    DB 0 * 16,2 * 16,4 * 16,6 * 16, 1 * 16,3 * 16,5 * 16,7 * 16, 8 * 16,10 * 16, 12 * 16,14 * 16, 9 * 16,11 * 16,13 * 16,15 * 16

SECTION "UITileData",ROM0
DataUITiles:
    INCBIN  "/data/bin/ui.bg.bin"


SECTION "UITextMap",ROM0
text_table:
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $00, $11, $12, $13, $14, $15, $16, $00, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F
    DB $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $20
    DB $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30
    DB $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40
    DB $17, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50
    DB $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $00
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ;DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ;DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ;DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ;DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    ;DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
