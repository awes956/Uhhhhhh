import re

def process_lua_file(input_path, output_path):
    with open(input_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    out_lines = []

    for line in lines:
        # 4. remove empty / whitespace-only lines
        if line.strip() == "":
            continue

        # 6. remove exact `m: Mario`
        line = re.sub(r'\bm:\s*Mario\b', '', line)

        # 2. replace m. and m: with maryo. (after the special case)
        line = re.sub(r'\bm[.:]', 'maryo.', line)

        # 3. replace Action / AIRSTEP AirStep / Animations / Sounds
        line = re.sub(
            r'\b(Action|AirStep|Animations|Sounds)\.([A-Z_]+)',
            r'"\2"',
            line
        )

        # also handle weird `AIRSTEP AirStep.SOMETHING`
        line = re.sub(
            r'\bAIRSTEP\s+AirStep\.([A-Z_]+)',
            r'"\1"',
            line
        )

        # 9. Input / Flags Has() replacements
        line = re.sub(
            r'maryo\.Input:Has\(InputFlags\.([A-Z_]+)\)',
            r'maryo.Input.\1',
            line
        )

        line = re.sub(
            r'maryo\.Flags:Has\(MarioFlags\.([A-Z_]+)\)',
            r'maryo.Flags.\1',
            line
        )

        # 8. special SetY + maryo cases
        line = re.sub(
            r'Util\.SetY\(maryo\.Position\s*,\s*([^)]+)\)',
            r'maryo.SetHeight(\1)',
            line
        )

        line = re.sub(
            r'Util\.SetY\(maryo\.Velocity\s*,\s*([^)]+)\)',
            r'maryo.SetUpwardVel(\1)',
            line
        )

        line = re.sub(
            r'Util\.SetY\(maryo\.FaceAngle\s*,\s*([^)]+)\)',
            r'maryo.SetFaceYaw(\1)',
            line
        )

        # 7. generic Util.SetX/Y/Z -> Vector3.new
        def set_to_vec(match):
            axis = match.group(1)
            src = match.group(2)
            val = match.group(3)

            if axis == "X":
                return f"Vector3.new({val}, {src}.Y, {src}.Z)"
            if axis == "Y":
                return f"Vector3.new({src}.X, {val}, {src}.Z)"
            if axis == "Z":
                return f"Vector3.new({src}.X, {src}.Y, {val})"

        line = re.sub(
            r'Util\.Set([XYZ])\(\s*([^,\s]+)\s*,\s*([^)]+)\)',
            set_to_vec,
            line
        )

        # 5. remove argument `m` from function calls
        line = re.sub(r'\(\s*m\s*,', '(', line)
        line = re.sub(r',\s*m\s*(?=\))', '', line)
        line = re.sub(r'\(\s*m\s*\)', '()', line)

        out_lines.append(line)

    # 1. write to new file
    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(out_lines)

# example usage
process_lua_file("v_moveset3.lua", "v_moveset3_2.lua")