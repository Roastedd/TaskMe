# Productivity RPG App: "TaskQuest" - Feature Breakdown

## Core Concept
A productivity app combining task management with RPG mechanics. Users complete real-world tasks to gain EXP, level up characters, and engage in turn-based combat mini-games during breaks. Built with Flutter + Flame for game elements.

---

## App Flow & Key Features

### 1. Onboarding & Character Creation
**Flow:**
- Welcome screen → Signup/Login → Class selection → Initial stat allocation

**Features:**
- **Class System:** 
  - Warrior (Focus on physical tasks)
  - Mage (Focus on mental/cognitive tasks)
  - Rogue (Focus on quick/short tasks)
- **Stat Allocation:** 
  - Strength (Physical workouts)
  - Intelligence (Study/learning tasks)
  - Dexterity (Quick tasks)
  - Stamina (Long focus sessions)

### 2. Main Dashboard (Productivity Hub)
**Flow:** 
Dashboard → Add Task → AI Priority List → Focus Mode

**Features:**
- **AI-Prioritized Task List**
  - Machine learning sorts tasks by deadline/importance
  - Visualized as "quest board" with RPG-style quest cards
- **Task Input Options:**
  - Quick-add (Title + Estimated EXP)
  - AI Chat ("Help me break down project X into tasks")
- **Character Status Panel** 
  - Shows current level/EXP
  - Equipment visualization
  - Health/MP bars tied to focus stamina

### 3. Focus Mode (Core Productivity)
**Flow:** 
Start Focus → Combat Mini-Game (Optional) → Timer → Session Complete

**Features:**
- **Focus Session Types:**
  - Pomodoro (25min work/5min break)
  - Deep Work (90min session)
  - Custom Timer
- **RPG Integration:**
  - Earn EXP based on session duration/task complexity
  - Risk/reward system: Longer sessions = better rewards but harder enemies
- **Flame-Powered Mini-Games:**
  - "Enemy of Distraction" combat during breaks
  - Bullet-hell style focus challenges
  - Touch-based spell casting mini-games

### 4. Progression & Combat System
**Core Loop:** 
Complete Tasks → Gain EXP → Level Up → Fight Enemies → Get Gear → Repeat

**Features:**
- **Leveling System**
  - Stat growth based on task types:
    - Coding tasks → +Intelligence
    - Workout tasks → +Strength
  - Skill tree unlocks (Productivity bonuses + combat skills)
- **Turn-Based Combat (Flame Engine)**
  - Enemies represent procrastination types:
    - "Notification Troll" (Social media)
    - "Anxiety Dragon"
    - "Lazy Slime"
  - Combat mechanics:
    - Dodge bullet-hell patterns (Undertale-style)
    - Use skills earned through productivity
    - Loot system for power-ups

### 5. Customization & Social
**Features:**
- **Character Customization**
  - Unlock armor/weapons through productivity
  - Cosmetic rewards for streaks
- **Guild System**
  - Join productivity groups
  - Shared goals & boss battles
- **Leaderboards**
  - Daily/weekly productivity rankings
  - Combat challenge ladders

---

## Technical Implementation

### Flutter UI Components
- **Standard Screens:**
  - Authentication (Supabase)
  - Dashboard (Custom animated widgets)
  - Task Management (Drag-and-drop quest board)
- **Flame Game Components:**
  - Combat Arena (GameWidget overlay)
  - Character Animation System
  - Bullet-hell engine

### Backend Structure
- **Supabase Backend:**
  - Authentication (Email/Google)
  - Real-time Database
  - Storage for assets and user content
  - Edge Functions for complex operations
  - Row Level Security (RLS) for data protection
- **AI Features:**
  - Task prioritization (Supabase Edge Functions)
  - NLP for chat-based task creation

### State Management
- Riverpod for app state
- Separate game state management for Flame components

---

## Art Style & UX
- **Visual Theme:** 
  - Retro RPG (16-bit) meets modern minimalism
  - Dark mode default with optional themes
- **Sound Design:** 
  - Chiptune background music
  - SFX for task completion/combat
- **Haptic Feedback:** 
  - Subtle vibrations for EXP gains
  - Strong feedback for combat hits

---

## Roadmap Suggestions
1. MVP with basic task management + EXP system
2. Implement Flame combat prototype
3. Add AI task prioritization
4. Build social/guild features
5. Create seasonal content/events

---

## Current Implementation Status

### Core Features Implemented
- **Authentication System**
  - Email/password login and registration
  - Google OAuth integration
  - Password reset functionality
  - Secure session management

- **Task Management**
  - Create, edit, and delete tasks (called "Tallies")
  - Daily, weekly, monthly, and yearly reset intervals
  - Custom tracking days (specific days of the week)
  - Progress tracking with daily values

- **User Experience**
  - Dark mode / light mode toggle
  - Weekly calendar view with date selection
  - Animated UI components
  - Confetti celebration on task completion

- **Timer Functionality**
  - Custom countdown timer
  - Recent timer presets
  - Visual timer progress indicator
  - Timer notifications

- **RPG Elements**
  - XP system with level progression
  - Task completion rewards
  - Level-based unlocks (colors, max tasks)

- **Data Management**
  - Local storage for offline usage
  - Supabase integration for cloud sync
  - User preferences persistence

### Technical Implementation
- **State Management**
  - Provider pattern for app-wide state
  - Efficient UI updates with ChangeNotifier
  
- **Error Handling**
  - Robust error handling for data operations
  - Fallback mechanisms for network issues
  - Logging system for debugging

- **Performance Optimizations**
  - Efficient data loading and saving
  - Optimized UI rendering with animations
