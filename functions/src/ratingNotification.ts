import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { sendNotification } from "./utils/sendNotification";

const db = admin.firestore();

/**
 * Rating Notification — SRS §3.7 / FR-35
 *
 * Trigger: Firestore onCreate on ratings/{ratingId}
 * Logic: When a new rating is submitted, notify the person being rated (rateeId).
 */
export const ratingNotification = onDocumentCreated(
  "ratings/{ratingId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const rating = snapshot.data();
    const rateeId = rating.rateeId as string | undefined;
    const raterId = rating.raterId as string | undefined;
    const jobId = rating.jobId as string | undefined;
    const ratingScore = rating.rating as number | undefined;

    if (!rateeId) {
      console.log("[ratingNotification] No rateeId — skipping");
      return;
    }

    // Get rater's name for the message
    let raterName = "Someone";
    if (raterId) {
      try {
        const raterDoc = await db.collection("users").doc(raterId).get();
        raterName =
          (raterDoc.data()?.displayName as string) ?? "Someone";
      } catch (_) {
        // Use fallback
      }
    }

    const stars = ratingScore ? `${ratingScore}★` : "";
    const message = `${raterName} gave you a ${stars} rating. Tap to see your profile.`;

    await sendNotification({
      userId: rateeId,
      type: "rating_received",
      title: "New Rating Received! ⭐",
      message,
      jobId: jobId,
      screen: "/profile",
    });

    console.log(
      `[ratingNotification] Notified ratee ${rateeId} about new rating`
    );
  }
);
