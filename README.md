# Ch Aarush Udbhav — Portfolio

My personal portfolio. One self-contained `index.html`: no build step, no framework,
no dependencies beyond GSAP and a font.

**Live:** [aarushch.github.io/Portfolio](https://aarushch.github.io/Portfolio/)

## Stack

- HTML5 / CSS3 with custom properties for theming
- Vanilla JavaScript
- GSAP 3 + ScrollTrigger for the intro timeline, card fan-out, scroll reveals and counters
- DM Sans (Google Fonts), Font Awesome 6
- Web3Forms for the contact form

## Editing content

Content lives in arrays at the top of the script block and the page renders from them.
Edit the data, not the markup.

| Constant | Drives |
|---|---|
| `PROJECTS` | Hero card fan and the Work grid |
| `HERO_ORDER` | Left-to-right order of the hero fan, by project id |
| `EXPERIENCE` | Experience timeline |
| `CERTS` | Certificate grid and lightbox order |
| `SKILLS` | Skill columns in About |
| `MARQUEE` | Scrolling ticker |
| `PHRASES` | Hero typewriter lines, cycled in order |
| `ART` | One inline SVG motif per project, so projects need no images |

A project entry:

```js
{
  id: "argo",
  name: "Argo",
  short: "Argo", shortSub: "Churn survival",
  sub: "Contributor Churn Intelligence",
  period: "Jul 2026 — Present",
  status: "Active",
  featured: true,
  blurb: "…",
  metrics: [{ v: "547K", l: "Events" }],
  stack: ["Python", "XGBoost"],
  links: [{ label: "Source", href: "…", icon: "fab fa-github", solid: false }]
}
```

- `id` must match a key in `ART`.
- Empty `links` shows "Case study and repo coming soon".
- One project should have `featured: true`. It spans the full grid row, which also
  stops an odd project count leaving an orphan card on the last row.
- Metric values starting with a digit, `.` or `~` render large. Word values drop to a
  smaller size automatically so rows stay aligned.
- `HERO_ORDER` is deliberately separate from grid order: the fan is largest in the
  middle, so the strongest project belongs at the centre of that list.

## Images

| Path | Purpose |
|---|---|
| `images/thumbs/` | 720px certificate thumbnails for the cards, lazy-loaded |
| `images/full-*.jpg` | 1600px scans for the lightbox |
| `images/cert-*` | Untouched originals, kept as source, not loaded by the page |
| `images/favicon-64.png` | 64px favicon |

### Adding a certificate

1. Drop the original into `images/` as `cert-<slug>.jpg`.
2. Regenerate derived images. Safe to re-run, it rebuilds everything:

   ```powershell
   powershell -File tools/optimize-images.ps1
   ```

3. Add an entry to `CERTS` with `file: "cert-<slug>"`, `name`, `org`, `year`.
4. Bump `data-count` on the Certifications stat block.

If an original is stored rotated, add its filename to `$rotateList` in the script.
`cert-sih-2023` is already in there. The nine originals total around 13 MB; the
derived thumbnails the page actually loads come to about 500 KB.

## Things that will bite again

Notes to self, all of these cost me time once already.

- **Certificate cards are `<button>`s.** Buttons default to `color: buttontext`,
  which is black. Any text inside needs an explicit colour or it vanishes on the
  dark card.
- **`background-clip: text` on a parent does not paint inline-block children.**
  The giant hero letters are separate spans, so the gradient has to sit on each
  letter, not on the wrapper.
- **Two animations must never write the same transform channel.** The hero cards
  are touched by four things at once: the scroll handler (`x`, `y`, `rotation`),
  the idle float (`yPercent`), the hover lift (`rotateX`, `rotateY`, `scale`) and
  the mouse parallax (CSS `translate`). When the float also animated `y` and
  `rotation`, it fought the scroll handler every frame and the cards visibly
  jumped while scrolling. Keep the channels disjoint.
- **Scroll reveals must not animate `scale`.** A staggered scale makes cards
  genuinely different sizes mid-flight, which looks like a layout bug. They also
  need `clearProps: "transform"`, or a leftover translate leaves a card sitting
  outside its grid and overlapping the next section.
- **Keep background gradients symmetrical.** Large off-centre radials look fine on
  a laptop and land as blotches near one edge on an ultrawide. Everything left is
  centred or clipped inside a rounded card.
- **The hero card fan needs mirrored percentages.** For a pair,
  `right.left = 100% - left.left - width`. Without that the fan drifts left. It also
  needs a `max-width`, or it keeps spreading on wide screens until it detaches from
  the headline.
- **The nav must sit above the mobile menu overlay,** otherwise the close button is
  covered and the menu can only be dismissed by tapping a link.
- **JS writes the cursor ring's `transform`,** so its hover and press states have to
  change fill or border. A CSS transform there gets overwritten every frame.
- **The lens magnification is deliberately small (~1.08).** Higher and the magnified
  face misaligns with the base at the rim and reads as a rendering glitch.

## Hero headline

The headline types and erases through `PHRASES` on a loop. Each letter is a nested
pair of spans: the outer one carries a looping CSS wave with a per-letter delay, the
inner one gets a GSAP bounce as it is typed. They have to be separate elements,
otherwise the wave and the bounce would both be writing `transform` on the same node.

## Loading screen

Tracks fonts, eager images and `window.load`, and eases a counter toward whichever
is further along: real progress or a minimum-duration ramp. Holds for at least
1.5s so it cannot flash past on a warm cache, and gives up after 6s so a stalled
asset cannot trap anyone. The hero intro timeline is built paused and started by
the loader, so it never plays behind the curtain.

## Background and cursor

A fixed canvas draws a slow node field behind the page, brightening near the
pointer. Node count scales with viewport area but caps at 110, device pixel ratio
caps at 1.5, and the loop stops when the tab is hidden.

The custom cursor is a dot that tracks exactly plus a ring that eases behind it,
expanding over clickable elements and collapsing to a caret bar over text inputs.
It only activates under `(hover: hover) and (pointer: fine)`.

## Accessibility

Full `prefers-reduced-motion` path: all animation is skipped, the background renders
one static frame, the custom cursor never activates, and content renders in place.
The certificate lightbox is keyboard driven with Escape and arrow keys and restores
focus on close.

## Running locally

```bash
npx serve .
```

Then open `http://localhost:3000`. Opening the file directly over `file://` works
too, but the contact form's captcha will warn about an invalid host.

## Deployment

GitHub Pages from `main`, root folder. Push and it republishes.

## Contact

- aarushch666@gmail.com
- [LinkedIn](https://www.linkedin.com/in/ch-aarush-udbhav/)
- [GitHub](https://github.com/AarushCh)
- [YouTube](https://www.youtube.com/@auc_ae)

© 2026 Ch Aarush Udbhav. All rights reserved.
