# Kinetra - Design System

Bright, modern fitness tracking app. Light near-white surfaces, ink text, one neon chartreuse accent, a soft pink support hue. Energetic but clean: one bold focal element per screen.

## Frame
- Mobile 393x852 (iPhone 16/17). Keep the top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content.
- Screen edge padding 20px. 8pt spacing scale: 4, 8, 12, 16, 24, 32.

## Color (use ONLY these colors; no default violet or indigo, no flat neutral grey)
- Background: #FAFCF4 (tinted near-white)
- Surface (cards, sheets): #FFFFFF
- Surface alt (grouped rows, tracks): #F1F5E4
- Accent neon: #CCFF00 - large fills, rings, active pill, primary button fill WITH INK LABEL #1C1F0C, chart highlight. Never white text on neon.
- Accent fill (dark olive): #647D00 - text links, chips text, progress bar fill, buttons with white label.
- Accent tint: #F8FFDB - chip backgrounds, selected states.
- Accent pressed: #586E00
- Ink: #1C1F0C - primary text, dark hero cards (ink background with neon numbers and white text), dark buttons.
- Text secondary: #4B5034. Text tertiary: #6A6F52.
- Border hairline: #E2E7D2. Input and control border (borderStrong): #92975F.
- Support pink: #FF9BD2 (decoration, illustration). Chart second series (supportStrong): #FF4BB2.
- Status (text on tint): success #0E7C3A on #E3F4E9, warning #A75906 on #FAEFE1, danger #CE2020 on #FBE5E5, info #5C7300 on #ECEFE0.

## Typography
- UI and body: Inter. Display (screen titles, hero headlines): Instrument Serif. Numbers: Inter with tabular figures, bold.
- Use only these 5 sizes: display 32 / 400 Instrument Serif / -0.01em; title 20 / 600 Inter; body 16 / 400; label 14 / 500; caption 13 / 500.
- Big hero stat numbers may use display size in Inter 700.
- Minimum text 12px (13px chips and tags, 14px safety or legal text).

## Shape and elevation
- Radius: card 20, control 14, input 12, pill 999.
- Card shadow: 0 1px 2px rgba(28,31,12,.04) + 0 8px 24px rgba(28,31,12,.06). No hard or black shadows.

## Icons
- One set only: Lucide-style rounded outline, 24px, 1.75 stroke. Do not mix filled and outline.

## Controls (one spec each, reused on every screen)
- Primary button: pill, 56px tall, neon #CCFF00 fill, ink #1C1F0C label 16/600. Pressed #B8E600 fill. Disabled 40% opacity.
- Dark button: pill, 56px, ink #1C1F0C fill, white label.
- Secondary button: pill, white, 1.5px #92975F border, ink label.
- Text input: 12px radius, 52px tall, white, 1px #92975F border; focus 2px #647D00 ring; error #CE2020 border + 13px helper.
- Card: white, 20px radius, soft shadow.
- Chip: pill, 32px tall, #F8FFDB fill with #647D00 text 13/500; selected chip = ink fill with neon #CCFF00 text.
- Progress bar: 8px pill, track #F1F5E4, fill #647D00 (or neon on ink cards).
- Activity ring: thick neon #CCFF00 arc on an ink card, track at 15% white.

## Shared components
- Bottom tab bar (on tab screens only): exactly 5 tabs in this order: Today (sun icon), Workouts (dumbbell icon), Goals (target icon), Progress (bar chart icon), Profile (user icon). Flat white bar, 1px #E2E7D2 top border, no gradient. Active tab: ink icon + ink label 12/600 with a small neon #CCFF00 pill behind the icon. Inactive: #4B5034 icon + label. Never rename, reorder, add or remove tabs.
- Tab screen header: screen title on the left in Instrument Serif 32, round avatar or icon button on the right.
- Full-screen, detail, modal and onboarding screens show NO bottom tab bar.

## Gradient and focal rules
- The bold focal element per screen is usually an ink (#1C1F0C) hero card with neon numbers, or a big neon ring, or a big stat number. One per screen.
- Any surface with white text is ink #1C1F0C or the gradient #647D00 -> #586E00, nothing lighter. Photo overlays use an ink gradient (transparent to #1C1F0C at 85%) behind white text.
- Pills or chips on a photo or dark surface use a dark translucent fill (ink at 60%), not white.
- Tab bar stays flat.

## Imagery
- Real photography only: people training in bright gyms and outdoors, equipment close-ups. Empty states and onboarding also use real photos or flat 2D vector art. NO 3D renders, claymorphism, isometric, CGI or glossy plastic objects.

## Meaning of color
- Red only for errors and destructive actions (Sign out may stay neutral). Non-urgent warnings use the warning color with an icon.

## Copy scope
- Do not mention: coach chat, meal plan, nutrition, subscription, premium, AI coach, Apple Health, Google Fit, diagnosis. No invented integrations or person names beyond those in the screen prompts (the user is Alex Morgan).
