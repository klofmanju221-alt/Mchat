# Mchat — Production Foundation

This package is intentionally **not** a fake-money app.

## Real-data rule
The client does not create balances, payment success, commissions or withdrawal success.
Financial state must be written by trusted backend functions after verification.

## Required configuration
1. Create a Firebase project.
2. Add Android/iOS apps and generate `google-services.json` / `GoogleService-Info.plist`.
3. Enable Firebase Authentication.
4. Enable Firestore.
5. Enable App Check.
6. Deploy Firestore rules.
7. Create server-side Cloud Functions or another secure backend.
8. Connect a payment provider and verify its webhook server-side.
9. Connect a verified payout/withdrawal provider.
10. Connect a real-time voice/video provider.
11. Configure monitoring, audit logs and fraud controls.
12. Complete KYC/business, tax, privacy, refund, terms and app-store requirements.

## Owner
Owner email identifier: `klofmanju221@gmail.com`

Do not put the owner's password, payment secret, payout secret or Firebase Admin credentials in this project or in chat.

## Financial flow
Payment initiated -> gateway -> server webhook verification -> server ledger entry -> coins credited.
Gift -> server-side atomic ledger transaction -> recipient/commission entries.
Withdrawal request -> server checks verified available balance -> payout provider -> webhook/status reconciliation.

No client-side button is allowed to simply mark a withdrawal as successful.
