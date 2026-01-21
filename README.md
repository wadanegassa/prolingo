# ProLingo 🌍📚

**ProLingo** is a cutting-edge, AI-powered language learning application built with Flutter. It combines gamified lessons with an intelligent AI tutor to provide an immersive and personalized learning experience.

## 🚀 Overview

ProLingo aims to make language learning accessible, engaging, and effective. Whether you're a beginner starting from scratch or an advanced learner looking to polish your skills, ProLingo adapts to your pace. The app features a robust curriculum divided into levels, interactive exercises, and a real-time AI conversation partner powered by Google's Gemini models.

## ✨ Key Features

-   **🤖 AI Tutor**: a personalized chat interface powered by **Google Gemini**. Practice real conversations, ask grammatical questions, and get instant feedback.
-   **🎓 Structured Curriculum**:
    -   **Levels**: Progress from Basic to Intermediate and Advanced levels.
    -   **Units & Lessons**: Bite-sized lessons covering vocabulary, grammar, and pronunciation.
-   **🎮 Interactive Exercises**:
    -   Multiple-choice questions.
    -   Fill-in-the-blanks.
    -   Listening comprehension.
    -   🗣️ **Pronunciation Practice**: Real-time speech recognition to test your speaking skills.
-   **🏆 Gamification**:
    -   Earn **XP** and track your progress.
    -   Unlock achievements and levels.
    -   🎉 **Celebratory Animations**: Confetti effects upon completing milestones.
-   **🔐 Secure Authentication**: User sign-up, login, and profile management using **Firebase Auth**.
-   **📊 Progress Tracking**: Visual representation of your learning journey with "Saga Maps" and statistics.

## 🛠️ Tech Stack & Tools

ProLingo is built using a modern mobile development stack:

### Frontend
-   **[Flutter](https://flutter.dev/)**: Google's UI toolkit for building natively compiled applications.
-   **Dart**: The programming language used for Flutter.

### Backend & Services
-   **[Firebase](https://firebase.google.com/)**:
    -   **Authentication**: Secure user management.
    -   **Cloud Firestore**: NoSQL database for storing user progress, lessons, and content.
    -   **Cloud Functions**: Serverless backend logic.
-   **[Google Generative AI (Gemini)](https://ai.google.dev/)**: Powers the intelligent AI conversational tutor.

### Key Libraries & Packages
-   **State Management**: `provider` for efficient state management across the app.
-   **AI Integration**: `google_generative_ai` for accessing Gemini models.
-   **Speech**: `speech_to_text` for voice input and pronunciation verification.
-   **UI/UX**:
    -   `animations` for smooth transitions.
    -   `flutter_svg` for scalable vector graphics.
    -   `google_fonts` for beautiful typography.
    -   `confetti` for reward animations.
-   **Utilities**: `shared_preferences` for local storage, `intl` for localization support.

## 📱 Installation & Setup

Follow these steps to run ProLingo locally:

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   A [Firebase](https://console.firebase.google.com/) project set up.
-   An API Key for [Google Gemini](https://ai.google.dev/).

### Steps

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/prolingo.git
    cd prolingo
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    -   Install the Firebase CLI and run `flutterfire configure` to connect your app to your Firebase project.
    -   Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are generated in the respective directories.

4.  **Environment Variables (Optional/If implemented)**
    -   If the app uses an `.env` file for API keys, create one and add your Gemini API key:
        ```
        GEMINI_API_KEY=your_api_key_here
        ```
    -   *Note: Ensure you have a valid method for supplying the API key to the `GenerativeModel`.*

5.  **Run the App**
    ```bash
    flutter run
    ```

## 🤝 Contributing

Contributions are welcome! If you'd like to improve ProLingo, feel free to fork the repository and submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
