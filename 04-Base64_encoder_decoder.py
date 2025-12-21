"""
Base64 encoder / decoder.

- No uso del módulo estándar `base64`
- Soporta datos binarios arbitrarios
- Compatible con UTF-8 mediante encode/decode explícito
"""

BASE64_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


def base64_encode(data: bytes) -> str:
    """
    Condifica una secuancia de bytes a un string de Base64.

    param data: Bytes a codificar
    return: el string codificado en base64 asociado a los bytes introducidos
    """
    encoded = []
    i = 0

    while i < len(data):
        # Tomar hasta 3 bytes (24 bits)
        block = data[i : i + 3]
        padding = 3 - len(block)

        # Convertir el bloque a un entero de 24 bits
        bits = 0
        for byte in block:
            bits = (bits << 8) | byte

        # Rellenar con ceros si faltan bytes
        bits <<= padding * 8

        # Extraer 4 grupos de 6 bits
        for shift in (18, 12, 6, 0):
            index = (bits >> shift) & 0b111111
            encoded.append(BASE64_ALPHABET[index])

        # Sustituir los últimos caracteres por '=' si hubo padding
        if padding:
            encoded[-padding:] = "=" * padding

        i += 3

    return "".join(encoded)


def base64_decode(encoded: str) -> bytes:
    """
    Decodifica una string en base64 a bytes

    :encoded: string codificada en base64
    :return: bytes decodificados
    """
    encoded = encoded.rstrip("=")

    bits = 0
    buffer_len = 0
    output = bytearray()

    for char in encoded:
        bits = (bits << 6) | BASE64_ALPHABET.index(char)
        buffer_len += 6

        while buffer_len >= 8:
            buffer_len -= 8
            byte = (bits >> buffer_len) & 0xFF
            output.append(byte)

    return bytes(output)


def main():
    txt = "Hola á ë"
    encoded = base64_encode(txt.encode("utf-8"))
    decoded = base64_decode(encoded).decode("utf-8")

    print(encoded)
    print(decoded)


if __name__ == "__main__":
    main()
