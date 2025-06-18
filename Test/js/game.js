// Game-specific code
document.addEventListener('DOMContentLoaded', () => {
    // This will run on initial load, but we only want it for the games route
    if (!window.location.pathname.includes('games')) return;

    const gameContainer = document.getElementById('game-container');
    const startButton = document.getElementById('start-game');
    
    startButton.addEventListener('click', () => {
        startGame();
    });
    
    function startGame() {
        gameContainer.innerHTML = `
            <div class="game-screen">
                <div id="player" class="player"></div>
                <div class="enemy"></div>
            </div>
            <style>
                .game-screen {
                    width: 100%;
                    height: 300px;
                    background: linear-gradient(45deg, #ff00ff, #00ffff);
                    position: relative;
                    overflow: hidden;
                }
                
                .player {
                    width: 50px;
                    height: 50px;
                    background: white;
                    position: absolute;
                    bottom: 20px;
                    left: 50px;
                }
                
                .enemy {
                    width: 30px;
                    height: 30px;
                    background: red;
                    position: absolute;
                    top: 20px;
                    right: -30px;
                    animation: moveEnemy 3s linear infinite;
                }
                
                @keyframes moveEnemy {
                    from { right: -30px; }
                    to { right: 100%; }
                }
            </style>
        `;
    }
});
