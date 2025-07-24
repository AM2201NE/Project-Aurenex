# Neonote Requirements Analysis

## Overview
Neonote is a fully offline, server-free Notion clone with comprehensive features including block editing, database functionality, AI assistance, graph view, and cross-platform support. The application must be production-ready and follow Apple's UI design style.

## Platforms & Frameworks
- **Primary Framework**: Flutter for cross-platform support (Windows, macOS, Linux, Android, iOS, iPadOS)
- **Optional Backend**: Tauri/Rust for advanced desktop plugins (high-performance SQLite watchers, file watchers)
- **Single Codebase**: No extra native projects, unified experience across all platforms

## Storage & File Model
- **Page Structure**: 
  - `page.md` file with YAML front-matter (title, tags, created, updated)
  - `assets/` subfolder for all attachments
- **Database**: SQLite for indexing blocks, full-text search, tags, backlinks, embeddings, sync groups, comments
- **Version Control**: Git integration for automatic change tracking and commit history access

## Block Types (35+)
- **Text Blocks**:
  - Paragraph
  - Heading (levels 1-3)
  - Quote
  - Callout
  - Divider
  - Table of contents
- **List Blocks**:
  - Bulleted list item
  - Numbered list item
  - To-do item
  - Toggle list
- **Layout Blocks**:
  - Column list → column (with adjustable ratio via drag)
- **Database Blocks**:
  - Child database
  - Table → table row → table cell
- **Media & Embed Blocks**:
  - Images (PNG, JPEG, GIF, SVG, WebP, HEIC) with thumbnail generation
  - Photos, screenshots, GIFs
  - Audio (MP3, WAV, AAC, OGG) with waveform previews
  - Video (MP4, WebM, MOV) with thumbnail and embedded player
  - Files (PDF, DOCX, XLSX, PPTX) with appropriate viewers
  - Bookmark, embed, link preview, website embeds
- **Advanced Blocks**:
  - Synced block (shared sync-group ID, live mutual updates)
  - Template
  - Child page
  - Link to page
  - Breadcrumb
  - Unsupported block placeholder
- **Special Blocks**:
  - Code (with language tag highlighting)
  - Equation (LaTeX)
  - Support for future block types via auto-mapping

## Link Handling
- **Internal Links**: 
  - `/page_id` or `[[Page Title]]` format
  - Auto-complete in editor
  - Backlinks table
  - Graph visualization
- **Tags**: 
  - `#TagName` format
  - Tag indexing
  - Filtering
  - Graph node representation
- **External Links**:
  - `[Label](URL)` format
  - Bare `https?://...` links
  - Automatic bookmark cards
- **Notion API Integration**:
  - Fetch page content, media, comments
  - Place comments in custom "Comment" blocks at correct locations

## Markdown Round-Trip
- **Import**:
  - Parse Notion Markdown export (with YAML front-matter)
  - Convert to block model
  - Handle all media references
- **Export**:
  - Serialize to Markdown
  - Custom fences for columns, callouts, synced blocks, Mermaid, embeds
  - Standard syntax for lists, tables, code, LaTeX
- **Live Preview**:
  - Use `flutter_markdown` with plugins
  - Mirror Notion CSS (fonts, spacing, colors, icons, callout styling)

## AI Assistant "VibeAI"
- **Model**: 
  - Qwen2.5:7b via Ollama
  - Converted to GGUF and quantized (q4_0) for offline inference
  - Integrate the previously optimized model pipeline
- **Capabilities**:
  - Instruction-tuned
  - 128K context window
  - Multilingual support
  - Coding/math tasks
  - JSON-structured outputs
- **Multimodal Support**:
  - Accept text, base64 images/audio
  - Output text and speech
- **Features**:
  - Summarization
  - Translation
  - Rephrasing
  - Brainstorming
  - Code generation
  - Mermaid diagram creation
- **Embedding & RAG**:
  - Compute embeddings
  - Store in SQLite
  - Power "Related pages" with HNSW ANN index
- **Networking Modes**:
  - Local Only Mode: Inference from local model, no network calls
  - Online Assist Mode: Fetch Google search results or call Notion API
  - Runtime switching: Toggle between modes mid-chat

## Graph View & Mermaid
- **Graph Visualization**:
  - Interactive force-directed using `flutter_graph_view` or D3.js
  - Pan/zoom functionality
  - Lazy subgraphs
  - Tag/date filters
- **Mermaid Integration**:
  - Inline code blocks rendered via Mermaid.js
  - Styled as Notion panels

## End-User Customization
- **Style Panel**:
  - Fonts
  - Colors
  - Block spacing
  - Callout icons
  - Grid layouts
  - Persistence per page
- **Plugins/Themes**:
  - Sandboxed JS/CSS API
  - Rust/Tauri extension points
- **Templates & Databases**:
  - In-app template editor
  - Database schema editor identical to Notion
- **Shortcuts**:
  - Replicate Notion's keyboard shortcuts
  - Support for all block operations and navigation
  - Platform-specific adaptations

## UI Design
- Follow Apple UI design style as in the Neonote Vibe Flow GitHub project
- Incorporate the provided blue/purple lotus icon as the app logo
- Ensure consistent styling across all platforms while maintaining native feel

## API Integration
- **Notion API Key Management**:
  - Input field for API key
  - Save with custom user-defined name
  - Select and switch between saved keys
  - Preview Notion pages within the app

## File Export Structure
- **Hierarchical Export**:
  ```
  [Selected Export Directory]/
  ├── My_Page_Title_1/          # Folder named after the Notion page
  │   ├── My_Page_Title_1.md    # Markdown file with page content
  │   └── media/                # Media folder for this page
  │       ├── image1.jpg
  │       ├── video.mp4
  │       └── document.pdf
  ├── My_Page_Title_2/
  │   ├── My_Page_Title_2.md
  │   └── media/
  │       └── ...
  └── ...
  ```
- Include all tags at the top of each exported Markdown file
- Embed comments into custom blocks, positioned as in Notion

## Additional Features
- **Notifications**:
  - Background page syncing on all devices
  - Task progress in notification center (non-removable until stopped/paused)
  - App logo in notifications
  - Controls to stop, pause, or resume tasks
- **Widgets**:
  - Cross-platform widget support
  - Direct AI access widget
  - Voice interaction with "Neonote" wake word
  - Siri-style animation on activation
  - Apple design aesthetic for interface
- **Language Support**:
  - All languages except Hebrew for UI and AI
  - AI responses matching user's input language
- **AI Modes**:
  - Local Data Mode: Responses based on user-selected local data
  - Cloud Data Mode: Fetch from Notion API or Google Drive
  - Search Mode: Fetch answers from Google
  - Mid-conversation mode switching

## Code Quality & CI/CD
- **Module Structure**:
  - `models/blocks.dart`
  - `storage/`
  - `ui/blocks/`
  - `ui/ai/`
  - `graph/`
  - `md/`
  - `plugins/`
  - `ci/`
- **Testing**:
  - Unit tests
  - Integration tests
  - Coverage for parsing, widget rendering, import/export, AI prompts, online toggles
- **CI Pipeline**:
  - GitHub Actions matrix for all platforms
  - Auto-download and convert Qwen2.5:7b
  - Build binaries
  - Run tests
  - Package installers
- **Documentation**:
  - Detailed README
  - Setup, build, packaging instructions
  - Example pages/assets for all features

## Delivery Requirements
- Complete Flutter project as a single download
- All code, configurations, tests, and documentation included
- Embedded AI models and dependencies
- Production-ready, fully functional on all platforms
- Immediately testable and deployable
