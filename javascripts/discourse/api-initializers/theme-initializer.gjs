import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {

  function format(text) {
    return text
      .replace(/_/g, " ")
      .replace(/\b\w/g, c => c.toUpperCase());
  }

  function fixElement(el, key) {
    if (!el || el.dataset[key]) return;
    el.textContent = format(el.textContent);
    el.dataset[key] = "true";
  }

  function fixAll(root = document) {

    // Fix tags
    root.querySelectorAll("a.discourse-tag, .discourse-tags a").forEach(el => {
      fixElement(el, "fixedTag");
    });

    // Fix usernames
    root.querySelectorAll(".username").forEach(el => {
      fixElement(el, "fixedUser");
    });

  }

  // ✅ Works for posts
  api.decorateCookedElement((element) => {
    fixAll(element);
  }, { id: "fix-tags-users" });

  // 🔥 Main fix for /latest (Ember re-render issue)
  function observeTopicList() {
    const target = document.querySelector(".topic-list");
    if (!target) return;

    const observer = new MutationObserver(() => {
      fixAll(target);
    });

    observer.observe(target, {
      childList: true,
      subtree: true
    });

    // run once initially
    fixAll(target);
  }

  // Run on navigation
  api.onPageChange(() => {
    requestAnimationFrame(() => {
      fixAll();
      observeTopicList();
    });
  });

});

