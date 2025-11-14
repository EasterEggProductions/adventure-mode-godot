extends Node
class_name JoinCode

const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ234678"
const LENGTH := 8

# Return: 8-character code as a String, empty string on failure.
static func ip_to_code(ip: String, port: int) -> String:
	var parts := ip.split(".")
	if parts.size() != 4:
		push_error("ip_to_code: invalid IPv4 address: %s" % ip)
		return ""

	if port > 33999 or port < 33900:
		push_error("ip_to_code: invalid port (must be [33900-33999]): %s" % port)
		return ""

	var port_component := port - 33900

	var a := int(parts[0])
	var b := int(parts[1])
	var c := int(parts[2])
	var d := int(parts[3])
	if a < 0 or a > 255 or b < 0 or b > 255 or c < 0 or c > 255 or d < 0 or d > 255:
		push_error("ip_to_code: invalid IPv4 address: %s" % ip)
		return ""

	var ip_num := (a << 24) | (b << 16) | (c << 8) | d
	var packed := (int(ip_num) << 7) | (port_component & 0x7F)
	packed = packed << 1 # 40-bit number containing the 32-bit IP & 7-bit port

	var code := ""
	for i in LENGTH:
		var shift := 35 - 5 * i
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
	packedData = packedData >> 1 # Remove padding

	var ip_num := (packedData >> 7) & 0xFFFFFFFF
	var port := (packedData & 0x7F) + 33900

	var oct_a := (ip_num >> 24) & 0xFF
	var oct_b := (ip_num >> 16) & 0xFF
	var oct_c := (ip_num >> 8) & 0xFF
	var oct_d := ip_num & 0xFF

	var ip := "%d.%d.%d.%d" % [oct_a, oct_b, oct_c, oct_d]
	return [ip, port]
