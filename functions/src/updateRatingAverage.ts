import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Update Rating Average — SRS §7.2
 *
 * Trigger: Firestore onCreate on ratings/{ratingId}
 * Logic: Re-query all ratings for rateeId, compute average,
 * update ratingAvg on users/{rateeId} and youth_profiles/{rateeId} (if exists).
 */
export const updateRatingAverage = onDocumentCreated(
  "ratings/{ratingId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const rating = snapshot.data();
    const rateeId = rating.rateeId as string | undefined;

    if (!rateeId) {
      console.log("[updateRatingAverage] No rateeId — skipping");
      return;
    }

    try {
      // Query all ratings for this ratee
      const ratingsSnap = await db
        .collection("ratings")
        .where("rateeId", "==", rateeId)
        .get();

      if (ratingsSnap.empty) return;

      // Compute average score
      let totalScore = 0;
      let count = 0;
      for (const doc of ratingsSnap.docs) {
        const score = doc.data().score as number | undefined;
        if (score != null) {
          totalScore += score;
          count++;
        }
      }

      if (count === 0) return;

      const ratingAvg = parseFloat((totalScore / count).toFixed(1));
      const ratingCount = count;

      console.log(
        `[updateRatingAverage] rateeId=${rateeId} — avg=${ratingAvg}, count=${ratingCount}`
      );

      // Update users/{rateeId}
      await db.collection("users").doc(rateeId).update({
        ratingAvg,
        ratingCount,
        averageRating: ratingAvg, // backward compat
        totalRatings: ratingCount,
      });

      // Update youth_profiles/{rateeId} if it exists
      const youthDoc = await db
        .collection("youth_profiles")
        .doc(rateeId)
        .get();
      if (youthDoc.exists) {
        await db.collection("youth_profiles").doc(rateeId).update({
          ratingAvg,
          ratingCount,
        });
      }

      console.log(
        `[updateRatingAverage] Updated rating for user ${rateeId}`
      );
    } catch (error) {
      console.error("[updateRatingAverage] Error:", error);
    }
  }
);
