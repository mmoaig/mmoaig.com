export const TrainingMatchParticipant = {
    mounted() {
        const sourceCode = this.el.dataset.sourceCode;
        const participantId = this.el.dataset.participantId;

        this.runBot = new Function(`
            ${sourceCode}
            return takeTurn(); 
        `);

        this.handleEvent(`take_turn:${participantId}`, () => {
            const turn = this.runBot();
            console.log({ turn });
        })
    }
};