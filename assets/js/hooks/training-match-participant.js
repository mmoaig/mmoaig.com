export const TrainingMatchParticipant = {
    mounted() {
        const sourceCode = this.el.dataset.sourceCode;
        const participantId = this.el.dataset.participantId;

        this.runBot = new Function(`
            ${sourceCode}
            return takeTurn(); 
        `);

        this.handleEvent(`take_turn:${participantId}`, turn => {
            const data = this.runBot();
            this.pushEvent('take_turn', { turnId: turn.id, data });
        });
    }
};