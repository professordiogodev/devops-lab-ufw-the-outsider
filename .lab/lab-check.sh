#!/usr/bin/env bash
rc=0
[ -s ufw-rules.txt ] && grep -q 8080 ufw-rules.txt && echo "- ✅ ufw-rules.txt records your rules" || { echo "- ❌ ufw-rules.txt is missing (sudo ufw status numbered | tee ufw-rules.txt)"; rc=1; }
grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md && echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED" || { echo "- ❌ paste the verify.sh output ('ALL CHECKS PASSED') into SUBMISSION.md"; rc=1; }
exit $rc
