# YouTube player: release privacy findings

Assessment dated 2026-10-28. The last saved local checkpoint records both App Store Connect privacy questionnaires as complete, OnlyWeights App Privacy as published by the owner and OnlyBody as unpublished. These records were reconciled on 2026-10-31 without a new live App Store Connect check. This is a conservative disclosure assessment from published Google policies, not a packet capture or a configuration-specific statement from Google.

See `../Artifacts/2026-10-28-store-audit/privacy-field-decisions.txt` for field-by-field decisions and sources. Device ID (web identifiers, not native IDFA), coarse location, product interaction and advertising data are disclosed for functionality, analytics and third-party advertising, linked and used for tracking. Other diagnostic data is disclosed for functionality and analytics, linked but not tracking. On-device workout and health records are not uploaded by the apps.

Build 1.0 (2) introduces App Tracking Transparency before any embedded YouTube player is created, in addition to versioned local consent. Denial and restriction leave exercises, workouts and an external Watch on YouTube link available. Returning to the foreground rechecks system authorization. The view removes its embedded player while inactive. Old local consent is invalidated by notice version 2.

The public policy update removes unsupported guarantees about non-personalized processing and explains permission and external playback. Website-only commit: 9feadc7. Deployment must be verified separately; a successful Git push does not establish public availability.

Primary sources consulted:
- https://policies.google.com/technologies/partner-sites
- https://policies.google.com/privacy
- https://policies.google.com/technologies/cookies?hl=en
- https://support.google.com/youtube/answer/132596?hl=en
- https://support.google.com/youtube/answer/171780?hl=en
- https://developer.apple.com/app-store/app-privacy-details/
- https://developer.apple.com/app-store/user-privacy-and-data-use/

Remaining evidence limitations: current physical-iPhone playback and each video's complete audio, provenance/license and Made for Kids assessment are not established by simulator tests or this privacy analysis. Historical per-video records remain partial. Do not describe the complete media checklist as passed or infer that every field is collected in every playback session.
