# Peblo-Challenge

## Architecture & Implementation

### UIKit (Programmatic)
Built entirely with UIKit programmatically for maximum layout control, cleaner code reviews, easier maintenance, and a smaller project footprint without Storyboards.

### Transition Management
Story Mode transitions into Quiz Mode using `AVSpeechSynthesizerDelegate`. When narration finishes, the story UI fades out and is removed while the quiz view fades into the same layout space. The navigation bar and character image remain fixed to avoid layout jumps.

### Data-Driven Quiz Engine
Quiz content is powered by JSON models rather than hardcoded views. A vertical `UIStackView` dynamically renders 3–5 answer options, automatically adapting to content without constraint issues.

### Audio & State Handling
A dedicated narration state machine (`idle`, `loading`, `speaking`, `failed`) manages UI behavior.

- Loading: Displays an activity indicator and prevents duplicate taps.
- Failure: Presents a retry flow with graceful error handling and no app crashes.

### Caching Strategy
In order to retrieve the frequently accessed audio/text assets from an external API like  <code>ElevenLabs</code>, i would have stored in the cache by utilizing <code>NSCache</code> as the cache content loads instantly, resulting into reduced network request and improved responsiveness.

---

## 🛠 Performance Optimization

### Profiling & Rendering
Performance was monitored using Instruments and Core Animation tools. Layout constraints were simplified, unnecessary rendering passes were removed, and button animations were GPU-accelerated using `CGAffineTransform`.

### Optimizations
- Dynamic Auto Layout sizing instead of fixed heights.
- GPU-driven animations and shadows.
- `CAEmitterLayer` for efficient particle effects.
- Maintained smooth 60/120 FPS performance during transitions and animations.

### Lightweight Design
Visual effects are generated programmatically using Core Graphics instead of bundled image assets, reducing app size and memory usage.

---

## 🤖 AI Usage

AI was used as a development assistant to brainstorm JSON structures, animation concepts, and implementation approaches. All architectural decisions, integration, debugging, and final code were reviewed and implemented manually.
