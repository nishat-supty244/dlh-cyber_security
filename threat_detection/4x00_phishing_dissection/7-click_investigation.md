**7\. The Click Investigation**

**Click Investigation — Diane Marsh / WS-NURSE-04**

**Confirmed Facts**

- **User:** Diane Marsh
- **Workstation:** WS-NURSE-04
- **Email:** Email 2 (E2)
- **Recipient address:** <dmarsh@meddefense.com>
- **Sender:** <noreply@meddefense-portal.com>
- **Claimed sender:** "MedDefense IT Security"
- **URL clicked:**  
  <https://meddefense-portal.com/verify/staff?id=dmarsh&token=a8f3e2d1>
- **Defanged URL:**  
  hxxps://meddefense-portal\[.\]com/verify/staff?id=dmarsh&token=a8f3e2d1
- **Domain:** meddefense-portal.com
- **Related sending IP:** 91.234.99.107
- **Click timestamp:** 2026-04-14 15:02:33 CDT
- **Evidence source:** The evidence batch states that Diane clicked the E2 link approximately 36 hours before collection, and the final batch record provides the workstation and click timestamp.

Email 2 also contains the following evidence:

- SPF: **FAIL**
- DKIM: **NONE**
- DMARC: **FAIL**
- The email claims to be from MedDefense IT Security.
- The domain is meddefense-portal.com, rather than the organization's normal meddefense.com domain.
- The email requested portal re-verification within 24 hours.
- It threatened suspension of access to the scheduling system, EHR gateway, and shift-swap requests.

**Key Unknowns**

The click itself is confirmed, but the evidence batch does **not** confirm that Diane entered credentials or that her account was compromised.

The following are unknown:

- Whether the phishing page successfully loaded.
- Whether Diane entered her username or password.
- Whether MFA information was entered or approved.
- Whether credentials were captured by the attacker.
- Whether a session cookie or authentication token was exposed.
- Whether anything was downloaded to WS-NURSE-04.
- Whether a malicious process executed.
- Whether PowerShell or cmd.exe was used after the click.
- Whether Diane's account was accessed by an attacker.
- Whether suspicious authentication occurred after the click.
- Whether the attacker created inbox rules or changed account settings.

These questions require endpoint and identity evidence that is not included in the current project.

**Endpoint Checks To Perform**

If endpoint logs or forensic data are available, check WS-NURSE-04 for activity around the click time:

**1\. Browser history**

Check for:

- meddefense-portal.com
- /verify/staff
- Other pages visited immediately before and after the click
- Redirects to other domains

**2\. Downloaded files**

Check whether any files were downloaded around:

2026-04-14 15:02:33 CDT

Look for:

- New files
- Suspicious filenames
- Unexpected scripts
- Executables
- Archives
- Office/PDF files

**3\. Process execution**

Check for unexpected processes starting after the click.

Pay particular attention to:

- Browser child processes
- PowerShell
- cmd.exe
- wscript.exe
- cscript.exe
- Other unexpected interpreters

**4\. PowerShell / command activity**

If available, review PowerShell and command-line activity around the click time.

Look for commands that downloaded files, executed scripts, or accessed credentials.

**5\. File creation**

Check for files created or modified shortly after the click.

Compare the timestamps with the confirmed click time.

**Important:**

These are recommended follow-up checks. The current evidence does **not** show that Sysmon, Wazuh, Suricata, Windows Security logs, or endpoint logs were searched.

**Account Checks To Perform**

If identity-provider or Microsoft 365 account logs are available, check Diane's account around and after the click.

**1\. Failed logons**

Look for unusual authentication failures after:

2026-04-14 15:02:33 CDT

**2\. Successful logons**

Check for successful logins from:

- Unusual IP addresses
- Unusual countries or locations
- New devices
- Unusual browsers
- Unusual times

**3\. MFA activity**

Check for:

- Unexpected MFA prompts
- Repeated MFA requests
- MFA approvals that Diane does not recognize
- Changes to MFA methods

**4\. Password changes**

Check whether the password was changed after the phishing click.

**5\. Inbox rules**

Check for newly created or modified rules that could:

- Forward mail externally
- Hide security notifications
- Move messages to unusual folders
- Delete incoming messages

**6\. Group membership**

Check whether Diane's account was added to or removed from privileged or sensitive groups.

**7\. Other account changes**

Check for:

- New registered devices
- New authentication methods
- Session/token changes
- Changes to account recovery information

**Decision Matrix**

| **Outcome**                      | **Evidence**                                                                                                                         | **Interpretation**                                                  | **Action**                                                                                                                |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **No compromise found**          | Click confirmed, but no credential submission, suspicious endpoint activity, or unusual account activity is found                    | The click occurred, but available evidence does not show compromise | Continue monitoring and document the incident                                                                             |
| **Possible credential exposure** | Evidence suggests Diane interacted with the phishing page or entered credentials, but unauthorized account activity is not confirmed | Credentials or authentication information may have been exposed     | Reset password, revoke sessions, review MFA and monitor the account                                                       |
| **Confirmed compromise**         | Evidence shows unauthorized login, account takeover, malicious activity, or other confirmed attacker activity                        | The account or workstation has been compromised                     | Apply incident-response containment, revoke access/sessions, reset credentials, investigate affected systems and accounts |

**Recommended Containment**

Because the user clicked a credential-harvesting link, the following actions are reasonable while the investigation is ongoing:

1. **Interview Diane**
   - Ask whether she entered her username or password.
   - Ask whether she entered or approved an MFA request.
   - Ask whether anything downloaded or appeared unusual.
2. **Reset the password**
   - If credential entry is confirmed or suspected, reset Diane's password through the organization's normal trusted process.
3. **Revoke active sessions**
   - If supported by the identity system, revoke active sessions/tokens to reduce the risk of an attacker reusing an existing session.
4. **Review MFA**
   - Check for unexpected MFA activity or newly registered authentication methods.
5. **Monitor the account**
   - Watch for unusual successful logins, failed logins, new devices, or suspicious account changes.
6. **Check the workstation**
   - Review browser activity, downloads, process execution, PowerShell/cmd activity, and file creation on WS-NURSE-04.
7. **Do not use the phishing link again**
   - The URL should remain defanged during documentation and investigation.

**Conclusion**

The evidence confirms that **Diane Marsh clicked the Email 2 phishing link from WS-NURSE-04 at 2026-04-14 15:02:33 CDT**.

The link used the suspicious domain meddefense-portal.com and was associated with sending IP 91.234.99.107. Email 2 also had **SPF fail, DKIM none, and DMARC fail**, and attempted to create urgency by demanding portal verification within 24 hours.

However, the current evidence does **not** prove that Diane entered credentials or that her account or workstation was compromised.

The correct next step is therefore to perform the recommended **endpoint and identity checks**. The investigation should then classify the incident as **no compromise found, possible credential exposure, or confirmed compromise** based on the evidence obtained.
