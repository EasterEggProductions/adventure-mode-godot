extends Node
class_name JoinCode

const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ234678"
const LENGTH := 10

# Return: 10-character code as a String, empty string on failure.
static func ip_to_code(ip: String, port: int) -> String:
	var parts := ip.split(".")
	if parts.size() != 4:
		push_error("ip_to_code: invalid IPv4 address: %s" % ip)
		return ""

	var a := int(parts[0])
	var b := int(parts[1])
	var c := int(parts[2])
	var d := int(parts[3])
	if a < 0 or a > 255 or b < 0 or b > 255 or c < 0 or c > 255 or d < 0 or d > 255:
		push_error("ip_to_code: invalid IPv4 address: %s" % ip)
		return ""

	var ip_num := (a << 24) | (b << 16) | (c << 8) | d
	var packed := (int(ip_num) << 16) | (port & 0xFFFF)
	packed = packed << 2 # 50-bit number containing the IP and port

	var code := ""
	for i in LENGTH:
		var shift := 45 - 5 * i
		var index := int((packed >> shift) & 0x1F) # 5-bits per char
		code += ALPHABET[index]
	return code

# Return: [String, int] corresponding to IPv4 and port, empty array on failure.
static func code_to_ip(code: String) -> Array:
	if code.length() != LENGTH:
		push_error("code_to_ip: invalid length for code")
		return []

	var packedData := 0
	for i in LENGTH:
		var c := code[i]
		var ind := ALPHABET.find(c)
		if ind == -1:
			push_error("code_to_ip: invalid code")
			return []
		packedData = (packedData << 5) | ind
	packedData = packedData >> 2 # Remove padding (imperfect fit)

	var ip_num := (packedData >> 16) & 0xFFFFFFFF
	var port := packedData & 0xFFFF

	var oct_a := (ip_num >> 24) & 0xFF
	var oct_b := (ip_num >> 16) & 0xFF
	var oct_c := (ip_num >> 8) & 0xFF
	var oct_d := ip_num & 0xFF

	var ip := "%d.%d.%d.%d" % [oct_a, oct_b, oct_c, oct_d]
	return [ip, port]
