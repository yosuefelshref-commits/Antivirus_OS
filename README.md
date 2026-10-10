# Antivirus Daemon Lab

## 1. Overview

This project implements a simple antivirus daemon using Bash on Ubuntu. The daemon monitors a specified directory for files that match predefined suspicious file extensions or contain suspicious keywords.

When a file is detected, the daemon copies it to a quarantine directory named `malicious_dir` and removes the original file from the monitored directory.

The project also includes a restoration tool that allows the user to review quarantined files, restore false positives, or permanently delete files identified as malicious. A persistent whitelist stores the filenames of files restored as false positives so they can be skipped during future scans.

### Project Structure

```text
Antivirus_OS/
├── antivirusd.sh
├── restore.sh
├── Makefile
├── whitelist.txt
├── test_dir/
├── malicious_dir/
├── directory-info.last
└── directory-info.new
```

**File and directory descriptions:**

* `antivirusd.sh`: Monitors the specified directory and scans files for suspicious extensions and content.
* `restore.sh`: Provides an interactive menu to restore or permanently delete quarantined files.
* `Makefile`: Defines targets for running the antivirus daemon and restoration tool.
* `whitelist.txt`: Stores filenames marked as safe.
* `test_dir/`: Example directory monitored by the daemon.
* `malicious_dir/`: Stores quarantined files.
* `directory-info.last`: Stores the previous directory snapshot.
* `directory-info.new`: Stores the current directory snapshot.

The snapshot files are generated at runtime. The monitored and quarantine directories can be created when setting up the project.

## 2. Prerequisites and Installation

The project requires:

* Ubuntu or a compatible Linux environment.
* Bash.
* GNU Make.
* Standard command-line utilities such as `grep`, `ls`, `cmp`, `cp`, `mv`, `rm`, and `mkdir`.

These utilities are normally available on Ubuntu.

### Install the required packages

Update the package lists:

```bash
sudo apt update
```

Install the required packages:

```bash
sudo apt install bash coreutils grep make
```

Verify that Make is installed:

```bash
make --version
```

### Prepare the project

Navigate to the project directory:

```bash
cd ~/antivirus-lab
```

If your project directory has a different name, use its actual path.

Create the monitored directory:

```bash
mkdir -p test_dir
```

The Makefile creates `malicious_dir/` automatically through its `pre-build` target when running either main target.

## 3. Running the Antivirus Daemon

The antivirus daemon accepts three arguments:

```text
antivirusd.sh <dir> <malicious_dir> <interval-secs>
```

* `dir`: The directory to monitor.
* `malicious_dir`: The directory used to quarantine detected files.
* `interval-secs`: The interval, in seconds, between monitoring checks.

### Step 1: Start the daemon

From the project directory, run:

```bash
make run-antivirus
```

The current Makefile configuration runs the daemon with:

* Monitored directory: `test_dir`
* Quarantine directory: `malicious_dir`
* Monitoring interval: 5 seconds

### Step 2: Understand the monitoring process

1. The daemon validates its arguments and checks that the monitored directory exists.
2. It creates the quarantine directory if necessary and ensures the whitelist file exists.
3. It scans the monitored directory on the first run.
4. It records directory information in snapshot files.
5. It periodically compares the current snapshot with the previous snapshot.
6. If a change is detected, it scans the directory again.
7. Files that match a detection rule and are not whitelisted are copied to `malicious_dir/` and removed from the monitored directory.
8. The daemon updates its snapshot and continues monitoring.

### Step 3: Stop the daemon

Press `Ctrl+C` in the terminal running the daemon.

**Note:** Use a dedicated test directory because files flagged by the daemon are removed from that directory after being copied to quarantine.

## 4. Running the Restore Tool

The restore tool allows the user to review files stored in `malicious_dir/`.

Stop the antivirus daemon before running the restore tool to avoid having both scripts operate on the same directories simultaneously.

### Step 1: Start the restore tool

Run:

```bash
make run-restore
```

The tool displays the quarantined files and asks the user to select one.

### Step 2: Choose an action

The interactive menu provides three options:

1. **Restore the file:** Moves the file back to the monitored directory and adds its filename to `whitelist.txt` if it is not already present.
2. **Permanently delete the file:** Removes the selected file from the quarantine directory.
3. **Leave the file in quarantine:** Leaves the file unchanged for later review.

If no quarantined files are available, the script displays:

```text
No malicious files to review.
```

### Running the restore tool directly

The restore script accepts two arguments:

```text
restore.sh <dir> <malicious_dir>
```

For example:

```bash
bash restore.sh test_dir malicious_dir
```

## 5. Detection Rules: Flagged Extensions and Keywords

The required detection lists are defined in `antivirusd.sh`, inside the `scan_dir()` function.

### Flagged file extensions

The extension-matching `case` statement checks for:

* `.exe`
* `.bat`
* `.vbs`
* `.scr`
* `.ps1`

### Flagged content keywords

The content-search command uses the following keyword pattern:

```text
virus|trojan|malware|worm|ransomware
```

These keywords are searched case-insensitively, so uppercase and lowercase variations can match.

A file is flagged if its extension matches one of the configured extensions or its content contains one of the configured keywords, unless its filename is found in the whitelist.

### Whitelist behavior

The whitelist is stored in `whitelist.txt` beside the scripts. When the user restores a file through option 1 of `restore.sh`, its filename is added to the whitelist if it is not already listed.

During subsequent scans, `antivirusd.sh` checks the file's basename against the whitelist. If a matching entry exists, the file is skipped before the extension and content checks.

Because the whitelist is stored on disk, its entries persist when the daemon is stopped and restarted.

## 6. Limitations

This project is a simplified educational antivirus implementation. It uses predefined extensions and keywords rather than a comprehensive malware detection engine. It scans files directly inside the monitored directory and does not recursively scan nested directories.

A legitimate file may be flagged if it matches a detection rule, while a malicious file may go undetected if it does not match any configured rule.

The project should therefore be tested using a dedicated directory containing non-important test files.