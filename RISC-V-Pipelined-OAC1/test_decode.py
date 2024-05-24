import ass2machine

result = ass2machine.ass2bin("some_stuff: beq x4, x0, around", {'around': 36}, 76)
print(f"Binary:\n {result} & size: {len(result)}")
gab = bin(int('02728863', 16))[2:].zfill(32)
print(f"Gabarito:\n {gab} & int: {int(gab[:20], 2)}")
result_dec = int(result, 2)
result_hex = hexadecimal_string = format(result_dec, f'0{8}X')
print(f"Hexa: {result_hex}")
