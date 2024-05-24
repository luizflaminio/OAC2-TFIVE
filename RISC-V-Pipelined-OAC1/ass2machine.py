# Transforms assembly in a txt to machine code
# for RISC-V 32I, considering only base instructions.

MEM_SIZE = 128
ZERO_LINE = "00000000"

R_INSTRUCTIONS = {
    "ADD": {"OP": "0110011", "F3": "000", "F7": "0000000"},
    "SUB": {"OP": "0110011", "F3": "000", "F7": "0100000"},
    "XOR": {"OP": "0110011", "F3": "100", "F7": "0000000"},
    "OR": {"OP": "0110011", "F3": "110", "F7": "0000000"},
    "AND": {"OP": "0110011", "F3": "111", "F7": "0000000"},
    "SLL": {"OP": "0110011", "F3": "001", "F7": "0000000"},
    "SRL": {"OP": "0110011", "F3": "101", "F7": "0000000"},
    "SRA": {"OP": "0110011", "F3": "101", "F7": "0100000"},
    "SLT": {"OP": "0110011", "F3": "010", "F7": "0000000"},
    "SLTU": {"OP": "0110011", "F3": "011", "F7": "0000000"},
}

I_INSTRUCTIONS = {
    "ADDI": {"OP": "0010011", "F3": "000"},
    "XORI": {"OP": "0010011", "F3": "100"},
    "ORI": {"OP": "0010011", "F3": "110"},
    "ANDI": {"OP": "0010011", "F3": "111"},
    "SLLI": {"OP": "0010011", "F3": "001"},
    "SRLI": {"OP": "0010011", "F3": "101"},
    "SRAI": {"OP": "0010011", "F3": "101"},
    "SLTI": {"OP": "0010011", "F3": "010"},
    "SLTIU": {"OP": "0010011", "F3": "011"},
}

LW_INSTRUCTIONS = {
    "LB": {"OP": "0000011", "F3": "000"},
    "LH": {"OP": "0000011", "F3": "001"},
    "LW": {"OP": "0000011", "F3": "010"},
    "LBU": {"OP": "0000011", "F3": "100"},
    "LHU": {"OP": "0000011", "F3": "101"},
}

S_INSTRUCTIONS = {
    "SB": {"OP": "0100011", "F3": "000"},
    "SH": {"OP": "0100011", "F3": "001"},
    "SW": {"OP": "0100011", "F3": "010"},
}

SB_INSTRUCTIONS = {
    "BEQ": {"OP": "1100011", "F3": "000"},
    "BNE": {"OP": "1100011", "F3": "001"},
    "BLT": {"OP": "1100011", "F3": "100"},
    "BGE": {"OP": "1100011", "F3": "101"},
    "BLTU": {"OP": "1100011", "F3": "110"},
    "BGEU": {"OP": "1100011", "F3": "111"},
}

UJ_INSTRUCTIONS = {
    "JAL": {"OP": "1101111"},
}

def create_label_table(file_path):
    label_table = {}

    with open(file_path, 'r') as file:
        current_address = 0

        for line in file:
            line = line.strip()

            # Ignore empty lines and comments
            if not line or line.startswith('#'):
                continue

            # Check for labels
            if ':' in line:
                label = line.split(':')[0].strip()
                label_table[label] = current_address

            current_address += 4

        file.seek(0)

    return label_table

def decode_SW(instruction_parts):
    mnem = instruction_parts[0]
    rs2  = int(instruction_parts[1].split('x')[1])
    rs1 = int(instruction_parts[2].split('(')[1].split(')')[0].split('x')[1])

    imm = int(instruction_parts[2].split('(')[0])
    if imm < 0:
        imm += 2**12

    decoded_instruction = str(format(imm, '012b'))[:7]
    decoded_instruction += str(format(rs2, '05b'))
    decoded_instruction += str(format(rs1, '05b'))
    decoded_instruction += S_INSTRUCTIONS[mnem]['F3']
    decoded_instruction += str(format(imm, '012b'))[7:]
    decoded_instruction += S_INSTRUCTIONS[mnem]['OP']
    return decoded_instruction

def decode_LW(instruction_parts):
    mnem = instruction_parts[0]
    rd  = int(instruction_parts[1].split('x')[1])
    rs1 = int(instruction_parts[2].split('(')[1].split(')')[0].split('x')[1])

    imm = int(instruction_parts[2].split('(')[0])
    if imm < 0:
        imm += 2**12

    decoded_instruction = bin(imm)[2:].zfill(12)
    decoded_instruction += str(format(rs1, '05b'))
    decoded_instruction += LW_INSTRUCTIONS[mnem]['F3']
    decoded_instruction += str(format(rd, '05b'))
    decoded_instruction += LW_INSTRUCTIONS[mnem]['OP']

    return decoded_instruction
    pass

