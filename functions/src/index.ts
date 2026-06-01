import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK (must be called before any other admin calls)
admin.initializeApp();

// ─── Matching Engine (SRS §7.1) ───
// Fires on new job creation → matches youth by skills + location → sends FCM
export { matchingEngine } from "./matchingEngine";

// ─── Application Status Notification (SRS §7.3) ───
// Fires on application status change → notifies youth of accept/reject
export { applicationStatusNotification } from "./applicationStatusNotification";

// ─── New Application Notification ───
// Fires on new application creation → notifies job provider
export { newApplicationNotification } from "./applicationStatusNotification";

// ─── Rating Notification (SRS §3.7 / FR-35) ───
// Fires on new rating → notifies the ratee
export { ratingNotification } from "./ratingNotification";
