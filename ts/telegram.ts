import { viewport, init, isTMA } from "@telegram-apps/sdk";

async function initTg() {
    if (await isTMA()) {
        init(); // init tg app

        if (viewport.mount.isAvailable()) {
            await viewport.mount();
            viewport.expand(); // first it would be better to expand
        }

        if (viewport.requestFullscreen.isAvailable()) {
            await viewport.requestFullscreen(); // then request full screen mode
        }
    }
}

(async () => {
    await initTg();
})();