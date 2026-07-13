// Mock firebase-admin first to handle Jest hoisting correctly.
// All mock setup functions are self-contained inside the mock factory.
jest.mock("firebase-admin", () => {
  class MockGeoPoint {
    constructor(public latitude: number, public longitude: number) {}
  }
  
  const mockGet = jest.fn();
  const mockWhere = jest.fn().mockReturnThis();
  const mockCollection = jest.fn().mockReturnValue({
    where: mockWhere,
    get: mockGet,
    doc: jest.fn().mockReturnThis(),
    collection: jest.fn().mockReturnThis(),
  });

  const mockBatchSet = jest.fn();
  const mockBatchCommit = jest.fn().mockResolvedValue(null);
  const mockBatch = jest.fn().mockReturnValue({
    set: mockBatchSet,
    commit: mockBatchCommit,
  });

  const mockFirestoreInstance = {
    collection: mockCollection,
    batch: mockBatch,
  };

  const firestoreFn = jest.fn().mockImplementation(() => mockFirestoreInstance);
  (firestoreFn as any).GeoPoint = MockGeoPoint;
  (firestoreFn as any).FieldValue = {
    serverTimestamp: jest.fn().mockReturnValue("mock-timestamp"),
  };

  const mockSendEach = jest.fn().mockResolvedValue({ successCount: 1, failureCount: 0 });
  const mockSendEachForMulticast = jest.fn().mockResolvedValue({ successCount: 1 });

  return {
    initializeApp: jest.fn(),
    firestore: firestoreFn,
    messaging: jest.fn().mockImplementation(() => ({
      sendEach: mockSendEach,
      sendEachForMulticast: mockSendEachForMulticast,
    })),
  };
});

import { haversineKm } from "../src/utils/haversine";
import * as admin from "firebase-admin";
import { matchingEngine } from "../src/matchingEngine";

describe("Haversine Proximity Calculation", () => {
  it("calculates 0 for identical coordinates", () => {
    const p1 = new admin.firestore.GeoPoint(-6.8140, 39.2800);
    const distance = haversineKm(p1, p1);
    expect(distance).toBe(0);
  });

  it("calculates correct distance between Dar es Salaam and Masaki", () => {
    const p1 = new admin.firestore.GeoPoint(-6.8140, 39.2800);
    const p2 = new admin.firestore.GeoPoint(-6.7900, 39.2500);
    const distance = haversineKm(p1, p2);
    // Approximately 4.25 km
    expect(distance).toBeGreaterThan(4.1);
    expect(distance).toBeLessThan(4.4);
  });
});

describe("Matching Engine Cloud Function", () => {
  let db: any;
  let mockCollection: jest.Mock;
  let mockGet: jest.Mock;
  let mockWhere: jest.Mock;
  let mockBatchSet: jest.Mock;
  let mockBatchCommit: jest.Mock;

  beforeEach(() => {
    // Clear and retrieve mock functions from the mocked firebase-admin instance
    db = admin.firestore();
    mockCollection = db.collection as jest.Mock;
    mockGet = db.collection("dummy").get as jest.Mock;
    mockWhere = db.collection("dummy").where as jest.Mock;
    mockBatchSet = db.batch().set as jest.Mock;
    mockBatchCommit = db.batch().commit as jest.Mock;

    // Clear call histories from setup invocations
    mockCollection.mockClear();
    mockGet.mockClear();
    mockWhere.mockClear();
    mockBatchSet.mockClear();
    mockBatchCommit.mockClear();
  });

  it("skips execution if job status is not open", async () => {
    const mockEvent = {
      data: {
        data: () => ({
          status: "closed",
          title: "Test Closed Job",
        }),
      },
      params: {
        jobId: "job_123",
      },
    };

    await matchingEngine.run(mockEvent as any);
    expect(mockCollection).not.toHaveBeenCalled();
  });

  it("matches and notifies overlapping skill candidates within range", async () => {
    // Job located at Dar es Salaam (-6.8140, 39.2800) requiring Plumbing
    const mockEvent = {
      data: {
        data: () => ({
          status: "open",
          title: "Leaking Sink Repair",
          skillsRequired: ["Plumbing"],
          location: new admin.firestore.GeoPoint(-6.8140, 39.2800),
          payAmount: 15000,
        }),
      },
      params: {
        jobId: "job_123",
      },
    };

    // Mock candidates query docs:
    // candidate 1: Plumbing, within 10 km (location -6.8100, 39.2700) -> should match
    // candidate 2: Plumbing, too far (location -6.7500, 39.1000) -> filtered out by distance
    const mockProfiles = [
      {
        id: "youth_close",
        data: () => ({
          skills: ["Plumbing"],
          location: new admin.firestore.GeoPoint(-6.8100, 39.2700),
          ratingAvg: 4.8,
          availabilityStatus: "available",
          fcmToken: "token_close",
        }),
      },
      {
        id: "youth_far",
        data: () => ({
          skills: ["Plumbing"],
          location: new admin.firestore.GeoPoint(-6.7500, 39.1000),
          ratingAvg: 4.5,
          availabilityStatus: "available",
          fcmToken: "token_far",
        }),
      },
    ];

    mockGet.mockResolvedValueOnce({
      docs: mockProfiles,
    });

    // Mock user FCM lookup during notifications lookup
    const mockUserDoc = {
      data: () => ({
        fcmToken: "token_close",
      }),
    };
    mockGet.mockResolvedValueOnce(mockUserDoc); // for youth_close lookup

    await matchingEngine.run(mockEvent as any);

    // Expecting query for available profiles with skills
    expect(mockWhere).toHaveBeenCalledWith("skills", "array-contains-any", ["Plumbing"]);
    
    // Expecting batch writing for notifications collection
    expect(mockBatchSet).toHaveBeenCalled();
    expect(mockBatchCommit).toHaveBeenCalled();
  });
});
