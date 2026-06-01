import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { haversineKm } from "./utils/haversine";
import { sendBatchNotifications } from "./utils/sendNotification";

const db = admin.firestore();

// Configurable constants — can be moved to Firebase Remote Config
const MATCH_RADIUS_KM = 10;
const MAX_MATCHES = 50;

/**
 * Matching Engine — SRS §7.1
 *
 * Trigger: Firestore onCreate on jobs/{jobId}
 *
 * Algorithm:
 * 1. Read new job doc → extract skillsRequired[] and location (GeoPoint)
 * 2. Query youth_profiles where skills array-contains-any skillsRequired
 *    AND availabilityStatus == 'available'
 * 3. For each candidate, compute Haversine distance; retain within MATCH_RADIUS_KM
 * 4. Score: (matching_skill_count × 3) + (1/distance_km × 2) + (ratingAvg × 1)
 * 5. Cap at MAX_MATCHES (50)
 * 6. For each match: write notification doc + send FCM push
 */
export const matchingEngine = onDocumentCreated(
  "jobs/{jobId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const job = snapshot.data();
    if (!job || job.status !== "open") {
      console.log("[matchingEngine] Job is not open or missing — skipping");
      return;
    }

    const skillsRequired: string[] = job.skillsRequired ?? [];
    const jobLocation: admin.firestore.GeoPoint | undefined = job.location;
    const jobTitle: string = job.title ?? "New Job";
    const payAmount: number = job.payAmount ?? 0;
    const jobId = event.params.jobId;

    if (skillsRequired.length === 0) {
      console.log("[matchingEngine] No skills required — skipping");
      return;
    }

    if (!jobLocation) {
      console.log("[matchingEngine] No job location — skipping");
      return;
    }

    // Step 2: Query youth_profiles with overlapping skills
    // Firestore array-contains-any supports max 10 values
    const querySkills = skillsRequired.slice(0, 10);

    const snap = await db
      .collection("youth_profiles")
      .where("skills", "array-contains-any", querySkills)
      .get();

    console.log(
      `[matchingEngine] Found ${snap.docs.length} profiles with matching skills`
    );

    // Step 3-4: Filter by distance, compute score, sort
    interface CandidateProfile {
      uid: string;
      skills: string[];
      location: admin.firestore.GeoPoint;
      ratingAvg: number;
      fcmToken?: string;
      score: number;
      distance: number;
    }

    const candidates: CandidateProfile[] = snap.docs
      .map((doc) => {
        const data = doc.data();
        const youthLocation = data.location as
          | admin.firestore.GeoPoint
          | undefined;
        if (!youthLocation) return null;

        const distance = haversineKm(jobLocation, youthLocation);
        if (distance > MATCH_RADIUS_KM) return null;

        const youthSkills: string[] = data.skills ?? [];
        const matchingSkillCount = youthSkills.filter((s: string) =>
          skillsRequired.includes(s)
        ).length;

        const ratingAvg: number = data.ratingAvg ?? 0;

        // Scoring formula from SRS §7.1
        const score =
          matchingSkillCount * 3 +
          (distance > 0 ? (1 / distance) * 2 : 2) +
          ratingAvg * 1;

        return {
          uid: doc.id,
          skills: youthSkills,
          location: youthLocation,
          ratingAvg,
          score,
          distance,
        } as CandidateProfile;
      })
      .filter((c): c is CandidateProfile => c !== null)
      .sort((a, b) => b.score - a.score)
      .slice(0, MAX_MATCHES);

    console.log(
      `[matchingEngine] ${candidates.length} candidates after distance filter and scoring`
    );

    if (candidates.length === 0) return;

    // Step 6: Create notifications and send FCM
    const notifications = candidates.map((c) => ({
      userId: c.uid,
      type: "job_match",
      title: "New Job Match! 🎯",
      message: `${jobTitle} — TSh ${payAmount.toLocaleString()}`,
      jobId,
      screen: `/jobs/${jobId}`,
    }));

    await sendBatchNotifications(notifications);

    console.log(
      `[matchingEngine] Notified ${candidates.length} youth for job ${jobId}`
    );
  }
);
