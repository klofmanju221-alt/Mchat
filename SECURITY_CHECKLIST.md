# Mchat Production Security Checklist

- [ ] Firebase App Check enabled
- [ ] Owner custom claim is assigned server-side
- [ ] No secrets in Flutter source
- [ ] Firestore financial collections client-write disabled
- [ ] Payment webhooks signature verified
- [ ] Idempotency keys used for payment webhooks
- [ ] Wallet ledger is append-only
- [ ] Gift transfer is atomic
- [ ] Withdrawal is server-approved
- [ ] Payout webhook reconciles status
- [ ] Refunds reverse ledger entries
- [ ] Audit log records owner actions
- [ ] Rate limiting and fraud detection enabled
- [ ] KYC/tax/legal requirements completed
- [ ] Privacy policy and terms published
- [ ] App-store review requirements completed
