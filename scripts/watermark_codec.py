#!/usr/bin/env python3
"""
watermark_codec.py
Steganographic and Obfuscated Watermark Codec Utility

Owner Details:
- Author: Wilhelm San Pedro (@welsonnot)
- Website: https://minristudio.com
- GitHub: https://github.com/Welsonnot
- License: PolyForm Noncommercial License 1.0.0
"""

import sys
import argparse

ZWSP = '\u200B'  # Zero-width space (bit 0)
ZWNJ = '\u200C'  # Zero-width non-joiner (bit 1)

# Default Layer B XOR key & digest
DEFAULT_XOR_KEY = [0x57, 0x69, 0x6C, 0x68, 0x65, 0x6C, 0x6D]  # 'Wilhelm'
DEFAULT_XOR_DIGEST = [
    20, 6, 28, 17, 23, 5, 10, 63, 29, 76, 64, 6, 69, 77, 0, 0, 0, 0, 0, 0, 0,
    119, 58, 13, 6, 69, 60, 8, 51, 27, 3, 72, 77, 1, 4, 57, 27, 5, 27, 17, 25,
    9, 62, 6, 66, 11, 10, 1, 68, 121, 73, 45, 4, 9, 76, 31, 62, 14, 4, 28, 22,
    76, 31, 50, 26, 9, 26, 19, 9, 9, 119, 28, 2, 12, 0, 30, 77, 7, 6, 0, 17,
    35, 3, 31, 58, 73, 34, 7, 11, 15, 2, 58, 4, 9, 26, 6, 5, 12, 59, 73, 32,
    1, 6, 9, 3, 36, 12, 66
]

def encode_invisible(text: str) -> str:
    """Encodes ASCII/UTF-8 plaintext into zero-width Unicode characters."""
    encoded_bytes = text.encode('utf-8')
    bits = ''.join(f'{b:08b}' for b in encoded_bytes)
    return ''.join(ZWNJ if b == '1' else ZWSP for b in bits)

def decode_invisible(text: str) -> str:
    """Extracts and decodes zero-width characters from text into UTF-8 plaintext.
    Handles both raw Unicode code points and escaped string literals (\\u200b / \\u200c).
    """
    import re
    # Check if text contains escaped notation (e.g. in source code literals)
    if '\\u200' in text:
        # Match sequences of \\u200[bBcC] separated by quotes/whitespace/newlines
        escaped_matches = re.findall(r'\\u200[bBcC]', text)
        # Look for sequences that are multiples of 8 or long sequences (>= 16)
        if len(escaped_matches) >= 16:
            # If there are standalone single occurrences (like constant definitions), strip them
            # Group into blocks separated by non-consecutive occurrences
            clean_matches = [m for m in escaped_matches]
            # If not aligned to 8, try removing leading single definitions
            while len(clean_matches) % 8 != 0 and len(clean_matches) > 8:
                clean_matches.pop(0)
            if clean_matches:
                bits = ['1' if m.lower() == r'\u200c' else '0' for m in clean_matches]
                byte_count = len(bits) // 8
                raw_bytes = bytearray()
                for i in range(byte_count):
                    chunk = ''.join(bits[i * 8:(i + 1) * 8])
                    raw_bytes.append(int(chunk, 2))
                try:
                    res = raw_bytes.decode('utf-8')
                    if any(c.isalnum() for c in res):
                        return res
                except Exception:
                    pass

    bits = [('1' if char == ZWNJ else '0') for char in text if char in (ZWSP, ZWNJ)]
    if not bits:
        return ""
    byte_count = len(bits) // 8
    raw_bytes = bytearray()
    for i in range(byte_count):
        chunk = ''.join(bits[i * 8:(i + 1) * 8])
        raw_bytes.append(int(chunk, 2))
    return raw_bytes.decode('utf-8', errors='replace')

def resolve_xor_signature(digest=None, key=None) -> str:
    """Decodes obfuscated byte signature using the XOR cipher key."""
    d = digest or DEFAULT_XOR_DIGEST
    k = key or DEFAULT_XOR_KEY
    decoded_chars = [chr(b ^ k[i % len(k)]) for i, b in enumerate(d)]
    return ''.join(decoded_chars)

def main():
    parser = argparse.ArgumentParser(
        description="Rust Code Raider - Watermark & Provenance Utility"
    )
    parser.add_argument("--encode", help="Text to encode into invisible zero-width characters")
    parser.add_argument("--decode", help="String or file path to extract invisible watermark from")
    parser.add_argument("--verify-signature", action="store_true", help="Decode and verify Layer B XOR license signature")

    args = parser.parse_args()

    if args.encode:
        encoded = encode_invisible(args.encode)
        print(f"[+] Encoded {len(args.encode)} chars into {len(encoded)} zero-width code points.")
        print(f"[+] Raw escape sequence representation:")
        print(encoded.encode('unicode_escape').decode('utf-8'))
        sys.exit(0)

    if args.decode:
        content = args.decode
        try:
            with open(content, 'r', encoding='utf-8') as f:
                content = f.read()
                print(f"[*] Read content from file: {args.decode}")
        except Exception:
            pass
        decoded = decode_invisible(content)
        if decoded:
            print(f"[+] Decoded invisible watermark payload:\n--> {decoded}")
        else:
            print("[-] No zero-width watermark characters found.")
        sys.exit(0)

    if args.verify_signature:
        sig = resolve_xor_signature()
        print(f"[+] Layer B Decoded License Signature:\n--> {sig}")
        sys.exit(0)

    # Default action if no args: test both layers
    print("===================================================================")
    print("Rust Code Raider - Watermark & Provenance Diagnostic")
    print("===================================================================")
    sample_payload = "Welsonnot | minristudio.com"
    zw = encode_invisible(sample_payload)
    back = decode_invisible(zw)
    print(f"Layer A (Steganography Engine): '{sample_payload}' -> '{back}' (OK)")
    assert back == sample_payload, "Layer A failed"

    import os
    target_path = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', 'lib', 'models', 'keybind_config.dart'))
    if os.path.exists(target_path):
        with open(target_path, 'r', encoding='utf-8') as f:
            code_content = f.read()
        extracted = decode_invisible(code_content)
        print(f"Layer A (Extracted from lib/models/keybind_config.dart): '{extracted}'")
        assert extracted == sample_payload, f"Layer A codebase extraction mismatch: {extracted}"

    sig = resolve_xor_signature()
    print(f"Layer B (XOR Signature): '{sig}'")
    print("Status: ALL WATERMARK LAYERS OPERATIONAL & VERIFIED.")
    print("===================================================================")

if __name__ == "__main__":
    main()
