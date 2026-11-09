# Submission

Fork URL: <!-- paste the URL of your fork here -->

## Files to commit

- [ ] `ufw-rules.txt`: the output of `sudo ufw status numbered` for your final rules, committed to the repo

## Questions

Answer in your own words. Where a question asks for output, paste it in a code block.

### Q1. Paste the port scan from the outsider before and after. Which ports were exposed that should never have been?

**Your answer:**

<!-- replace this line with your answer -->

### Q2. Why is "default deny incoming" a better starting point than "allow everything and block the bad ports"?

**Your answer:**

<!-- replace this line with your answer -->

### Q3. You enabled the firewall while a connection from the office was open. Did it survive? Could the office open a *new* connection? Explain using the idea of connection state.

**Your answer:**

<!-- replace this line with your answer -->

### Q4. Why does the order of `ufw allow` and `ufw enable` matter on a remote server? What would a lockout cost on a cloud VM?

**Your answer:**

<!-- replace this line with your answer -->

### Q5. Where would these rules live in AWS instead of ufw? Name the equivalent object and one difference.

**Your answer:**

<!-- replace this line with your answer -->

### Q6. Paste the output of `sudo ./verify.sh`. It must end with **ALL CHECKS PASSED**.

**Your answer:**

<!-- replace this line with your answer -->
