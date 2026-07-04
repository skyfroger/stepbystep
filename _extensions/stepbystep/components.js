function registerAlpineComponents() {
    Alpine.data("pagebypage", (total, pageHeadersLevel = 3) => ({
        current: 0,
        total: total,
        viewportHeight: 0,
        stepHeaders: [],
        stepEls: [],
        taskCompletion: Array(total).fill(0),
        _resizeObserver: null,
        _activeEl: null,
        _unwatch: null,
        init() {
            this.$nextTick(() => {
                this.stepEls = Array.from(this.$el.querySelectorAll(".step"));

                // count, how many questions each step contains
                this.stepEls.forEach((page, index) => {
                    const qNum = page.querySelectorAll(
                        ".qinput__container, .qgroup__ready",
                    ).length;
                    this.taskCompletion[index] = qNum;
                });

                const headers = this.$el.querySelectorAll(
                    `.step h${pageHeadersLevel}`,
                );
                this.stepHeaders = Array.from(headers).map((h) => h.innerHTML);

                this._resizeObserver = new ResizeObserver((entries) => {
                    for (const entry of entries) {
                        this.viewportHeight =
                            entry.borderBoxSize?.[0]?.blockSize ??
                            entry.target.scrollHeight;
                    }
                });

                this.observeStep(this.current);

                this._unwatch = this.$watch("current", (value) => {
                    this.observeStep(value);
                });

                // Подстраховка на догрузку шрифтов
                if (document.fonts?.ready) {
                    document.fonts.ready.then(() =>
                        this.observeStep(this.current, true),
                    );
                }
            });
        },
        catchAnswers(event) {
            /*
            event.detail schema:
            {
                type: question type
                isCorrect: self explanatory
                attempts: current attempt number
            }
            */

            // count events only from this type of questions
            const approvedQuestionTypes = ["qgroup", "qinput", "qselect"];
            // destructure event.detail
            const { isCorrect, type } = event.detail;

            if (isCorrect && approvedQuestionTypes.includes(type)) {
                this.taskCompletion[this.current] =
                    this.taskCompletion[this.current] - 1;
            }
        },
        observeStep(index, forceRemeasure = false) {
            const el = this.stepEls[index];
            if (!el) return;
            if (el === this._activeEl && !forceRemeasure) return;

            if (this._activeEl) {
                this._resizeObserver.unobserve(this._activeEl);
            }
            this._activeEl = el;
            this._resizeObserver.observe(el);
            this.viewportHeight = el.scrollHeight;
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
            if (index < 0 || index >= this.total || index === this.current)
                return;
            this.current = index;
            this.$refs.main.scrollIntoView({ behavior: "smooth" });
        },
        destroy() {
            this._resizeObserver?.disconnect();
            this._unwatch?.();
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
