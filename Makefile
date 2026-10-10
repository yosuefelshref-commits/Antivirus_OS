pre-build:
	mkdir -p malicious_dir
run-antivirus: pre-build
	bash antivirusd.sh test_dir malicious_dir 5
run-restore: pre-build
	bash restore.sh test_dir malicious_dir
