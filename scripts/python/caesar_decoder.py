import sys
from typing import Final

ALPHABET_SIZE: Final[int] = 26


def encrypt(text: str, shift: int) -> str:
    """Encripta o desencripta un texto empleado cifrado cesar"""
    shift %= ALPHABET_SIZE
    result: list[str] = []

    for char in text:
        if char.isalpha():
            base = ord("A") if char.isupper() else ord("a")
            result.append(chr((ord(char) - base + shift) % ALPHABET_SIZE + base))
        else:
            result.append(char)

    return "".join(result)


def bruteforce(encrypted: str) -> None:
    """Prueba todos los shifts posibles para desencriptar Cesar por fuerza bruta"""
    for shift in range(ALPHABET_SIZE):
        decrypted = encrypt(encrypted, -shift)
        print(f"SHIFT {shift:2d}: {decrypted}")


def usage() -> None:
    """Imprime las instrucciones de uso"""
    script = sys.argv[0]
    print("Uso:")
    print(f"  Encriptar:     {script} -e 'texto' <desplazamiento>")
    print(f"  Fuerza bruta:  {script} -b 'texto_cifrado'")


def main() -> None:
    if len(sys.argv) < 3:
        usage()
        sys.exit(1)

    mode, text = sys.argv[1], sys.argv[2]

    if mode == "-e":
        if len(sys.argv) != 4:
            usage()
            sys.exit(1)

        try:
            shift = int(sys.argv[3])
        except ValueError:
            print("Error: el desplazamiento debe ser un número entero", file=sys.stderr)
            sys.exit(1)

        print(encrypt(text, shift))

    elif mode == "-b":
        bruteforce(text)

    else:
        usage()
        sys.exit(1)


if __name__ == "__main__":
    main()
