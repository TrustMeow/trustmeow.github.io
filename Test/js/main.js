// Simple SPA Router with funky effects
document.addEventListener('DOMContentLoaded', () => {
    // Initialize glitch canvas
    initGlitchEffect();
    
    // Define routes and their content
    const routes = {
        '/': {
            title: 'Home',
            html: `
                <h1 class="glitch-effect">Welcome to My Funky Site</h1>
                <p>This is a completely dynamic SPA that works on GitHub Pages!</p>
                <div class="grid">
                    <div class="grid-item neon-box">✨</div>
                    <div class="grid-item neon-box">🌈</div>
                    <div class="grid-item neon-box">👾</div>
                </div>
            `,
            init: () => console.log('Home page initialized')
        },
        '/games': {
            title: 'Games',
            html: `
                <h1>Game Zone</h1>
                <div id="game-container"></div>
                <button id="start-game">Start Funky Game</button>
            `,
            init: () => {
                // This will be called when the games route loads
                console.log('Games page initialized');
                // game.js will handle this
            }
        },
        '/about': {
            title: 'About',
            html: `
                <h1>About This Funky Site</h1>
                <p>Everything is rendered with JavaScript!</p>
                <p>No page reloads, just smooth transitions.</p>
            `
        },
        '/contact': {
            title: 'Contact',
            html: `
                <h1>Get in Touch</h1>
                <form class="neon-form">
                    <input type="text" placeholder="Your name" class="neon-input">
                    <input type="email" placeholder="Your email" class="neon-input">
                    <textarea placeholder="Your message" class="neon-input"></textarea>
                    <button type="submit" class="neon-button">Send</button>
                </form>
            `
        }
    };

    // Router function
    function router() {
        const path = window.location.pathname;
        const route = routes[path] || routes['/'];
        
        // Update title
        document.title = route.title + ' | Funky SPA';
        
        // Update content
        const app = document.getElementById('app');
        app.innerHTML = route.html;
        
        // Initialize route-specific JS
        if (route.init) route.init();
        
        // Add funky transition effect
        app.style.animation = 'none';
        app.offsetHeight; // Trigger reflow
        app.style.animation = 'fadeIn 0.5s ease-out';
    }

    // Handle navigation
    document.addEventListener('click', (e) => {
        if (e.target.matches('[data-route]')) {
            e.preventDefault();
            const path = e.target.getAttribute('href');
            window.history.pushState({}, '', path);
            router();
        }
    });

    // Handle back/forward
    window.addEventListener('popstate', router);

    // Initial load
    router();
});

// Funky background effect
function initGlitchEffect() {
    const canvas = document.getElementById('glitchCanvas');
    const ctx = canvas.getContext('2d');
    
    // Set canvas size
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    
    // Glitch animation
    function draw() {
        ctx.fillStyle = '#0f0f1a';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        // Add random noise
        for (let i = 0; i < 100; i++) {
            const x = Math.random() * canvas.width;
            const y = Math.random() * canvas.height;
            const size = Math.random() * 3;
            const hue = Math.random() * 360;
            
            ctx.fillStyle = `hsla(${hue}, 100%, 50%, 0.1)`;
            ctx.fillRect(x, y, size, size);
        }
        
        requestAnimationFrame(draw);
    }
    
    draw();
}
