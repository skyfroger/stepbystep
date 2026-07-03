function registerAlpineComponents() {
    Alpine.data("pagebypage", (total, pageHeadersLevel = 3) => ({
        current: 0,
        total: total,
        viewportHeight: 0,
        stepHeaders: [],
        async init() {
            await this.$nextTick();
            const headers = this.$el.querySelectorAll(
                `.step h${pageHeadersLevel}`,
            );
            this.stepHeaders = Array.from(headers).map((h) => h.innerHTML);

            const observer = new MutationObserver(() => {
                this.updateHeight();
            });

            observer.observe(this.$refs.viewport, {
                attributes: true,
                subtree: true,
                attributeFilter: ["class"],
            });

            this.updateHeight();
        },
        next() {
            if (this.current === this.total - 1) return;
            this.current++;
            this.$refs.main.scrollIntoView({ behavior: "smooth" });
        },
        prev() {
            if (this.current === 0) return;
            this.current--;
            this.$refs.main.scrollIntoView({ behavior: "smooth" });
        },
        go(index) {
            if (index < 0 || index > total || index === this.current) return;
            this.current = index;
        },
        async updateHeight() {
            await this.$nextTick();
            const active = this.$el.querySelector(".step.active");
            if (active) {
                this.viewportHeight = active.scrollHeight;
            }
        },
    }));
}

if (window.Alpine) {
    registerAlpineComponents();
} else {
    document.addEventListener("alpine:init", () => {
        registerAlpineComponents();
    });
}
