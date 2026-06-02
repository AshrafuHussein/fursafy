import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { sendNotification } from "./utils/sendNotification";

const db = admin.firestore();

/**
 * Application Status Notification — SRS §7.3
 *
 * Trigger: Firestore onUpdate on applications/{appId}
 * Logic: If status changed to 'accepted' or 'rejected',
 * send FCM notification to youth and write to notifications/{youthId}/items
 */
export const applicationStatusNotification = onDocumentUpdated(
  "applications/{appId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const oldStatus = before.status as string;
    const newStatus = after.status as string;
    const appId = event.params.appId;

    // Only fire when status actually changes
    if (oldStatus === newStatus) return;

    const youthId = after.youthId as string | undefined;
    const jobId = after.jobId as string | undefined;

    if (!youthId) {
      console.log(
        "[applicationStatusNotification] No youthId on application — skipping"
      );
      return;
    }

    // Get job title for the notification message
    let jobTitle = "a job";
    if (jobId) {
      try {
        const jobDoc = await db.collection("jobs").doc(jobId).get();
        jobTitle = (jobDoc.data()?.title as string) ?? "a job";
      } catch (_) {
        // Ignore — use fallback title
      }
    }

    if (newStatus === "accepted") {
      await sendNotification({
        userId: youthId,
        type: "application_accepted",
        title: "Application Accepted! 🎉",
        message: `Congratulations! Your application for "${jobTitle}" has been accepted.`,
        jobId: jobId,
        applicationId: appId,
        screen: `/applications/${appId}`,
      });
      console.log(
        `[applicationStatusNotification] Notified youth ${youthId} — accepted`
      );
    } else if (newStatus === "rejected") {
      await sendNotification({
        userId: youthId,
        type: "application_rejected",
        title: "Application Update",
        message: `Your application for "${jobTitle}" was not selected this time. Keep applying!`,
        jobId: jobId,
        applicationId: appId,
        screen: `/applications/${appId}`,
      });
      console.log(
        `[applicationStatusNotification] Notified youth ${youthId} — rejected`
      );
    }
  }
);

/**
 * New Application Notification — notifies provider when a youth applies.
 *
 * Trigger: Firestore onCreate on applications/{appId}
 * Logic: Read the providerId from the related job, send notification to provider.
 */
export const newApplicationNotification = onDocumentCreated(
  "applications/{appId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const application = snapshot.data();
    const jobId = application.jobId as string | undefined;
    const youthId = application.youthId as string | undefined;

    if (!jobId || !youthId) {
      console.log(
        "[newApplicationNotification] Missing jobId or youthId — skipping"
      );
      return;
    }

    // Get the job to find the provider
    const jobDoc = await db.collection("jobs").doc(jobId).get();
    const jobData = jobDoc.data();
    if (!jobData) return;

    const providerId = jobData.providerId as string | undefined;
    const jobTitle = (jobData.title as string) ?? "your job";

    if (!providerId) {
      console.log(
        "[newApplicationNotification] No providerId on job — skipping"
      );
      return;
    }

    // Get youth name for the message
    let youthName = "A youth";
    try {
      const userDoc = await db.collection("users").doc(youthId).get();
      youthName = (userDoc.data()?.displayName as string) ?? "A youth";
    } catch (_) {
      // Use fallback
    }

    await sendNotification({
      userId: providerId,
      type: "application_received",
      title: "New Application! 📋",
      message: `${youthName} applied for "${jobTitle}"`,
      jobId: jobId,
      applicationId: event.params.appId,
      screen: `/provider/jobs/${jobId}/applicants`,
    });

    console.log(
      `[newApplicationNotification] Notified provider ${providerId} about new application`
    );
  }
);
