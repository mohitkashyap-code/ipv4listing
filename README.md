# ipv4listing
Interactive IPv4 Range Generator CLI (Safe &amp; User-Friendly) written in Bash.

Generates IP address lists in `A.B.C.D` format with strong validation, safe execution, and user-friendly prompts.

---

## 🚀 Features

- Interactive input (A, B, C, D ranges)
- Strict validation (0–255 per octet)
- Range enforcement (Start ≤ End)
- Multiple range support
- Large range warning (prevents accidental huge outputs)
- Deduplication of IPs
- Safe cancellation (Ctrl+C handled cleanly)
- Atomic file writing (no partial/corrupt output)
- Overwrite protection with re-prompt
- Colored CLI output for better UX

---

## 📦 Installation

```bash
git clone https://github.com/your-username/ipv4listing.git
cd ipv4listing
chmod +x ipv4listing.sh
```

## ▶️ Usage

```bash
./ipv4listing.sh
```

Follow the interactive prompts:

```bash
A-Start -> 192
A-End   -> 192
B-Start -> 168
B-End   -> 168
C-Start -> 1
C-End   -> 1
D-Start -> 1
D-End   -> 5
```

## 📄 Example Output

```bash
192.168.1.1
192.168.1.2
192.168.1.3
192.168.1.4
192.168.1.5
```

## ⚠️ Safety Features

This tool is designed to prevent common mistakes:

Rejects invalid input (non-numeric, out of range)
Prevents reversed ranges (e.g., start > end)
Warns before generating very large IP sets
Prevents accidental file overwrite
Cleans up temporary files on interruption or crash

## 📊 Output Details

Default output file: ip_list.txt
Custom filename supported
Duplicate IPs are automatically removed
Displays total number of generated IPs

## 🧠 Use Cases

Feeding IP lists into tools like:
nmap
masscan
Network testing / lab setups
Scripting pipelines
Quick IP range expansion without external dependencies

## 🔧 Requirements

Bash (>= 4.x recommended)
Linux / Unix environment

## 🛠️ Future Improvements (Optional)

CIDR support (192.168.1.0/24)
Non-interactive CLI mode (--range)
Pipe/stream mode for automation
Parallel generation for very large datasets

## 📜 License

MIT License

## 👤 Author

Mohit Kashyap

## ⭐ Notes

This project focuses on simplicity, safety, and usability rather than replacing advanced network tools.
It is intended as a lightweight utility for quick IP list generation.
