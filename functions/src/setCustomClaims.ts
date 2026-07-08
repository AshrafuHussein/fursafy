import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

/**
 * Set Custom User Claims — SRS §13.2
 *
 * Trigger: Firestore onCreate on users/{uid}
 * Logic: Read the role field from the new user doc and set it as a
 * Firebase Auth custom claim. This enables Security Rules to use
 * request.auth.token.role for role-based access control.
 */
export const setCustomClaims = onDocumentCreated(
  "users/{uid}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const userData = snapshot.data();
    const uid = event.params.uid;
    const role = userData.role as string | undefined;

    if (!role) {
      console.log(`[setCustomClaims] No role field on user ${uid} — skipping`);
      return;
    }

    try {
      await admin.auth().setCustomUserClaims(uid, { role });
      console.log(
        `[setCustomClaims] Set custom claim role='${role}' for user ${uid}`
      );
    } catch (error) {
      console.error(`[setCustomClaims] Error setting claims for ${uid}:`, error);
    }
  }
);
