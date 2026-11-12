/* Active-section tracking for the PowerFit Gym navigation.
   Progressive enhancement: anchors still work when JavaScript is disabled. */
(function () {
  "use strict";

  const header = document.querySelector(".site-header");
  if (!header) return;

  const entries = Array.from(header.querySelectorAll('nav a[href^="#"]'))
    .map((link) => ({ link, section: document.getElementById(link.hash.slice(1)) }))
    .filter((entry) => entry.section);

  if (!entries.length) return;

  function updateActive() {
    // The activation line follows the sticky header's real height, even on mobile.
    const activationLine = header.getBoundingClientRect().bottom + 24;
    let active = entries[0];

    for (const entry of entries) {
      if (entry.section.getBoundingClientRect().top <= activationLine) {
        active = entry;
      }
    }

    // On the last screen, select the final section even if its top
    // cannot reach the activation line because the document ends.
    if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 3) {
      active = entries[entries.length - 1];
    }

    for (const entry of entries) {
      const selected = entry === active;
      entry.link.classList.toggle("is-active", selected);
      if (selected) entry.link.setAttribute("aria-current", "location");
      else entry.link.removeAttribute("aria-current");
    }
  }

  let scheduled = false;
  function scheduleUpdate() {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => { scheduled = false; updateActive(); });
  }

  window.addEventListener("scroll", scheduleUpdate, { passive: true });
  window.addEventListener("resize", scheduleUpdate);
  window.addEventListener("hashchange", scheduleUpdate);
  window.addEventListener("load", scheduleUpdate);
  header.querySelectorAll('nav a[href^="#"]').forEach((link) => {
    link.addEventListener("click", () => {
      // Give visual feedback immediately; scrolling then synchronizes it.
      for (const entry of entries) {
        const selected = entry.link === link;
        entry.link.classList.toggle("is-active", selected);
        if (selected) entry.link.setAttribute("aria-current", "location");
        else entry.link.removeAttribute("aria-current");
      }
    });
  });
  scheduleUpdate();
})();
