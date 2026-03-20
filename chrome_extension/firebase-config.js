const FIREBASE_AUTH_CONFIG = {
  apiKey: "AIzaSyAZLcKDWaG6uh71a2iRMX4sil1WPbpDVzw",
  projectId: "cpp-aihackathon"
};

const FIREBASE_AUTH_ENDPOINTS = {
  signIn: `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_AUTH_CONFIG.apiKey}`,
  signUp: `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${FIREBASE_AUTH_CONFIG.apiKey}`,
  resetPassword: `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${FIREBASE_AUTH_CONFIG.apiKey}`,
  lookup: `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${FIREBASE_AUTH_CONFIG.apiKey}`
};
