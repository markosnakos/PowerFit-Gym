/* Active-section tracking for the PowerFit Gym navigation.
   Progressive enhancement: anchors still work when JavaScript is disabled. */
(function () {
  "use strict";

  const header = document.querySelector(".site-header");
  if (!header) return;
  const root = document.documentElement;

  const entries = Array.from(header.querySelectorAll('nav a[href^="#"]'))
    .map((link) => ({ link, section: document.getElementById(link.hash.slice(1)) }))
    .filter((entry) => entry.section);

  if (!entries.length) return;

  function updateHeaderHeight() {
    root.style.setProperty("--header-height", `${header.getBoundingClientRect().height}px`);
    scheduleUpdate();
  }

  function updateActive() {
    // Use the same padding and target margin as the browser's anchor alignment.
    const activationLine = parseFloat(getComputedStyle(root).scrollPaddingTop);
    let active = entries[0];

    for (const entry of entries) {
      const targetMargin = parseFloat(getComputedStyle(entry.section).scrollMarginTop) || 0;
      if (entry.section.getBoundingClientRect().top - targetMargin <= activationLine + 1) {
        active = entry;
      }
    }

    // On the last screen, select the final section even if its top
    // cannot reach the activation line because the document ends.
    if (window.innerHeight + window.scrollY >= root.scrollHeight - 3) {
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
  window.addEventListener("resize", updateHeaderHeight);
  window.addEventListener("hashchange", scheduleUpdate);
  window.addEventListener("load", updateHeaderHeight);
  if (typeof ResizeObserver === "function") {
    new ResizeObserver(updateHeaderHeight).observe(header);
  }
  header.querySelectorAll('nav a[href^="#"]').forEach((link) => {
    link.addEventListener("click", () => {
      // Give visual feedback immediately. Scrolling then synchronizes it.
      for (const entry of entries) {
        const selected = entry.link === link;
        entry.link.classList.toggle("is-active", selected);
        if (selected) entry.link.setAttribute("aria-current", "location");
        else entry.link.removeAttribute("aria-current");
      }
    });
  });
  updateHeaderHeight();
})();
