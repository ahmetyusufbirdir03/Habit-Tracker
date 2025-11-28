importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Firebase config
firebase.initializeApp({
  apiKey: "AIzaSyCvQvD_kn5s-hlJ_CYAwa6mHtVEh9KjYTY",
    authDomain: "habittracker-80f5f.firebaseapp.com",
    projectId: "habittracker-80f5f",
    storageBucket: "habittracker-80f5f.firebasestorage.app",
    messagingSenderId: "263402661018",
    appId: "1:263402661018:web:71e8fd66f24e6ebdf42b23",
    measurementId: "G-BGWR6Q0TNC"
});

// Retrieve Firebase Messaging object
const messaging = firebase.messaging();

// Arka planda push mesajları için
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title || 'Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
