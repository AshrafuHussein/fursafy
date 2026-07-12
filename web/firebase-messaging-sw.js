importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCfW1Nf_NrVLzWB0M2plmEIJ7JKN_SNRg0",
  authDomain: "fursafy.firebaseapp.com",
  projectId: "fursafy",
  storageBucket: "fursafy.firebasestorage.app",
  messagingSenderId: "621661779995",
  appId: "1:621661779995:web:1f812ff987e7d574ca20be"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
});
