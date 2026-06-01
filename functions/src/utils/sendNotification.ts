import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * Shared helper to write a Firestore notification document AND send an
 * FCM push notification to a single user.
 *
 * Notification path: notifications/{userId}/items/{auto}
 * FCM payload follows the structure defined in SRS §12.3.
 */
export async function sendNotification(params: {
  userId: string;
  type: string;
  title: string;
  message: string;
  jobId?: string;
  applicationId?: string;
  screen: string;
}): Promise<void> {
  const { userId, type, title, message, jobId, applicationId, screen } = params;

  // 1. Write notification document to Firestore
  const notifRef = db
    .collection("notifications")
    .doc(userId)
    .collection("items")
    .doc();

  await notifRef.set({
    type,
    title,
    message,
    jobId: jobId ?? null,
    applicationId: applicationId ?? null,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // 2. Look up user's FCM token
  const userDoc = await db.collection("users").doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken as string | undefined;

  if (!fcmToken) {
    console.log(`[sendNotification] No FCM token for user ${userId} — skipping push`);
    return;
  }

  // 3. Send FCM push notification (SRS §12.3 payload structure)
  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body: message },
      data: {
        type,
        jobId: jobId ?? "",
        applicationId: applicationId ?? "",
        screen,
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "fursafy_jobs",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });
    console.log(`[sendNotification] Push sent to user ${userId}`);
  } catch (error: unknown) {
    const err = error as { code?: string };
    // Handle stale tokens — remove them from the user doc
    if (
      err.code === "messaging/registration-token-not-registered" ||
      err.code === "messaging/invalid-registration-token"
    ) {
      console.warn(
        `[sendNotification] Stale token for user ${userId} — removing`
      );
      await db
        .collection("users")
        .doc(userId)
        .update({ fcmToken: admin.firestore.FieldValue.delete() });
    } else {
      console.error(`[sendNotification] FCM send failed:`, error);
    }
  }
}

/**
 * Send notifications to multiple users in batch.
 * Writes Firestore docs in a batch and sends FCM individually.
 */
export async function sendBatchNotifications(
  notifications: Array<{
    userId: string;
    type: string;
    title: string;
    message: string;
    jobId?: string;
    screen: string;
  }>
): Promise<void> {
  // Write all notification docs in a batch
  const batch = db.batch();

  for (const notif of notifications) {
    const ref = db
      .collection("notifications")
      .doc(notif.userId)
      .collection("items")
      .doc();
    batch.set(ref, {
      type: notif.type,
      title: notif.title,
      message: notif.message,
      jobId: notif.jobId ?? null,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();

  // Collect FCM tokens
  const userIds = [...new Set(notifications.map((n) => n.userId))];
  const tokenMap = new Map<string, string>();

  for (const uid of userIds) {
    const doc = await db.collection("users").doc(uid).get();
    const token = doc.data()?.fcmToken as string | undefined;
    if (token) tokenMap.set(uid, token);
  }

  // Send FCM to each user with a valid token
  const tokens: string[] = [];
  const messages: admin.messaging.TokenMessage[] = [];

  for (const notif of notifications) {
    const token = tokenMap.get(notif.userId);
    if (!token || tokens.includes(token)) continue;
    tokens.push(token);
    messages.push({
      token,
      notification: { title: notif.title, body: notif.message },
      data: {
        type: notif.type,
        jobId: notif.jobId ?? "",
        screen: notif.screen,
      },
      android: {
        priority: "high" as const,
        notification: { sound: "default", channelId: "fursafy_jobs" },
      },
      apns: {
        payload: { aps: { sound: "default", badge: 1 } },
      },
    });
  }

  if (messages.length > 0) {
    // sendEach supports up to 500 messages per call
    const chunks = [];
    for (let i = 0; i < messages.length; i += 500) {
      chunks.push(messages.slice(i, i + 500));
    }

    for (const chunk of chunks) {
      const result = await admin.messaging().sendEach(chunk);
      console.log(
        `[sendBatchNotifications] Sent ${result.successCount}/${chunk.length} FCM messages`
      );
    }
  }
}
