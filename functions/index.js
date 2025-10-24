const functions = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentDeleted } = require("firebase-functions/v2/firestore");
const functions_v1 = require("firebase-functions");

admin.initializeApp();

const db = admin.firestore();

exports.clearChatDaily = onSchedule(
    {
        schedule: "0 0 * * *",
    },
    async (event) => {
        const snapshot = await db.collection("chat").get();
        const batch = db.batch();

        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();

        console.log(`Deleted ${snapshot.size} chat messages`);
    }
);


exports.cleanupInactiveUsers = onSchedule(
    {
        schedule: "0 0 * * *",
    },
    async (event) => {
        try {
            const firestore = admin.firestore();

            // 1. Get all Auth users
            let allAuthUsers = [];
            let nextPageToken;
            do {
                const result = await admin.auth().listUsers(1000, nextPageToken);
                allAuthUsers = allAuthUsers.concat(result.users.map(user => user.uid));
                nextPageToken = result.pageToken;
            } while (nextPageToken);

            console.log(`Total Auth users: ${allAuthUsers.length}`);

            // 2. Get all Firestore 'users' documents
            const usersSnapshot = await firestore.collection('users').get();
            let deletedCount = 0;

            for (const doc of usersSnapshot.docs) {
                const uid = doc.id;
                if (!allAuthUsers.includes(uid)) {
                    // Delete Firestore document if user does not exist in Auth
                    await firestore.collection('users').doc(uid).delete();
                    deletedCount++;
                    console.log(`Deleted Firestore user document: ${uid}`);
                }
            }

            console.log(`Cleanup completed. Deleted ${deletedCount} inactive users.`);
        } catch (error) {
            console.error("Error cleaning up inactive users:", error);
        }
    });

exports.deleteUserImage = onDocumentDeleted("users/{userId}", async (event) => {
    const deletedData = event.data?.data();

    if (!deletedData || !deletedData.image_url) {
        console.log("No image_url found, skipping deletion.");
        return;
    }

    try {
        const imageUrl = deletedData.image_url;

        // Example: gs://chat-app-rugburn.firebasestorage.app/user_images/5i5qHijV2MPsBF8BFzYxT21zZ9r1.jpg
        // Remove the prefix (gs://<bucket-name>/)
        const bucket = getStorage().bucket();
        const bucketName = bucket.name;

        const path = imageUrl.replace(`gs://${bucketName}/`, "");

        console.log(`Deleting file at path: ${path}`);
        await bucket.file(path).delete({ ignoreNotFound: true });

        console.log(`Successfully deleted image for user ${event.params.userId}`);
    } catch (error) {
        console.error("Error deleting user image:", error);
    }
});

exports.sendPushNotifications = functions.onDocumentCreated(
    "chat/{messageId}",
    (event) => {
        const data = event.data.data();
        return admin.messaging().send({
            notification: {
                title: data["username"],
                body: 'New message.',
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
            topic: "chat",
        });
    }
);
