# 🌸 HerHub: The Intelligent Women's Health Companion

[![Download on the App Store](https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83)](https://apps.apple.com/in/app/herhub/id6760648593)

<div align="center">
 <img width="1024" height="1024" alt="herhub_community_banner_1781075124473" src="https://github.com/user-attachments/assets/87b56223-8978-4cd9-b59b-1953023f5248" />

  <br>
  <i>Empowering women through data-driven health insights and community support.</i>
</div>

---

## 📌 Project Overview
**HerHub** is a privacy-first iOS application designed to revolutionize women's health tracking. Moving beyond basic calendar estimations, HerHub leverages on-device Machine Learning (CoreML) to analyze comprehensive lifestyle data, delivering precise cycle predictions, actionable health forecasts, and a safe, moderated community platform. 

The app operates on a strict **Privacy-First** architecture, allowing full offline usage via Guest Mode, ensuring sensitive health data never leaves the user's device unless explicitly synced to encrypted cloud servers.

---

## 👩‍💻 My Role & Contributions
*This application was built collaboratively by a team of four at the iOS Development Center. I played a critical hybrid role across Design, Product Strategy, and iOS Engineering, specifically owning the following areas:*

* 🎨 **UI/UX Design (Figma):** Spearheaded the visual identity and user experience for HerHub. Designed the complete end-to-end user interface in Figma, ensuring a modern, intuitive, and highly accessible aesthetic tailored specifically for a women's health application.
* 💻 **Software Engineering (iOS/Community):** Solely owned and developed the entire "Community" ecosystem within the app. I built the frontend architecture for forums, post creation, and dynamic commenting, while also implementing critical backend integrations like automated profanity filtering and user reporting systems to ensure a safe environment.
* 📈 **Product Pitching & Business Strategy:** Led the product presentation strategy. Designed and delivered compelling pitch decks using Keynote that effectively communicated the app's CoreML capabilities, market gap, and overall business value to stakeholders.

---

## 🧠 Core Architecture & Data Models

### 1. On-Device Machine Learning (CoreML)
HerHub utilizes two distinct predictive models processed entirely on the iPhone's Neural Engine:
- **PeriodPredictor & CyclePredictor:** Analyzes 16 personal data points including age, stress levels, caffeine intake, exercise frequency, and up to three months of historical cycle data.
- **Why On-Device?** Processing ML models locally ensures zero-latency predictions while maintaining absolute compliance with medical data privacy standards.

### 2. Bio-Capacity Algorithm
A proprietary scoring engine that outputs a daily capacity score from `0 to 100`. The algorithm compares a user's theoretical hormonal baseline (based on their current cycle phase: Menstrual, Follicular, Ovulation, Luteal) against real-world daily check-in data (sleep debt, stress metrics) to calculate realistic daily energy limits.

### 3. Smart Lateness Analysis
A diagnostic logic tree that cross-references user conditions (e.g., PCOS) with recent behavioral anomalies (e.g., intense exercise spikes or sleep deprivation) to provide intelligent explanations for delayed cycles.

---

## ✨ Key Product Features

* **📅 7-Day Health Forecast:** Proactive insights into upcoming cycle phases, fertility windows, expected energy levels, and mood outlooks.
* **📝 Smart Daily Check-Ins:** A frictionless morning logging system tracking stress, sleep, and symptoms to constantly train and refine the user's local ML model.
* **💬 Safe & Supportive Community:** Dedicated forums for women to connect. Protected by a real-time profanity filter and a robust one-tap reporting system for immediate moderation.
* **📚 Personalized Resources:** An expert-backed library of articles across Health, Wellness, and Fitness. The content algorithm dynamically prioritizes articles based on medical conditions indicated during onboarding.

---

## 🛠️ Technology Stack
* **Frontend:** Swift, SwiftUI, UIKit
* **Design & Prototyping:** Figma, Keynote
* **Machine Learning:** CoreML, CreateML
* **Backend & Database:** Supabase (PostgreSQL), Encrypted Cloud Sync
* **Architecture:** MVVM (Model-View-ViewModel)

---

<div align="center">
  <b>Developed with ❤️ by Driksha Thakur, Dhruv Dogra, Mahika Behal, and Nihar Sandhu at Chitkara University (2026)</b>
</div>
