importScripts(
  "https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"
);

importScripts(
  "https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js"
);

firebase.initializeApp({
   apiKey: 'AIzaSyBQd-uwkYEbH1Yw7ULY6fVjGFkeVp4V7_4',
    appId: '1:20625081403:android:ac3e657c5d43e94c51881e',
    messagingSenderId: '20625081403',
    projectId: 'oil-distribution-app-8b767',
    databaseURL: 'https://oil-distribution-app-8b767-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'oil-distribution-app-8b767.firebasestorage.app',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("Background Firebase message:", message);
});