# Dyslexify 🧠📱

**Dyslexify** is a Flutter-based mobile application designed for early detection and support of dyslexia using machine learning, interactive assessments, and informative resources.

---

## ✨ Features

- 📸 Image-based Dyslexia Detection (MRI & Handwriting)
- 🔒 Secure Firebase Authentication
- 📄 Personalized PDF Reports
- 🧠 Educational Resources & Tips
- 📊 Prediction History
- 🌐 Clean and Intuitive UI

---

## 📱 Screens Overview

- **Signup/Login Screens** – Secure registration and login via Firebase
- **Home Dashboard** – Navigate to key features
- **MRI & Handwriting Upload** – Submit images for ML prediction
- **Results Screen** – View dyslexia probability
- **Report PDF Generator** – Download personalized results
- **Educational Tips Page** – Learn techniques to help with dyslexia
- **FAQs** – Common questions answered
- **Settings/Logout** – Manage your session

---

## 🧰 Tech Stack

- **Flutter** (UI)
- **Dart** (Language)
- **Firebase** (Auth, Firestore, Storage)
- **Python** (ML Model – external API)
- **Flask** or **FastAPI** (Backend ML server)

---

## 🔧 Project Setup (For Developers)

### 1. Clone the Repository

```bash
git clone https://github.com/Mahanoorfarooq/FinalYearProjectDyslexia.git
cd FinalYearProjectDyslexia
````

### 2. Install Flutter Dependencies

```bash
flutter pub get
flutter run
```

### 3. Configure Firebase

Set up Firebase for Android and iOS:

#### Android

* Place your `google-services.json` in `android/app/`

#### iOS

* Place your `GoogleService-Info.plist` in `ios/Runner/`

Ensure these Firebase services are enabled:

* Authentication
* Cloud Firestore
* Firebase Storage

### 4. Firebase Firestore Rules

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /predictionsHandwriting/{predictionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /predictionsMRI/{predictionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📦 Running the App

Make sure an emulator or physical device is connected.

```bash
flutter run
```

## 🌐 ML Model API

The app communicates with an external Python API to perform predictions.
In your ML backend file, change the IP to your LocalHost IP and then run the backend files and then the app. Place ML Models in .h5 or tfite in yout backend folder and make sure main file in backend includes these two endpoints.

* `POST /predict_mri`
* `POST /predict_handwriting`
* `python app.py`

Response format (JSON):

```json
{
  "result": "Likely dyslexic",
  "confidence": 87.5
}
```

---

## 👩‍💼 User Manual

### 1. **Sign Up**

* Open the app.
* Tap **Sign Up**, enter your name, email, and password.

### 2. **Log In**

* Use your registered email and password.

### 3. **Upload MRI / Handwriting**

* Navigate to **Upload MRI** or **Upload Handwriting**.
* Pick an image from your gallery or camera.
* Submit it to get a prediction.

### 4. **View Results**

* View a result like:

  > "87.5% confidence of dyslexia"

### 5. **Download Report**

* Tap **Generate PDF** to download a report containing:

  * Full name
  * Date
  * Uploaded image
  * Prediction

### 6. **Explore Dyslexia Tips**

* Read curated tips and techniques on the **Tips** page.

### 7. **Check FAQs**

* Navigate to the FAQ section for common questions.

### 8. **Log Out**

* Use the navigation drawer to securely log out.

---

## 🧪 Testing Instructions

You can test with:

* Sample MRI brain scan images
* Children’s handwriting samples

---

## 📸 Sample Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/4a7fbfe0-4314-4c3a-89d8-bfc8a9cb0173" alt="Screenshot 1" width="300"/>
  <img src="https://github.com/user-attachments/assets/57c07488-16f1-4da8-b77d-17a8f13b17e0" alt="Screenshot 2" width="300"/>
  <img src="https://github.com/user-attachments/assets/b061bb3d-4db9-401d-981c-368f7fe6431f" alt="Screenshot 3" width="300"/>
  <img src="https://github.com/user-attachments/assets/0ee81e06-b3d6-40ef-8d0a-e2217f0f9991" alt="Screenshot 4" width="300"/>
  <img src="https://github.com/user-attachments/assets/ea646118-704d-460f-8db6-3985607bc700" alt="Screenshot 5" width="300"/>
</p>


--

--

```