def decode_UJ(instruction_parts, label_table, pc):
    mnem = instruction_parts[0]
    rd = int(instruction_parts[1].split('x')[1])
    imm = label_table[instruction_parts[2]] - pc

    if imm < 0:
        imm += 2**21

    imm_bits = bin(imm)[2:].zfill(21)

    decoded_instruction = imm_bits[0] + imm_bits[10:20] + imm_bits[9] + imm_bits[1:9]
    decoded_instruction += str(format(rd, '05b'))
    decoded_instruction += UJ_INSTRUCTIONS[mnem]['OP']


    return decoded_instruction

def decode_SB(instruction_parts, label_table, pc):
    mnem = instruction_parts[0]
    rs1 = int(instruction_parts[1].split('x')[1])
    rs2 = int(instruction_parts[2].split('x')[1])
    imm = label_table[instruction_parts[3]] - pc

    if imm < 0:
        imm += 2**13 # Inverts if negative.

    imm_bits = bin(imm)[2:].zfill(13)

    decoded_instruction = imm_bits[0] + imm_bits[2:8]
    decoded_instruction += str(format(rs2, '05b'))
    decoded_instruction += str(format(rs1, '05b'))
    decoded_instruction += SB_INSTRUCTIONS[mnem]['F3']
    decoded_instruction += imm_bits[8:12] + imm_bits[1]
    decoded_instruction += SB_INSTRUCTIONS[mnem]['OP']

    return decoded_instruction

def decode_I(instruction_parts):
    mnem = instruction_parts[0]
    rd  = int(instruction_parts[1].split('x')[1])
    rs1 = int(instruction_parts[2].split('x')[1])

    imm = int(instruction_parts[3])
    if imm < 0:
        imm += 2**12


    imm_bits = bin(imm)[2:].zfill(12)

    decoded_instruction = imm_bits
    decoded_instruction += str(format(rs1, '05b'))
    decoded_instruction += I_INSTRUCTIONS[mnem]['F3']
    decoded_instruction += str(format(rd, '05b'))
    decoded_instruction += I_INSTRUCTIONS[mnem]['OP']

    return decoded_instruction

def decode_R(instruction_parts):
    mnem = instruction_parts[0]
    rs2 = int(instruction_parts[3].split('x')[1])
    rs1 = int(instruction_parts[2].split('x')[1])
    rd  = int(instruction_parts[1].split('x')[1])

    decoded_instruction = R_INSTRUCTIONS[mnem]['F7']
    decoded_instruction += str(format(rs2, '05b'))
    decoded_instruction += str(format(rs1, '05b'))
    decoded_instruction += R_INSTRUCTIONS[mnem]['F3']
    decoded_instruction += str(format(rd, '05b'))
    decoded_instruction += R_INSTRUCTIONS[mnem]['OP']

    return decoded_instruction

def decode_ass(instruction_parts, label_table, pc):
    instruction_parts[0] = instruction_parts[0].upper()
    if instruction_parts[0] in R_INSTRUCTIONS:
        return decode_R(instruction_parts)
    elif instruction_parts[0] in I_INSTRUCTIONS:
        return decode_I(instruction_parts)
    elif instruction_parts[0] in SB_INSTRUCTIONS:
        return decode_SB(instruction_parts, label_table, pc)
    elif instruction_parts[0] in LW_INSTRUCTIONS:
        return decode_LW(instruction_parts)
    elif instruction_parts[0] in S_INSTRUCTIONS:
        return decode_SW(instruction_parts)
    elif instruction_parts[0] in UJ_INSTRUCTIONS:
        return decode_UJ(instruction_parts, label_table, pc)
    else:
        print("Error: MNEM not found")
        exit(1)

def ass2bin(assembly_line, label_table, pc):
    instruction = assembly_line.split(':')[-1] # Handles ':' from symbol.
    instruction_parts = [char for char in instruction.replace(',', ' ').split()]
    return decode_ass(instruction_parts, label_table, pc)


def main():
    print("Start")
    my_table = create_label_table('./rv_ass.txt')

    pc = 0

    with open('./RISC-V-PIPELINE/rom.txt', 'w') as file:
        for line in open('./rv_ass.txt', 'r'):
            line = line.strip()
            binary_string = ass2bin(line, my_table, pc)
            print(binary_string)
            bit_index = 0
            while bit_index < 32:
                file.write(binary_string[bit_index:(bit_index + 8)] + "\n") #[0:8] [8:]
                bit_index += 8
            hex_string = hex(int(binary_string, 2))[2:].zfill(8)
            padded_line = line.ljust(30)
            print("Assembly: " + padded_line + "&    Hexa:  " + hex_string)

            pc += 4
        while pc < MEM_SIZE:
            file.write(ZERO_LINE + "\n")
            pc += 1

if __name__ == "__main__":
    main()

