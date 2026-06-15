# Security Specification for DonEat

## Data Invariants
1. A user can only create or update their own profile.
2. Only donors can create donations.
3. Donors can only update their own donations.
4. Receivers can reserve a donation (change status from AVAILABLE to RESERVED).
5. Pickups must be linked to a valid donation and valid donor/receiver.
6. XP and Levels cannot be modified by the user directly.

## The Dirty Dozen Payloads (Target: Rejection)
1. **Identity Spoofing**: `create` a User profile with a different `userId` than `auth.uid`.
2. **Role Escalation**: `update` own User profile to set `role: "ADMIN"`.
3. **Ghost Field Injection**: Adding `isVerified: true` to a Donation create payload.
4. **Donation Stealing**: Donor A updating Donor B's donation.
5. **Unauthorized Reservation**: User without a role or even a donor trying to reserve food.
6. **Negative Quantity**: Creating a donation with `quantity: -10`.
7. **Invalid Expiration**: Setting `expirationTime` to a value in the past.
8. **Stat Poisoning**: User updating their own `xp` to `9999999`.
9. **Orphaned Pickup**: Creating a Pickup for a non-existent Donation.
10. **Zombie Update**: Updating a COMPLETED donation back to AVAILABLE.
11. **ID Poisoning**: Using a 2MB string as a `donationId`.
12. **PII Leakage**: Authenticated user listing all emails in `users` collection.

## Validation
Integration tests (e.g. `firestore.rules.test.ts`) must pass to enforce these invariants.
