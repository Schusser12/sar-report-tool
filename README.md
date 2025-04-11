# 🖥️ Sar Resource Reporter

A lightweight Bash tool for generating historical resource usage reports from a Linux system using `sar`. 

---

## 📦 Features

- ✅ Load average (`sar -q`)
- ✅ CPU usage (`sar -u`)
- ✅ Memory usage (`sar -r`)
- ✅ Network interface stats (`sar -n DEV`)
- ✅ Disk I/O stats (`sar -d`)
- ✅ All-in-one report mode (`-a`)
- ✅ Optional output to file (`-f`)
- ✅ Colorized CLI help (`-h`)
- ✅ Clear, column-aligned output
- ✅ Timestamps auto-added to saved reports

---

## 🚀 Usage

```bash
bash sarview.sh [options]
